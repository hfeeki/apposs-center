# -*- encoding : utf-8 -*-
class SearchController < BaseController

  respond_to :json

  def user_by_email
    respond_with Redis::Search.complete('User', params[:query]).map{|data| data['title']}
  end

  def app_by_name
    respond_with Redis::Search.complete('App', params[:query]).map{|data| data['title']}
  end

end
