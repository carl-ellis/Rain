# Defines a rile in  map
class Tile

	attr_accessor :x, :y, :map, :attributes, :agents, :colourfunc

	# construct, taking coordinates and parent map
	def initialize(x, y, map)
		@x = x
		@y = y
		@map = map
		@attributes = {}
		@agents = []
	end

	def to_s
		return "#{@x.to_s}:#{@y.to_s} -> #{@attributes.to_s}"
	end

	def colour
		t = @colourfunc.call(self)	
		return t 
	end
end
