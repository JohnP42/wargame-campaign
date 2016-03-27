class Army < ActiveRecord::Base

	has_many :units
	belongs_to :user

	validates :name, presence: true
	validates :description, presence: true
	validates :is_current, default: false

end
