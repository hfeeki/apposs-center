# -*- encoding : utf-8 -*-
class DirectiveRefers < ActiveRecord::Migration

  def change
    add_column :directives, :pre_id, :integer
    add_column :directives, :next_id, :integer
  end

end
