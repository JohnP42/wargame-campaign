class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
    	t.string :name
    	t.string :description
    	t.string :combatType, default: "Infantry"
    	t.integer :price, default: 10
    	t.integer :tier, limit: 3, default: 1
    	t.boolean :hero, default: true
    	t.belongs_to :army, index: true
      t.timestamps null: false
    end
  end
end
