# -*- encoding : utf-8 -*-
class AddIndexForMachine < ActiveRecord::Migration
  def change
    add_index(:machines, :app_id)    
    add_index(:machines, :env_id)    
  end
end
