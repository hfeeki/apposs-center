# -*- encoding : utf-8 -*-
class SearchController < BaseController

  respond_to :json

  def user_by_email
    respond_with Redis::Search.complete('User', params[:query]).map{|data| data['title']}
  end

  def app_by_name
    respond_with Redis::Search.complete('App', params[:query]).map{|data| data['title']}
  end

  def app_by_name_and_user
    respond_with App.reals.select(:name).where(
      id: current_user.acls.where(role_id: Role[Role::PE].id).map(&:resource_id)
    ).map(&:name).select{|s| s =~ /^#{params[:query]}/}
  end

end
