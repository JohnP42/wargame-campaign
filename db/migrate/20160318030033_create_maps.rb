class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
    	t.string :name
    	t.string :description
    	t.string :tileset
    	t.belongs_to :user
      t.timestamps null: false
    end
  end
end
