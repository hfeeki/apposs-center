class AddIndexToStakeholder < ActiveRecord::Migration
  def change
    add_index :stakeholders, [:resource_id, :resource_type]
  end
end
