class DirectiveTemplateAddPluggable < ActiveRecord::Migration
  def change
    add_column :directive_templates, :pluggable, :boolean
    add_column :directives, :pluggable, :boolean
  end
end
