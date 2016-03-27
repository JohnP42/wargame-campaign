require 'bcrypt'

class User < ActiveRecord::Base
	include BCrypt

  has_secure_password

  before_save { self.email = email.downcase }

	belongs_to :campaign
  has_many :maps
  has_many :battalions
	has_many :armies
  has_many :friendships
  has_many :friends, through: :friendships

  validates_format_of :email, with: /@/
  validates :password, length: { within: 8..20 }, on: :create
  validates :username, presence: true, length: { within: 2..32 }, uniqueness: true
  validates :email, uniqueness: { case_sensitive: false}

  def clear_current
    self.armies.each_index do |i| 
      self.armies[i].is_current = false
      self.armies[i].save
    end
  end

  def current_army
    self.armies.each { |army| return army if army.is_current }
  end

  def has_current_army_set?
    self.armies.each { |army| return true if army.is_current }
    false
  end

  def total_buildings
    count = 0
    self.battalions.each { |b| count += 1 if b.type == "castle" || b.type == "town"}
    count
  end

  def first_building
    self.battalions.each { |b| return b if b.type == "castle" || b.type == "town"}
    nil
  end

  def self.search(search)
    where("username LIKE ?", "%#{search}%") 
  end

end
