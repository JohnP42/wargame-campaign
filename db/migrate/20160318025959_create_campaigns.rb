class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
    	t.string :name
    	t.string :description
    	t.belongs_to :map, index:true
      t.timestamps null: false
    end
  end
end
