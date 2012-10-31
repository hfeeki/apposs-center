# encoding: utf-8
class ResourceController < InheritedResources::Base

  layout false
  respond_to :js,:xml

  helper_method :current_user, :current_app
  protect_from_forgery
 
  def current_app
    @current_app ||= if session[:app_id]
                       current_user.apps.find_by_id(session[:app_id])
                     else
                       current_user.apps.where(:id => params[:app_id]).first
                     end
  end

  def change_current_app app_id
    session[:app_id] = app_id
    @current_app = nil
  end

  def authenticate_pe!
    if current_user.nil? || !current_user.is_pe?( current_app )
      redirect_to root_path
    end
  end
 
  def event
    if resource.events_for_user.include? params[:event].to_sym # 防止注入攻击
      @result = resource.send params[:event].to_sym
    end
  end
  
  protected
    def begin_of_association_chain
      @current_user
    end

end
