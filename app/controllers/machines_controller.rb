# -*- encoding : utf-8 -*-
class MachinesController < ResourceController

  include Rails.configuration.adapter

  def create
    @machine = current_app.machines.new(params[:machine])
    @machine.locked = true
    create!
  end

  def destroy
    machine = current_app.machines.find(params[:id])
    if machine.locked?
      machine.locked = false
      @result = machine.destroy
      respond_with machine
    end
  end

  def item
    @machine = machine_by_id
  end

  def app_item
    @machine = machine_by_id
  end

  def change_user
    @machine = machine_by_id params[:pk]
    @machine.update_attributes user: params[:value]
  end
  
  def change_env
    @machine = machine_by_id
    env_obj = @machine.app.envs.find params['env_id']
    @machine.update_attributes env: env_obj
  end
  
  def change_room
    @machine = machine_by_id
    room = Room.find params['room_id']
    @machine.update_attributes room: room
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
  end

  protected
  def begin_of_association_chain
    current_app
  end

  private
  def check_machine_ids machine_ids
    (machine_ids||[]).collect { |s| s.to_i }.uniq
  end
  
  def machine_by_id id=params[:id]
    current_app.machines.find(id)
  end
end
