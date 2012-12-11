# -*- encoding : utf-8 -*-
class Machine < ActiveRecord::Base

  default_scope where("`machines`.`state` <> 'offlined' and `machines`.`state` <> 'offlined'").order(:name)
  
  belongs_to :room
  belongs_to :env
  belongs_to :app

  has_many :machine_operations
  has_many :directives

  validates_inclusion_of :port,:in => 1..65535,:message => "port必须在1到65535之间"
  validates_presence_of :name,:host

  before_create :fulfill_default
  before_destroy :check_lock, :clean_all # 清理这个机器时要中止正在执行的指令


  def fulfill_default
    self.app = self.env.app if (self.app.nil? && self.env)
  end

  state_machine :state, :initial => :normal do
    event :pause do transition all => :paused end
    event :reset do transition all => :normal end
    event :disconnect do transition all => :disconnected end
    event :offline do transition all => :offlined end
  end

  # 重新分配machine的应用
  def reassign other_app, force = false
    return false if (app && app.locked? && !force) 
    other_app = App.find other_app if other_app.is_a? Fixnum
    transaction do
      self.directives.each do |dd|
        dd.update_attributes operation_id: Operation::DEFAULT_ID
      end
      self.update_attribute(:app_id, other_app.id)
      self.update_attribute(:env_id, other_app.envs[(self.env.try(:name)||'online').to_sym,true].id)
    end
  end

  def check_lock
    raise 'locked machine cannot destroy' if locked?
  end

  def send_pause
    inner_directive 'machine|pause'
  end
  
  def send_reset
    inner_directive 'machine|reset'
  end
  
  def send_interrupt
    inner_directive 'machine|interrupt'
  end

  def send_reconnect
    self.reset
    inner_directive 'machine|reconnect'
  end

  def send_clean_all
    clean_all
    inner_directive 'machine|clean_all'
  end

  def unlock
    self.update_attributes locked: nil
  end

  def clean_all
    directives.without_state(:done).each{|directive|
      if not directive.control?
        directive.clear || directive.force_stop
      end
    }
  end

  # 获取当前机器的参数信息
  def properties
    (env||app).send :enable_properties rescue Property.global.pairs
  end
  
  def directive_args
    {
      :params => properties,
      :machine_id => id,
      :room_id => room_id,
      :room_name => room.try(:name),
      :machine_host => host
    }
  end

  def inner_directive command
    DirectiveGroup['default'].directive_templates[command].gen_directive(
      directive_args.update(:room_name => room.name)
    )
  end

  def make_directive cmd
    directives.create(
      operation_id: 0,
      directive_template_id: 0,
      next_when_fail: false,
      room_id: room.id,
      room_name: room.name,
      machine_host: self.host,
      command_name: cmd
    )
  end

end
