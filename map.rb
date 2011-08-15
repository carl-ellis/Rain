require './tile.rb'

# Map class, manages a set of tiles
class Map

	attr_accessor :tiles

	# Initialises a tileset given a width and height
	def initialize(width, height)

		# Initialise the tileset
		@tiles = []
		(0...width).each do |x|
			@tiles[x] = []
			(0...height).each do |y|
				@tiles[x][y] = Tile.new(x, y, self)
			end
		end
	end

	# Apply a chink of attribute data to a block of tiles
	def apply_attribute(attr_key, attr_data, offsetx, offsety)
		
		# avoid edges with minimums
		(offsetx...[@tiles.length,attr_data.length].min).each do |x|
			(offsety...[@tiles[x].length, attr_data[x].length].min).each do |y|
				@tiles[x][y].attributes[attr_key] = attr_data[x - offsetx][y-offsety]
			end
		end
	end

	# Applies a lambda to each tile to determine it's color
	def apply_colour_lambda(lamb)
		tiles.each { |a| a.each { |t| t.colourfunc = lamb } }
	end

	# returns a set of neighbours which satisfy the lambda
	def get_neighbours_by_lambda(agent, lamb)
		tile = agent.tile
		min_x = [0,tile.x-1].max
		max_x = [@tiles.size-1, tile.x+1].min
		min_y = [0,tile.y-1].max
		max_y = [@tiles.size-1, tile.y+1].min

		tile_array = []
		(min_x..max_x).each do |x|
			(min_y..max_y).each do |y|
			 if x != tile.x || y != tile.y 
				 if !@tiles[x][y].nil?
					t = lamb.call(@tiles[x][y], agent) 
					tile_array << t if !t.nil?
					end
				end
			end
		end
		return tile_array
	end
end
