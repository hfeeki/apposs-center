class DirectiveUpdateIndex < ActiveRecord::Migration
  def up
    add_index :directives, [:room_id, :state]
    add_index :rooms, :name
  end

  def down
    remove_index :directives, :column => [:room_id, :state]
    remove_index :rooms, :name
  end
end
