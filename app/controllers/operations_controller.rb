# coding: utf-8
class OperationsController < ResourceController
  def pluglets
    @directives = Operation.find(params[:id]).directives.where(:pluggable => true)
    render :partial => 'shared/directives'
  end
end
