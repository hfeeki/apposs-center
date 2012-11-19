# -*- encoding : utf-8 -*-
class MachinesController < ResourceController

  include Rails.configuration.adapter

  def create
    @machine = current_app.machines.new(params[:machine])
    @machine.locked = true
    create!
  end

  def change_user
    @machine_ids = check_machine_ids(params[:machine_ids])
    
    @failed_machines = current_user.
                                    owned_machines(App.find(params[:app_id])).
                                    where(:id => @machine_ids).inject([]) do |arr, machine|
      if machine.update_attributes user: params[:data]
        arr
      else
        arr << machine
      end
    end
  end
  
  def change_env
    @machine = machine_by_id
    env_obj = @machine.app.envs.find params['env_id']
    @machine.update_attributes env: env_obj
  end
  
  def change_app
    @machine = machine_by_id
    @app = App.reals.where(name: params[:name]).first
    @result = if @app
                @machine.reassign @app, true
              end
  end
  
  def reload
    MachineLoader.load current_app
    respond_to do |format|
      format.js
    end
  end

  def reset
    @machine = machine_by_id
    @directive = @machine.send_reset
  end
  
  def clean_all
    @machine = machine_by_id
    @directive = @machine.send_clean_all
  end
  
  def interrupt
    @machine = machine_by_id
    @directive = @machine.send_interrupt
  end
  
  def pause
    @machine = machine_by_id
    @directive = @machine.send_pause
  end
  
  def reconnect
    @machine = machine_by_id
    @directive = @machine.send_reconnect
  end

  def unlock
    @machine = machine_by_id
    @machine.unlock
  end

  def directives
    @directives = machine_by_id.directives.without_state(:done).id_desc
  end
  
  def old_directives
    @directives = machine_by_id.directives.where(:state => :done).id_desc

  protected
  def begin_of_association_chain
    current_app
  end

  private
  def check_machine_ids machine_ids
    (machine_ids||[]).collect { |s| s.to_i }.uniq
  end
  
  def machine_by_id
    current_app.machines.find(params[:id])
  end
end
