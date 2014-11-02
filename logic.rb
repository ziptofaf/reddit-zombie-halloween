require_relative 'field.rb'
class GraphicalBoard
  attr_accessor :field, :positionOfAll
def initialize(args)
  @positionOfAll = Array.new
  @field = Field.new
  generateBeing(Zombie, @field, args[0])
  generateBeing(Hunter, @field, args[1])
  generateBeing(Victim, @field, args[2])
  generateBeing(Cthughan, @field, args[3])
  generateBeing(ArmsDealer, @field, args[4])
  generateBeing(Sniper, @field, args[5])
  generateBeing(Spawncrawler, @field, args[6])
end
def coordTrans(number) #transform coordinate to map values
  return 45*number #900x900 map compared to 20x20 matrix
end
def moveAll
  @positionOfAll = Array.new #lets empty it beforehand
  beings = @field.beingsList.values
  i=0
  beings.each do |being|
    x = being[0]
    y = being[1]
    next if @field[x,y].nil? #might have been exterminated by the hunter
    moveTo = @field[x,y].chooseMove(field)
    @field.moveBeing(x, y, moveTo[0], moveTo[1])
    refr = @field[moveTo[0], moveTo[1]] #this returns post-movement creature
    @positionOfAll[i]=[coordTrans(refr.x), coordTrans(refr.y), refr.image] #and now we add it to our array
    i+=1
  end
end

def actionAll
  @positionOfAll = Array.new #lets empty it beforehand
  beings = @field.beingsList.values.sort_by { |k| k[2] }.reverse #lets sort our beings by their initiative
  beings.each do |being|
    x = being[0]
    y = being[1]
    next if @field[x,y].nil? #might have been exterminated by the hunter
    @field[x,y].doAction(field)
  end

  i=0
  refreshed = @field.beingsList.values
  refreshed.each do |being|
    x = being[0]
    y = being[1]
    refr = @field[x,y]
    @positionOfAll[i]=[coordTrans(refr.x), coordTrans(refr.y), refr.image]
    i+=1
  end
end

end
