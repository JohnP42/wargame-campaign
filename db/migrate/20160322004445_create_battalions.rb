class CreateBattalions < ActiveRecord::Migration
  def change
    create_table :battalions do |t|
    	t.belongs_to :user, index: true
    	t.boolean :is_building
    	t.string :data
    	t.integer :x
    	t.integer :y
      t.timestamps null: false
    end
  end
end
