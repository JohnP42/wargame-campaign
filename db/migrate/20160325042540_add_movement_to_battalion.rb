class AddMovementToBattalion < ActiveRecord::Migration
  def change
  	add_column :battalions, :movement, :float, default: 0.0	
  end
end
