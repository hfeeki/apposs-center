# -*- encoding : utf-8 -*-
class Operation::MachinesController < ResourceController

  def index
    @operation = Operation.find(params[:operation_id])
    @machines = @operation.machines.uniq
  end

  def directives
    @directives = Directive.where(:operation_id => params[:operation_id], :machine_id => params[:id])
    render :partial => 'shared/directives'
  end

end
