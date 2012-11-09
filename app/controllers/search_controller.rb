# -*- encoding : utf-8 -*-
class SearchController < BaseController
  autocomplete :user, :email
end
