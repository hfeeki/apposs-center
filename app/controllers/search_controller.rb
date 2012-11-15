# -*- encoding : utf-8 -*-
class SearchController < BaseController

  respond_to :json

  def autocomplete_user_email
    respond_with User.where('email like ?', "%#{params[:query]}%").map(&:email)
  end
end
