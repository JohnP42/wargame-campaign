class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :username, unique: true, null: false
    	t.string :email, unique: true, null: false
    	t.string :password_digest
    	t.belongs_to :campaign, index: true
    	t.integer :gold, default: 0
      t.timestamps null: false
    end
  end
end
