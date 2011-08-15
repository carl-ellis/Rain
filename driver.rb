require './map.rb'
require './lib/WeakPlasmoid.rb'

m = Map.new(128, 128)

wp = WeakPlasmoid.new
attr_data = wp.generateTerrain(7, 128, 0.8)

m.apply_attribute("height", attr_data, 0, 0)

p m.tiles[5][7]
