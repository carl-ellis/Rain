require './agent.rb'

# spawns water agents
class SourceAgent < HeightAgent

  # How many to spawn
	SPAWN_RATE = 1

	attr_accessor :drops,:d

	def initialize(agentlist, map, x, y, drops)
		super(agentlist, map, x, y)
		@drops = drops
	end

	def update
		if @drops > 1
			SPAWN_RATE.times {
				a = HeightAgent.new(@agentlist, @map, @tile.x, @tile.y)
				a.set_source(self)
				@agentlist.agents << a
			}
			update_heights
			@drops -= SPAWN_RATE
			puts @drops if @drops < 1
		end
		return true
	end
end
