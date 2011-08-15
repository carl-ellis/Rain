# Copyright 2010 Carl Ellis, Stephen Wattam
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Add a new method to the Integer class, for convenience
class Integer

  # Returns true if the number is even
	def even?
		return (self == (self >> 1 << 1))
	end
end

class WeakPlasmoid

  # Creates the array and initilaises with a mid number
  def createArray(array, length)

    # Initialise rows
    array = Array.new(length, 0)

    # Initialise columns
    (0 ... array.length).each { |index|  
      array[index] = Array.new(length, 0)
    }
    
    return array
  end

  # Calculates the offset of an average value to add to the terrain.
  # Roughly follows Rand(-x, x) where x is defined as:
  #          range * ( level * 2^-H )
  #   Where:
  #       H is the level of roughness 0 < H < 1
  #
  # @param  level     Level of calculation
  #
  # @returns          Offset to average
  def calculateOffset(level, range, h)

    # Calculate offset
    #offsetbounds = (level > 0) ?  range * (2 ** (-h * level-1)) : range
    #offset = (rand() * 2 * offsetbounds) - offsetbounds

    #return offset
		# Define bounds in terms of level and a roughness
      # function
      multiplier = 2 ** (-h * level-1)

      # Perform random function, bound it, and then apply 
      # multiplier
      return (rand() * (range) - (range / 2)) * multiplier
  end

  # Get the corners of an arbitrary square and perform operation
  # on center.
  #
  # @param  array           Array to use
  # @param  topleftIndexX   X index of top left of square
  # @param  topleftIndexY   Y index of top left of square
  # @param  length          Length of the square 
  # @param  level           Level into the calculation
  def processSquare(array, topleftIndexX, topleftIndexY, length, level, range, h)

    #adjust
    #length -= 1

    # Get coordinates of the corners of the square
    toprightIndexX    = topleftIndexX
    toprightIndexY    = topleftIndexY + length + ((level == 0) ? -1 : 0)

    bottomleftIndexX  = topleftIndexX + length + ((level == 0) ? -1 : 0)
    bottomleftIndexY  = topleftIndexY

    bottomrightIndexX = topleftIndexX + length + ((level == 0) ? -1 : 0)
    bottomrightIndexY = topleftIndexY + length + ((level == 0) ? -1 : 0)

    middleX           = topleftIndexX + (length)/2
    middleY           = topleftIndexY + (length)/2

    #puts "topleft: (" + topleftIndexX.to_s + "," + topleftIndexY.to_s + ")"
    #puts "topright: (" + toprightIndexX.to_s + "," + toprightIndexY.to_s + ")"
    #puts "bottomright: (" + bottomrightIndexX.to_s + "," + bottomrightIndexY.to_s + ")"
    #puts "bottomleft: (" + bottomleftIndexX.to_s + "," + bottomleftIndexY.to_s + ")"
    #puts "middle: (" + middleX.to_s + "," + middleY.to_s + ")"

    # Get values
    topleftValue      = array[topleftIndexX][topleftIndexY]
    toprightValue     = array[toprightIndexX][toprightIndexY]
    bottomleftValue   = array[bottomleftIndexX][bottomleftIndexY]
    bottomrightValue  = array[bottomrightIndexX][bottomrightIndexY]

    # Get average
    average = (topleftValue + toprightValue + bottomleftValue + bottomrightValue)/4

    # Set new value
    array[middleX][middleY] = average + calculateOffset(level, range, h)
  end 

  # Get the edges of an arbitrary diamond and perform operation
  # on center
  #
  # @param  array           Array to use
  # @param  topIndexX       X index of top of diamond
  # @param  topIndexY       Y index of top of diamond
  # @param  length          Length of diamond
  # @param  level           Level into the calculation
  def processDiamond(array, topIndexX, topIndexY, arraylength, level, range, h)

    # Adjust
    arraylength -= 1
    length = arraylength/(2 ** level)
    #offset = (level == 0) ? 1 : 0

    #Get coordinates of the diamond
    rightIndexX   = topIndexX + length/2
    rightIndexY   = (topIndexY == length) ? length/2 : topIndexY + length/2 

    leftIndexX    = topIndexX + length/2
    leftIndexY    = (topIndexY == 0) ? arraylength - length/2 : topIndexY - length/2

    bottomIndexX  = (topIndexX + length/2 == arraylength) ? length/2 : topIndexX + length
    bottomIndexY  = topIndexY

    middleX       = topIndexX + length/2
    middleY       = topIndexY

    # Get values
    topValue      = array[topIndexX][topIndexY]
    rightValue    = array[rightIndexX][rightIndexY]
    bottomValue   = array[bottomIndexX][bottomIndexY]
    leftValue     = array[leftIndexX][leftIndexY]

    # Get average
    average = (topValue + rightValue + bottomValue + leftValue)/4

    # Set new value
    array[middleX][middleY] = average + calculateOffset(level, range, h)

    # Wraps
    if(middleX == arraylength)
      array[0][middleY] = array[middleX][middleY]
    end
    if(middleY == 0)
      array[middleX][arraylength] = array[middleX][middleY]
    end
    
  end

  # The main control loop for the algorithm.
  #
  # @param  lengthExp       Length exponent
  # @param  range           Value range
  # @param  h               Roughness constant
  def generateTerrain(lengthExp, range, h)

    length = (2 ** lengthExp) + 1

    array = Array.new
    array = createArray(array, length)

    #Go through Levels (irerative recursion)
    (0 .. lengthExp - 1).each{ |level|

      #puts "[Level] : " + level.to_s
      # Iterator for the Square part of the algorithm
      # Will go through the x-axis coords
      (0 .. (2 ** level) -1 ).each { |sqx|

        # Y axis coords
        (0 .. (2 ** level) -1).each { |sqy|

          gap = length/2 ** level
          x = (0 + (gap*sqx))
          y = (0 + (gap*sqy))

          #puts "[" + x.to_s + ", " + y.to_s + "]"
          processSquare(array, x, y, gap, level, range, h)
        }
      }

      # Iterator for the diamond part of the algorithm
      (0 ... (2 ** (level+1))).each { |dix|

        # Offset in the number of points on the y-axis. Dependant
        # on if x iteration is even or odd.
        offset = (dix.even?) ? 1 : 2
        (0 ... (2 ** (level+1)/2)).each { |diy|

          gap = (length/2 ** (level+1))
          ygap = 2 * gap

          x = (0 + (gap*dix))
          if (dix.even?)

            y = 0 + (ygap*diy)
          else

            y = gap + (ygap*diy)
          end
          #puts "[" + x.to_s + ", " + y.to_s + "]: " + length.to_s
          processDiamond(array, x, y, length, level, range, h)
        }
      }
    }
    return array

  end

  # Outputs the value array in ASCII format, using VT100 color codes.
  #
  # @param  array           Value array
  # @param  range           Value range
  def outputArrayASCII(array, range)

    # Output in a color that is dependent on being within a certain bound.
    array.each { |subArray|
      outStr = String.new
      subArray.each { |element|
        if element <= -4 * (range/5)
          outStr << "[1;30;44m#[0m"
        elsif element <= -3 * (range/5)
          outStr << "[1;34;44m#[0m"
        elsif element <= -2 * (range/5)
          outStr << "[1;36;44m#[0m"
        elsif element <= -1 * (range/5)
          outStr << "[1;36;46m#[0m"
        elsif element <= 0 * (range/5)
          outStr << "[1;33;43m#[0m"
        elsif element <= 1 * (range/5)
          outStr << "[2;32;43m#[0m"
        elsif element <= 2 * (range/5)
          outStr << "[2;42;32m#[0m"
        elsif element <= 3 * (range/5)
          outStr << "[2;41;32m#[0m"
        elsif element <= 4 * (range/5)
          outStr << "[2;41;31m#[0m"
        else
          outStr << "[2;41;37m#[0m"
        end
      }
      puts outStr
    }
  end

  # Outputs a raw version of the array, showing just the values
  #
  # @param  array           Value array
  def outputArrayRAW(array)

    array.each { |subArray|
      outStr = String.new
      subArray.each { |element|
        outStr << element.to_s + " "
      }
      puts outStr
    }
  end

  # Removes any outliers, scales down the variance of the values and then 
  # shifts the range to unsigned values
  #
  # @param  array           Value array
  # @param  limit           [optional] Max value, default = 255
  #
  # @return                 Normalised array
  def normaliseArray(array, limit = 255.0)
    
    min = array.flatten.min
    max = array.flatten.max
    minmax = max - min
    multiplier = limit/minmax.to_f


    (0 ... array.length).each { |x|
      (0 ... array[x].length).each { |y|
        
        array[x][y] = ((array[x][y] - min)*multiplier).to_f
      }
    }
    return array
  end

	def initialize
	end

end

#########################################################################
# Driver                                                                #
#########################################################################

# Create object
#wp = WeakPlasmoid.new

# Map of 2^7 by 2^7, range -128 to 128, h=0.8
#array = wp.generateTerrain(7, 128, 0.8)

##Ascii output
#########################################################################

#wp.outputArrayASCII(array, 256)

