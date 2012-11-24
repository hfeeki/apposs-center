# -*- encoding : utf-8 -*-

# 在一台机器上运行的一个原子指令实例，指令本身的生命周期用state_machine进行了约定
# 大部分原子指令从属于一个操作，某些特殊的原子指令独立运行，此时 operation_id 为
# operation模型指定的缺省值
# 前趋指令和后继指令：
#   directive可能会有前趋和后继指令，并且可能有多个
#   两个directive之间如果有顺序关系，那么当前一个结束时将驱动后一个变为可用或者驱动执行
#
class Directive < ActiveRecord::Base
  belongs_to :machine
  belongs_to :operation
  belongs_to :template, :class_name => 'DirectiveTemplate', :foreign_key => 'directive_template_id'

  belongs_to :pre,  :class_name => 'Directive'
  has_many :nexts,  :class_name => 'Directive', :foreign_key => :pre_id

  belongs_to :next, :class_name => 'Directive'
  has_many :pres,   :class_name => 'Directive', :foreign_key => :next_id
  
  scope :id_asc, order("operation_id asc, id asc")
  scope :id_desc, order("id desc")
  scope :normal, where('operation_id <> 0')
  
  attr_accessor :params

  before_create do
    if self.pluggable? and self.operation
      file_entry = AppossFile::FileEntry.where(
        operation_template_id: self.operation.operation_template.id
      ).first
      if file_entry
        app = self.operation.app
        self.params = {
          public_folder: "#{file_entry.public_folder}/target",
          private_folder: "#{file_entry.private_folder}/target"
        }.update(self.params||{})
		Rails.logger.info "directive(#{self.id}) params: #{self.params.inspect}"
	  else
		Rails.logger.info "file_entry not found: #{self.operation_id}"
      end
    end

    if self.params && self.params.is_a?(Hash)
      self.params.each_pair do |k,v|
        command_name.gsub! %r{\$#{k}}, "#{v}"
      end
    end
  end

  #TODO  未来将迁移 command_name 字段，改为 command
  def command
    self.command_name
  end

  def command= value
    self.command_name = value
  end

  # 反馈执行结果
  def callback( isok, body)
    self.isok = isok
    self.response = body.valid_encoding? ? body : encode_try(body)
    isok ? ok : error
  end

  state_machine :state, :initial => :init do
    # 需要延迟使用的directive，可以初始化为hold状态
    event :enable do transition :hold => :init end
    # 清理已经无用的未执行directive
    event :clear do transition [:hold, :init, :ready] => :done end
    event :download do transition :init => :ready end
    event :invoke do transition :ready => :running end
    event :force_stop do transition :running => :failure end
    event :error do transition [:init, :ready, :running] => :failure end
    event :ok do transition [:ready, :running] => :done end
    event :ack do transition :failure => :done end

    after_transition :on => :enable, :do => :after_enable
    after_transition :on => :invoke, :do => :fire_operation
    after_transition :on => :error, :do => :error_fire
    after_transition :on => [:ok,:ack], :do => :after_complete
    after_transition :on => [:clear], :do => :try_operation_clear
    before_transition :on => [:clear,:force_stop], :do => :put_response
  end
  
  def events_for_user
    state_events - [:download,:error,:invoke,:ok,:force_stop,:clear,:enable]
  end

  def put_response
    self.response = "stoped( when #{self.state})"
  end

  def fire_operation
    operation.try :fire
  end

  def error_fire
    operation.try :error
    machine.pause if machine
  end

  def after_enable
    if pluggable?
      download
      invoke
      exec_command command
    end
  end

  def after_complete
    if operation && operation.directives.without_state(:done).count == 0
      operation.ok || operation.ack
    end
    enable_next
  end

  def try_operation_clear
    operation.try :error
  end

  def control?
    (self.command_name||'').start_with? 'machine|'
  end
  
  def encode_try text
    ['GBK'].each do |from_enc|
      result = text.encode 'utf-8', from_enc
      return result if result.valid_encoding?
    end
    'Agent错误[编码不支持]'
  end

  private
  def enable_next
    if self.next
      unless self.next.pres.map(&:done?).include? false
        self.next.enable
      end
    elsif self.nexts.present?
      self.nexts.each(&:enable)
    end
  end

  def exec_command cmd
    Bundler.with_clean_env do
      Rails.logger.info "exec command: #{cmd}"
      IO.popen('-') do |io|
        if io
          # parent
          io.gets
        else
          # child
          body = `#{cmd}`
          result = $?.exitstatus
          self.callback result==0,body
          Rails.logger.info "exec result: #{cmd} - #{result}"
        end
      end
    end
  end

end
