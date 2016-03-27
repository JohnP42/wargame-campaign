class AddCurrentToArmies < ActiveRecord::Migration
  def change
  	add_column :armies, :is_current, :boolean, default: false	
  end
end
