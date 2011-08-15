require './map.rb'

# Behaves like a bit of water goes mostly down the steepest path
class HeightAgent

	attr_accessor :agentlist, :tile, :map, :waterlevel, :height, :active, :source

  # Extra height this agent adds
	HEIGHT_MOD = 0.01


	# Create the agent
	def initialize(agentlist, map, x, y)
		@agentlist = agentlist
		@tile = map.tiles[x][y]
		@map = map
		@tile.agents << self
		@active = true
    # How neighbours are picked, so if the height is smaller than this height and water level (can rise over bumps)
		@neighbour_logic = lambda { |t1, a| 
														#puts "wl #{ a.height} h #{t1.attributes["height"]}"
														if t1.attributes["height"] <= (a.height + a.waterlevel)
															return t1
														else
															return nil
														end }
		update_heights()
	end

	# update the height parameters
	def update_heights
		@height = @tile.attributes["height"]
		@waterlevel = @tile.agents.length * HEIGHT_MOD 
	end

  # move logic
	def update()
		# Stops the water going higher than its source
		if @active && !@source.nil?
			if (@height+@waterlevel) >= (@source.height + @source.waterlevel)
				@active = false
			end
		end
		if @active
      # Get where it could go
			candidates =  @map.get_neighbours_by_lambda(self, @neighbour_logic)
			if candidates.length > 0
 				# Random point
				#dest = candidates[rand(candidates.length)]
 				# wieghted Lowest point
				candidates.sort! { |a, b| a.attributes["height"] + a.agents.length*HEIGHT_MOD <=> b.attributes["height"] + b.agents.length*HEIGHT_MOD} 
        best_ind = []
				i = 0
				candidates.length.times { 
					(candidates.length-i)*3.times { best_ind << i}
					i += 1
				}
				# Move there
				dest = candidates[best_ind[rand(best_ind.length)]]
				@tile.agents.delete(self)
				@tile = dest
				update_heights()
			else
				if !@source.nil?
					if @source.tile != @tile
						# if this is from a source, set a new one here to keep flowing, but limit water to what is here, as these agents will be culled
						@agentlist.agents << SourceAgent.new(@agentlist, @map, @tile.x, @tile.y, 200) # @tile.agents.length) 
						#@source.active = false
						#puts "s off #{@source}"
					end
				end
				@active = false
			end
		end
	end

	def set_source(source)
		@source = source
	end

	def to_s
		return "h #{@height} wl #{@waterlevel}"
	end
end
