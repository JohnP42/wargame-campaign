class Campaign < ActiveRecord::Base

	has_many :users, -> { order 'id' }
	belongs_to :map

	validates :name, presence: true
	validates :description, presence: true
	validates :map, presence: true

	def players_invited
		self.white_list.split(".").map { |username| User.find_by(username: username) }
	end

	def start
		self.turn = rand(self.users.length)
		locs = self.map.castle_locations.shuffle

		self.users.each_index do |i|
			self.users[i].battalions.destroy_all
			self.users[i].gold = 100
			loc = locs.pop
			self.users[i].battalions.create!(Battalion.initialize_building(loc[0], loc[1]))
		end
		self.add_gold
		self.save
	end

	def next_turn
		if self.turn < self.users.length - 1
			self.turn += 1
		else
			self.turn = 0
		end
		self.add_gold
		self.save
	end

	def players_turn
		self.users[self.turn]
	end

	def add_gold
		self.players_turn.battalions.each { |b| self.players_turn.gold += 100 if b.type == "castle" || b.type == "town"}
		self.players_turn.save
	end

	def to_html_table
		html = ""

		self.map.tileset.split("n").each_with_index do |row, y|
			html += "<tr>"
			row.chars.each_with_index do |num, x|
				icon = ""
				b = get_battalion_at_pos(x, y)
				if b
					icon = "<div id='icon#{b.id}' class='icon #{eval(b.data)[:type]}#{self.users.index(b.user)}'>#{b.total_units}</div>"
				end

				html += "<td width='32px' height='32px' class='tile#{num}'>#{icon}</td>"
			end
			html += "</tr>"
		end

		html
	end

	def get_battalion_at_pos(x, y)
		all_battalions.each do |battalion|
			return battalion if battalion.x == x and battalion.y == y
		end
		nil
	end

	def get_battalions_at_pos(x, y)
		battalions = []
		all_battalions.each do |battalion|
			battalions << battalion if battalion.x == x and battalion.y == y
		end
		battalions
	end

	def all_battalions
		battalions = []
		self.users.each do |user|
			battalions.concat(user.battalions)
		end
		battalions
	end

	def reset_battalion_movment()
		all_battalions.each do |battalion|
			battalion.update_attributes(movement: 4.0);
		end
	end

	def all_battles
		battles = []
		all_battalions.each do |battalion|
			battle = get_battalions_at_pos(battalion.x, battalion.y).map {|b| b.id}
			battles << battle if battle.length > 1 && !battles.include?([battle[1], battle[0]]) && !battles.include?([battle[0], battle[1]])
		end
		battles
	end

	def battle_select_options(battle)
		[[Battalion.find(battle[0]).user.username, 0], [Battalion.find(battle[1]).user.username, 1]]
	end

end
