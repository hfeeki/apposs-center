class AddMachineLockField < ActiveRecord::Migration
  def change
    add_column :machines, :locked, :boolean
  end
end
