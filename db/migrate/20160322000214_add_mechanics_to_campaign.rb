class AddMechanicsToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :turn, :integer
  	add_column :campaigns, :white_list, :string
  end
end
