class Dreadnought < Zombie
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "zombie"
    @image = "graphics/dread.jpg"
    @initiative = 5
  end
  def doAction(field)
    hunters = singleTarget("hunter", field)
    return false if hunters.count==0 #no hunters detected
    if hunters.count==1
      x = hunters[0][0]
      y = hunters[0][1]
      puts "HUNTER detected at #{x},#{y} - I SHALL EAT YOUR SKULL"
      field.changeState(x,y, nil)
      field.huntersDestroyed+=1
    else
      hunter1 = rand(hunters.count)
      x = hunters[hunter1][0]
      y = hunters[hunter1][1]
      puts "I smell a hunter at #{x},#{y} - OBLITERATION"
      field.changeState(x,y, nil)
      hunters = hunters - [hunters[hunter1]]
      hunter1 = rand(hunters.count)
      x = hunters[hunter1][0]
      y = hunters[hunter1][1]
      puts "Another scum hides nearby, at #{x},#{y} - EASY. TOO EASY."
      field.changeState(x,y, nil)
      field.huntersDestroyed+=2
    end
    return true
  end

end

class Spawncrawler < Zombie
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "zombie"
    @image = "graphics/spawn.jpg"
    @initiative = 0
  end
  def doAction(field)
    chance = rand
    if chance>0.8

      area = field.freeLocations(@x,@y)
      return false if area.count==0
      choice = rand(area.count)
      x = area[choice][0]
      y = area[choice][1]
      if rand>0.5
      field[x, y] = Dreadnought.new(x, y)
      puts "Arise my defender! - #{x},#{y}"
      else
      field[x, y] = Zombie.new(x, y)
      puts "Go feast on their souls! - #{x},#{y}"
      end
      return true
    end
    return false
  end
end

class Sniper < Hunter
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "hunter"
    @image = "graphics/sniper.jpg"
    @initiative = 9
  end
  def doAction(field)
      targets = field.beingsByNameList("zombie")
      return false if targets.count==0
      chooseOne = rand(targets.count)
      target = targets[chooseOne]
      x = target[0]
      y = target[1]
      distance = (@x-x + @y-y).abs
      accuracy = 1.0/(distance*1.15)*100 #gets lower as the distance grows, obvious
      if rand*100 <= accuracy #eg. accuracy - 95, rand - 50 = hit. Or accuracy -5, rand - 50, miss
      field.changeState(x,y, nil)
      puts "Target down at #{x},#{y} from #{@x},#{@y}"
      field.zombiesKilled+=1
      return true
      end
        #puts "Target missed at #{x},#{y} from #{@x},#{@y}"
        return false
  end
end


class Cthughan < Zombie #transforms everyone around him into zombie
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "zombie"
    @image = "graphics/cthughan.jpg"
    @initiative = 2
  end
  def doAction(field)
    targets = ["victim", "hunter"]
    merged = multiTarget(targets, field)
    return false if merged.count==0
    merged.values.each do |being|
      puts "Oups, I was just passing"
      x = being[0]
      y = being[1]
      field.changeState(x,y, Zombie.new(x,y))
    end
  end
end

class ArmsDealer < Hunter
  def initialize(x=0, y=0)
    @x=x
    @y=y
    @name = "hunter"
    @image = "graphics/arms.jpg"
    @initiative = 1
  end
  def chooseMove(field) #ArmsDealers dont move unless threatened by Zombies
    amISafe = field.beingsAroundByNameList(@x,@y, "zombie")
    if !(amISafe.empty?)
    super
    else
    return [@x, @y]
    end
  end

  def doAction(field) #Sells weapons to victims turning them into Hunters/Snipers
    target = singleTarget("victim", field)
    return false if target.count==0
    chooseOne = rand(target.count)
    chosen = target[chooseOne]
    x = chosen[0]
    y = chosen[1]
    if rand<0.9
    puts "AK-47 for eveeeryooone"
    field.changeState(x,y, Hunter.new(x, y))
    else
    puts "Selling some M40 to #{x},#{y}"
    field.changeState(x,y, Sniper.new(x, y))
    end
  end
end
