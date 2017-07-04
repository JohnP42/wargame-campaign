class Battalion < ActiveRecord::Base

	belongs_to :user

	validates :user, presence: true
	validates :data, presence: true
	validates :x, presence: true
	validates :y, presence: true

	BUILDING_PRICES = {
		barracks1: 100,
		barracks2: 300,
		barracks3: 500,
		stables1: 100,
		stables2: 300,
		stables3: 500,
		workshop1: 100,
		workshop2: 300,
		workshop3: 500,
		secret1: 100,
		secret2: 300,
		secret3: 500,
		misc1: 100,
		misc2: 300,
		misc3: 500,
		defense_tower1: 200,
		defense_tower2: 400,
		defense_tower3: 600,

	}

	def self.initialize_building(x, y, type="castle", units={})
		data = { type: type, units: units, buildings: type=="castle" ? [:barracks1, :stables1] : [] }
		return {data: data.to_s, x: x, y: y, is_building: true}
	end

	def self.initialize_unit(x, y, units)
		data = { type: "unit", units: units, buildings: [] }
		return {data: data.to_s, x: x, y: y, is_building: false, movement: 2.0}
	end

	def data_hash
		eval(self.data)
	end

	def type
		data_hash[:type]
	end

	def units
		data_hash[:units]
	end

	def add_unit(unit_id)
		units = self.units
		if units[unit_id]
			units[unit_id] += 1
		else
			units[unit_id] = 1
		end
		data_hash = self.data_hash
		data_hash[:units] = units
		self.data = data_hash.to_s
		self.save
	end

	def add_units(unit_id, count)
		units = self.units
		if units[unit_id]
			units[unit_id] += count
		else
			units[unit_id] = count
		end
		data_hash = self.data_hash
		data_hash[:units] = units
		self.data = data_hash.to_s
		self.save
	end

	def remove_units(unit_id, count)
		units = self.units
		units[unit_id] -= count
		units.delete(unit_id) if units[unit_id] <= 0
		data_hash = self.data_hash
		data_hash[:units] = units
		self.data = data_hash.to_s
		self.save
	end

	def buildings
		data_hash[:buildings]
	end

	def add_building(building)
		buildings = self.buildings
		buildings << building
		data_hash = self.data_hash
		data_hash[:buildings] = buildings
		self.data = data_hash.to_s
		self.save
	end

	def buildable
		BUILDING_PRICES.select do |building, cost|
			!self.buildings.include?(building) && can_buy_building(building)
		end
	end

	def can_buy_building(building)
		building[-1] == "1" || self.buildings.include?("#{building[0, building.length - 1]}#{(Integer(building[-1]) - 1)}".to_sym)
	end

	def trainable
		self.user.current_army.units.select do |unit|
			if unit.combatType == "Infantry"
				self.buildings.include?("barracks#{unit.tier}".to_sym)
			elsif unit.combatType == "Cavalry"
				self.buildings.include?("stables#{unit.tier}".to_sym)
			elsif unit.combatType == "Artillery"
				self.buildings.include?("workshop#{unit.tier}".to_sym)
			else
				self.buildings.include?("secret#{unit.tier}".to_sym)
			end
		end
	end

	def can_move(direction, campaign)
    return false if self.is_building
		return case direction
		when "Up"
			self.movement >= campaign.map.move_cost(self.x, self.y - 1) && self.pos_valid?(self.x, self.y - 1, campaign.map.width, campaign.map.height)
		when "Right"
			self.movement >= campaign.map.move_cost(self.x + 1, self.y) && self.pos_valid?(self.x + 1, self.y, campaign.map.width, campaign.map.height)
		when "Down"
			self.movement >= campaign.map.move_cost(self.x, self.y + 1) && self.pos_valid?(self.x, self.y + 1, campaign.map.width, campaign.map.height)
		when "Left"
			self.movement >= campaign.map.move_cost(self.x - 1, self.y) && self.pos_valid?(self.x - 1, self.y, campaign.map.width, campaign.map.height)
		end
	end

	def move(direction, campaign, admin = false)
		case direction
		when "Up"
			x = self.x
			y = self.y - 1
		when "Right"
			x = self.x + 1
			y = self.y
		when "Down"
			x = self.x
			y = self.y + 1
		when "Left"
			x = self.x - 1
			y = self.y
    end

		other_battalion = campaign.get_battalion_at_pos(x, y)

		if other_battalion
			if (other_battalion.user.id == self.user.id)
				self.units.each { |unit_id, count| other_battalion.add_units(unit_id, count) }
				other_battalion.movement = self.movement - campaign.map.move_cost(x, y) unless admin
				other_battalion.save
				self.destroy
				return other_battalion
			else

				others = campaign.get_battalions_at_pos(x, y)
				if others.length > 1
					others.each do |b|
						if b.user.id == self.user.id
							self.units.each { |unit_id, count| b.add_units(unit_id, count) }
              self.movement -= campaign.map.move_cost(x, y) unless admin
							b.movement = b.movement < self.movement ? b.movement : self.movement
							b.save
							self.destroy
							return b
						end
					end
				else
					self.x = x
					self.y = y
					self.movement -= campaign.map.move_cost(x, y) unless admin
					self.movement = 0.0 if (other_battalion.total_units * 4 >= self.total_units) unless admin
					self.save
					return self
				end
			end
		else
			self.x = x
			self.y = y
			self.movement -= campaign.map.move_cost(x, y) unless admin
			self.save

			building = campaign.map.building_at(x, y)
			if building
				data = Battalion.initialize_building(x, y, building, self.units)
				self.update_attributes(data)
			end

			return self
		end
	end

	def possible_moves(campaign)
		moves = []

		moves << ["Up", "#{self.x},#{self.y - 1}"] if (self.pos_valid?(self.x, self.y - 1, campaign.map.width, campaign.map.height) && campaign.map.tile_at(self.x, self.y - 1) != "3" )
		moves << ["Right", "#{self.x + 1},#{self.y}"] if (self.pos_valid?(self.x + 1, self.y, campaign.map.width, campaign.map.height) && campaign.map.tile_at(self.x + 1, self.y) != "3")
		moves << ["Down", "#{self.x},#{self.y + 1}"] if (self.pos_valid?(self.x, self.y + 1, campaign.map.width, campaign.map.height) && campaign.map.tile_at(self.x, self.y + 1) != "3")
		moves << ["Left", "#{self.x - 1},#{self.y}"] if (self.pos_valid?(self.x - 1, self.y, campaign.map.width, campaign.map.height) && campaign.map.tile_at(self.x - 1, self.y) != "3")
		moves
	end

	def pos_valid?(x, y, limx, limy)
		return (x >= 0 && x < limx && y >= 0 && y < limy)
	end

	def total_units
		count = 0
		self.units.each { |unit_id, c| count += c }
		count
	end

end
