class DirectiveInvoker
  @queue = :directive

  def self.perform id, action, *args
    directive = Directive.where(:id => id).first
    directive.send(action, *args) if directive
  end
end
