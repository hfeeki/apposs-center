class OperationInvoker
  @queue = :operation

  def self.perform id, choosed_machine_ids, is_hold
    operation = Operation.find id
    template = operation.operation_template
    template.perform(operation, choosed_machine_ids, is_hold)
  end
end
