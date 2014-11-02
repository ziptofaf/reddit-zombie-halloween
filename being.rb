class Being
  attr_accessor :x, :y, :name, :image, :initiative
  def currentPosition
    puts "#{@x} #{@y}"
  end

  def doAction(field) #overload
    return true
  end

  def chooseMove(field)
    zones = filterLocations(field.freeLocations(@x, @y))
    if zones.empty? #only if no moves are possible return current position
      return [@x, @y]
    end
    move = rand(zones.count)
    return zones[move]
  end

  def filterLocations(freeLocations) #overload for zombies, feed it freeLocations from Field class
    return freeLocations
  end

  def initialize(x=0,y=0)
    @x=x
    @y=y
    @name = "unknown"
    @image = "graphics/unknown.jpg"
    @initiative = 1
  end
  def multiTarget(arrayOfStrings, field) #many creatures can have multiple target types to attack/concert/run away from, returns Hash with indices 0..n and values x,y
    targets = Hash.new
    i=0
    arrayOfStrings.each do |string|
      curr_target = field.beingsAroundByNameList(@x,@y, string).values
      curr_target.each do |list|
          targets[i] = list
          i+=1
        end
    end
    return targets
  end
  def singleTarget(string, field)
    return field.beingsAroundByNameList(@x,@y, string).values #returns table of tables , eg. [[3, 5], [4, 1], [x,y]]
  end
end

class Victim < Being
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "victim"
    @image = "graphics/victim.jpg"
    @initiative = 1
  end

  def chooseMove(field)
    amISafe = field.beingsAroundByNameList(@x,@y, "zombie")
    if !(amISafe.empty?)
    super
    else
    return [@x, @y]
    end
  end
end

class Zombie < Being

  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "zombie"
    @image = "graphics/zombie.jpg"
    @initiative = 1
  end

  def filterLocations(freeLocations)
    postFilter = Hash.new
    preFilter = freeLocations.values #changing hash to array
    i=0
    preFilter.each do |entry|
      x1 = entry[0]
      y1 = entry[1]
      (postFilter[i]=entry and i+=1) unless (@x!=x1 and @y!=y1) #zombies cant do crosswise moves
    end
    return postFilter
  end

  def filterAttackLocations(locations)
    filteredArea = Hash.new
    i = 0
    locations.values.each do |location|
      x1 = location[0]
      y1 = location[1]
      (filteredArea[i]=location and i+=1) unless (@x!=x1 and @y!=y1) #zombies cant do crosswise moves, this code looks retarded but works
    end
    return filteredArea
  end

  def doAction(field)
    targets = ["victim", "hunter"]
    merged = filterAttackLocations(multiTarget(targets,field))
    return false if merged.count==0
    chooseOne = merged[rand(merged.count)]
    puts "Braaaaaaains at #{chooseOne[0]},#{chooseOne[1]}"
    zombie = Zombie.new(chooseOne[0], chooseOne[1])
    field.changeState(chooseOne[0], chooseOne[1], zombie)
    field.bitten=field.bitten+1
    return true
  end
end


class Hunter < Being
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "hunter"
    @image = "graphics/hunter.jpg"
    @initiative = 5
  end

  def doAction(field)
    zombies = singleTarget("zombie", field)
    #puts zombies.count
    return false if zombies.count==0 #no zombies detected
    if zombies.count==1
      x = zombies[0][0]
      y = zombies[0][1]
      field.changeState(x,y, nil)
      puts "Rest in pieces and suffer hunger no more - at #{x},#{y}"
      field.zombiesKilled = field.zombiesKilled+1
      field.singleKills=field.singleKills+1
    else
      zombie1 = rand(zombies.count)
      x = zombies[zombie1][0]
      y = zombies[zombie1][1]
      field.changeState(x,y, nil)
      puts "You shall be crushed - #{x},#{y}"
      zombies = zombies-[zombies[zombie1]] #eg. [[2,5],[2,4]] - [[2,4]], its array of arrays minus array of arrays
      #puts zombies
      return if zombies.nil?
      zombie1 = rand(zombies.count)
      x = zombies[zombie1][0]
      y = zombies[zombie1][1]
      field.changeState(x,y, nil)
      puts "Your numbers are meaningless - #{x},#{y}"
      field.zombiesKilled=field.zombiesKilled+2
      field.doubleKills=field.doubleKills+1
    end
    return true
  end
end
