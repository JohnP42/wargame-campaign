class CreateArmies < ActiveRecord::Migration
  def change
    create_table :armies do |t|
    	t.string :name
    	t.string :description
    	t.belongs_to :user
      t.timestamps null: false
    end
  end
end
