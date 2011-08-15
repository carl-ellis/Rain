require 'gosu'
require 'texplay'
require './map.rb'
require './lib/WeakPlasmoid.rb'
require './agent.rb'
require './source_agent.rb'
require './agent_manager.rb'

SIZE_EXP = 7
SIZE = 2**SIZE_EXP
NUM_AGENTS =2
H = 0.4

EVA_RATE = 0
RAIN_RATE = 360
BUCKET = SIZE*SIZE

# Renderer, also handles the rain and evaporation functions when they are on

class GameWindow < Gosu::Window
	
	attr_accessor :m, :agents, :i

  def initialize(m, agents)
    super SIZE, SIZE, true
    self.caption = "Rain"
		@m = m
		@agents = agents
		@eva = []
		@i = 0
		@eva_on = true

		puts "Initialising render"

		# Create the images to be rendered
		@background = TexPlay.create_image(self, SIZE, SIZE, :color => :none)
		@image = TexPlay.create_image(self, SIZE, SIZE, :color => :none)
		@background.fill 0, 0, :color_control => proc { |c, x, y|
            @m.tiles[x][y].colour
        }
		@agents.agents << SourceAgent.new(@agents,@m,rand(SIZE),rand(SIZE), BUCKET) 
		puts "Done Initialising render"
  end

	def button_down(id)
		case id
			when Gosu::KbEscape
 				#Exit
				close
			when Gosu::KbEnter	
			when Gosu::KbReturn	
			  # Create a water source
				1.times { @agents.agents << SourceAgent.new(@agents,@m,rand(SIZE),rand(SIZE), BUCKET)}
			when Gosu::KbR
			  # 20 water agents, rain
				20.times { @agents.agents << HeightAgent.new(@agents,@m,rand(SIZE),rand(SIZE))}
			when Gosu::KbD
			  # Drench, puts a water agent on EVERY SQUARE
				(0...SIZE).each { |x|
					(0...SIZE).each { |y|
						@agents.agents << HeightAgent.new(@agents,@m,x,y)
					}
				}
			when Gosu::KbE
				@eva_on = !@eva_on
		end
	end

  def update
	  # for restricting actions to certain ticks
		@i +=1
			# Draw water
			@agents.agents.each do |a| 
				@eva << a.tile
				if a.update
					@image.pixel a.tile.x, a.tile.y, :color => [0,0,1,0.3]
				else
					@agents.agents.delete(a)
				end
			end
 			# Evaporate
			if @eva_on
				(EVA_RATE).times do 
					t = @eva[rand(@eva.length)]
					if !t.nil? 
						if t.agents.length == 0
							@image.pixel t.x, t.y, :color => [0,0,0,0]
						end
					end
					@eva.delete(t)
				end
			end
			if (i%RAIN_RATE) == 0
 			#rain
				i = 0
				EVA_RATE.times { @agents.agents << HeightAgent.new(@agents,@m,rand(SIZE),rand(SIZE))}
			end
  end

  def draw
		@background.draw(0,0,1)
		@image.draw(0,0,4)
  end
end


# Gen tiles
puts "Creating tiles"
m = Map.new(SIZE, SIZE)

#Gen height data
puts "Creating terrain"
wp = WeakPlasmoid.new
attr_data = wp.generateTerrain(SIZE_EXP, 128, H)
# This is to lower the height resolution, abit of a hack to be honest
attr_data.each { |a| 
	(0...SIZE).each {|i| a[i] = a[i].to_i/1.5*1.5.to_f } 
	}
attr_data = wp.normaliseArray(attr_data, 1)
m.apply_attribute("height", attr_data, 0, 0)

puts "Colouring tiles"
#Gen colour data
colour_func = lambda { |tile|
									if tile.agents.length == 0
										colour_value = tile.attributes["height"]
										#array = [colour_value, colour_value, colour_value, 1]  
										array = [0, colour_value, 0, 1]  
									else
										array = [0.0, 0.0, 1.0, 1]  
									end
									return array }
m.apply_colour_lambda(colour_func)									

# agents
am = AgentManager.new

# render
puts "Rendering tiles"
window = GameWindow.new(m, am)
window.show
puts window.i
