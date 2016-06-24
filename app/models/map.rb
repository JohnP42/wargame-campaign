class Map < ActiveRecord::Base

	has_many :campaigns
	belongs_to :user

	validates :name, presence: true
	validates :description, presence: true
	validates :tileset, presence: true
	validate :too_many_castles

	def too_many_castles
		if max_players > 4
			errors.add(:tileset, "can't exceed 4 castles")
		end
	end

	def max_players
  	self.tileset.count('4');
 	end

	def to_html_table
		html = ""

		self.tileset.split("n").each do |row|
			html += "<tr>"
			row.chars.each do |num|
				html += "<td width='32px' height='32px' class='tile#{num}'></td>"
			end
			html += "</tr>"
		end

		html
	end

	def width
		self.tileset.split("n")[0].length
	end

	def height
		self.tileset.split("n").length
	end

	def castle_locations
		locations = []

		self.tileset.split("n").each_with_index do |row, y|
			row.chars.each_with_index do |num, x|
				locations << [x, y] if num == "4"
			end
		end
		locations
	end

	def tile_at(x, y)
		self.tileset.split("n")[y][x]
	end
	def move_cost(x, y)
		return case self.tile_at(x, y)
		when "0"
			1.0
		when "1"
			1.3
		when "2"
			2.0
		when "3"
			100.0
		else
			1.0
		end
	end

	def building_at(x, y)
		tile = self.tileset.split("n")[y][x]
		return "castle" if tile == "4"
		return "town" if tile == "5"
		nil
	end

end
