# -*- encoding : utf-8 -*-
# 目前仅支持 application/json 
class ServiceController < ActionController::Base

  WHITE_LIST=[/^md5sum/, /^curl/, /^rpm -qa/, /^ulimit/, /^du/, /^cat [-_0-9A-Za-z\/].+\/[-_A-Za-z]\.real\.properties$/ ]
  respond_to :json

  before_filter :auth

  def add_machine
    if app.nil?
      render :status => 404, :text => 'app does not exist'
    else
      room = Room.find_by_name params[:room_name]
      if room.nil?
        render :status => 404, :text => "room does not exist: #{params[:room_name]}"
      else
        machine = app.envs[:online].machines.new(
          params[:machine]
            .slice(:host,:name,:port,:user,:password)
            .update(locked: true, room_id: room.id)
        )

        if machine.save
          respond_with machine
        else
          head :bad_request, machine.errors
        end
      end
    end
  end

  def remove_machine
    if request.delete?
      if app.nil?
        render :status => 404, :text => 'app does not exist'
      else
        machine = app.machines.find params[:machine_id]
        if machine
          # destroy whatever it locked
          machine.locked = false
          machine.destroy
          respond_with machine
        else
          render :status => 404, :text => 'machine does not exist'
        end
      end
    else
      head :method_not_allowed
    end
  end

  def send_cmd
    if request.post?
      m = Machine.where( params.slice :host,:name,:user ).first
      if m && m.app
        if @current_user.is_pe? m.app
          if params[:command].present?
            directive = m.make_directive(params[:command])
            respond_with directive
          else
            head :bad_request
          end
        elsif @current_user.is_a? Reader
          WHITE_LIST.each do |rr|
            if rr.match(params[:command])
              directive = m.make_directive(params[:command])
              respond_with directive
              return
            end
          end
          head :bad_request
        end
      else
        head :unauthorized
      end
    else
      head :method_not_allowed
    end
  end

  def get_result
    directive = Directive.find params[:id]
    machine = directive.machine
    if @current_user.owned_machines(machine.app).include? machine
      respond_with directive
    elsif @current_user.is_a? Reader
      respond_with directive
    else
      head :unauthorized
    end
  end

  def machines
    machine = Machine.where( params.slice :host,:name ).first
    if @current_user.owned_machines(machine.app).include? machine
      respond_with machine
    elsif @current_user.is_a? Reader
      respond_with machine
    else
      head :unauthorized
    end
  end

  private
  def auth
    authenticate_or_request_with_http_basic do |email, password|
      @current_user = User.authenticate email, password
      not @current_user.nil?
    end
  end

  def app
    @app ||= begin
               app = App.reals.where(name:params[:app_name]).first
               @current_user.is_pe?(app) ? app : nil
             end
  end
end
