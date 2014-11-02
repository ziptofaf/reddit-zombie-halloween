require 'matrix'
require_relative 'being.rb'
require_relative 'extra.rb'
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class Field
  attr_accessor :map, :zombiesKilled, :singleKills, :doubleKills, :bitten, :huntersDestroyed, :huntersBitten
  def initialize
    @map = Matrix.build(20,20){}
    @singleKills = 0
    @doubleKills = 0
    @bitten =0
    @zombiesKilled = 0
    @huntersDestroyed = 0
    @huntersBitten = 0
  end
  def []=(i, j, x) #easier to write field[x,y] than field.map[x,y]
    @map[i,j]=x
  end

  def [](i,j)
    @map[i,j]
  end

  def beingsCount
    i=0
    @map.each do |object|
      i+=1 if !(object.nil?)
    end
    return i
  end

  def beingsList
    i=0
    beings = Hash.new
    @map.each do |object|
      beings[i] = [object.x, object.y, object.initiative] and i+=1 if !(object.nil?)
    end
    return beings
  end
  def randomFreeSpot
    x = rand(20)
    y = rand(20)
    while !(@map[x,y]).nil?
      x = rand(20)
      y = rand(20)
    end
    return [x,y]
  end
  def beingsByNameCount(name)
    i=0
    @map.each do |object|
      i+=1 if !(object.nil?) and object.name==name
    end
    return i
  end

  def beingsByNameList(name)
    i=0
    beings = Hash.new
    @map.each do |object|
      beings[i] = [object.x, object.y, object.initiative] and i+=1 if !(object.nil?) and object.name==name
    end
    return beings
  end

  def beingsAroundByNameList(x,y, name)
    generic = lockedLocations(x,y)
    return filterByName(name, generic)
  end
  def moveBeing(curr_x, curr_y, new_x, new_y)
    distance = (new_x-curr_x + new_y-curr_y).abs
    #puts distance
    unless (@map[new_x, new_y].nil? and !(@map[curr_x, curr_y].nil?)) and distance<=2#making sure we arent overwriting something and that we are moving existing being
      #puts "nope! - move from #{curr_x},#{curr_y} to #{new_x},#{new_y} is not permitted"
      return false #not moving anywhere!
    end
    @map[new_x, new_y]=@map[curr_x, curr_y]
    @map[curr_x, curr_y]=nil
    @map[new_x,new_y].x = new_x
    @map[new_x,new_y].y = new_y
    return true
  end

  def changeState(x,y, new_state)
    if (@map[x,y].nil?)
      puts "invalid action"
      return false
    end
      if (@map[x,y].name=="hunter") #this shouldnt be used if you have modified creatures such as dreadnoughts on the field
        @huntersBitten+=1
      end
    @map[x,y]=new_state
    if new_state.nil?
      return true
    end
      @map[x,y].x=x #just in case
      @map[x,y].y=y
    return true
  end

  def freeLocations(x, y) #list of only valid locations
    all = adjacentLocations(x,y)
    free = Hash.new
    i=0
    all.keys.each do |key|
      curr_x = all[key][0]
      curr_y = all[key][1]
      free[i] = all[key] and i+=1 if curr_x>=0 and curr_y>=0 and curr_x<=19 and curr_y<=19 and @map[curr_x, curr_y].nil?
    end
    return free
  end
  def lockedLocations(x,y) #list of locations that are already inhabited by something
    all = adjacentLocations(x,y)
    locked = Hash.new
    i=0
    all.keys.each do |key|
    curr_x = all[key][0]
    curr_y = all[key][1]
    locked[i] = all[key] and i+=1 if curr_x>=0 and curr_y>=0 and curr_x<=19 and curr_y<=19 and !(@map[curr_x, curr_y].nil?)
    end
    return locked
  end
  private
  def adjacentLocations(x, y) #list of all valid and invalid locations that are close
    locations = Hash.new
    locations[0] = [x-1, y-1]
    locations[1] = [x-1, y]
    locations[2] = [x-1, y+1]
    locations[3] = [x, y-1]
    locations[4] = [x, y+1]
    locations[5] = [x+1, y-1]
    locations[6] = [x+1, y]
    locations[7] = [x+1, y+1]
    return locations
  end

  def filterByName(name, area)
    filtered = Hash.new
    area = area.values
    i=0
    area.each do |position|
      object = @map[position[0], position[1]]
      filtered[i] = [object.x, object.y] and i+=1 if object.name == name
    end
    return filtered
  end
end

def textGame(n, field) #doesnt include initiative values so hunters have pretty much 50/50 chance of killing zombie before they get eaten
  n.times do |i|
    puts "--------------------------------"
    puts "turn #{i+1}"
    beings = field.beingsList.values
    beings.each do |being|
      x = being[0]
      y = being[1]
      next if field[x,y].nil? #might have been exterminated by the hunter
      moveTo = field[x,y].chooseMove(field)
      field.moveBeing(x, y, moveTo[0], moveTo[1])
      field[moveTo[0],moveTo[1]].doAction(field)
    end
  end
  puts "\nResult: "
  puts "Zombies: #{field.beingsByNameCount("zombie")}"
  puts "Victims: #{field.beingsByNameCount("victim")}"
  puts "Hunters: #{field.beingsByNameCount("hunter")}"
  puts "Total bitten: #{field.bitten}"
  puts "Zombies killed: #{field.zombiesKilled}"
  puts "Hunters killed: #{field.huntersDestroyed}"
  puts "Hunters bitten: #{field.huntersBitten}"
  puts "Single kills: #{field.singleKills}"
  puts "Double kills: #{field.doubleKills}"
end



def generateBeing(beingClass, field, howMany=1)
  howMany.times do
    freeSpot = field.randomFreeSpot
    x=freeSpot[0]
    y=freeSpot[1]
    field[x,y] = beingClass.new(x,y)
  end
end
