# -*- encoding : utf-8 -*-

# 指令模板，用户执行指令时根据模板内容生成指令对象
# 指令包括两种: shell 脚本 和 服务插件
# shell 脚本： 由 apposs 下发到指定的目标机器上运行，和在目标机器本地运行脚本没有区别
# 服务插件  ： 在 apposs 系统上执行相应的服务任务，仅支持有限的预定义的功能
class DirectiveTemplate < ActiveRecord::Base

  GLOBAL_ID = 0

  belongs_to :directive_group
  belongs_to :owner, :class_name => 'User'
  has_many :directives

  scope :pluglets, where(pluggable: true)
  
  validates_uniqueness_of :alias, :scope => [:directive_group_id, :owner_id]
  validates_presence_of :name,:alias
  validates_length_of :name, maximum: 512
  
  before_save :clean_line_break
  def clean_line_break
    self.name = self.name.
      delete("\r").
      gsub( /\n+/, ' && ' ).
      gsub(/ && +&& /, ' && ').
      gsub(/(^ +&&|&& +$)/,'')
  end

  def gen_directive params={}
    directive = directives.new(directive_args.update params)
    directive.save!
    directive
  end

  def directive_args
    {
      :command_name => self.name,
      :operation_id => Operation::DEFAULT_ID,
      :next_when_fail => true,
      :pluggable => self.pluggable
    }
  end

  # 根据传入的app和machines信息创建相应的指令实例
  # <tt>args</tt> 构造directive对象的参数
  # <tt>app</tt> directive从属的app
  # <tt>machines</tt> 指定的机器列表
  #
  # 返回一个map，key为机器id，value为创建的指令实例
  def make_directives args, app, machines
    if pluggable
      directive = gen_directive args.update(params: app.enable_properties)
      machines.reduce({})do |map, m|
        yield m.id, directive if block_given?
        map.update m.id => directive
      end
    else
      machines.reduce({}) do |map, m|
        directive = gen_directive args.update(m.directive_args)
        yield m.id, directive if block_given?
        map.update m.id => directive
      end
    end
  end

  def to_s
    self.alias || self.name
  end
 
  class << self
    def make_pluglet name, command
      DirectiveGroup['default'].directive_templates.create!(
        :alias => name, :name => command, :pluggable => true
      )
    end
  end
end
