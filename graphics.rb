require 'gosu'
require_relative 'field.rb'
require_relative 'logic.rb'
class GameWindow < Gosu::Window
  def initialize(array, max_turns=500)
    super 900, 900, false, 500 #glorious 2 fps
    self.caption = "Hunters X Zombies X Victims"
    @x=0
    @y=0
    @odd = true
    @board = GraphicalBoard.new(array)
    @objectsArray = Array.new
    @turns=0
    @max_turns = max_turns
    @to_draw = true
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def arrayToImages(arrayOfAllObjects) #calling it once would probably suffice in 99.9% of the scenarios
    @imageHash = Hash.new
    #puts arrayOfAllObjects
    arrayOfAllObjects.each do |object|
      #puts "does it show?"
      @imageHash[object[2]] ||= Gosu::Image.new(self, object[2], true)
    end
    return @imageHash
  end

  def singleImage(singleObject) #make sure ArrayToImages has been called before, this method returns an image you can use
    image = @imageHash[singleObject[2]]
    return image
  end

  def update #main game loop

    if @turns>=@max_turns
      @to_draw = false
      @results = ["Turns: #{@turns}", "Zombies: #{@board.field.beingsByNameCount("zombie")}",
     "Victims: #{@board.field.beingsByNameCount("victim")}",
     "Hunters: #{@board.field.beingsByNameCount("hunter")}",
     "Total bitten: #{@board.field.bitten}",
     "Zombies killed: #{@board.field.zombiesKilled}",
     "Hunters killed: #{@board.field.huntersDestroyed}",
     "Hunters bitten: #{@board.field.huntersBitten}",
     "Single kills: #{@board.field.singleKills}",
     "Double kills: #{@board.field.doubleKills}"]
     return
    end

    if @odd
      @board.moveAll
      arrayToImages(@board.positionOfAll)
      @objectsArray = @board.positionOfAll
      @odd = false
    else
      @board.actionAll
      arrayToImages(@board.positionOfAll)
      @objectsArray = @board.positionOfAll
      @odd = true
      @turns+=1
    end
  end



  def draw

    if (@to_draw)
      i=45
      #vertical_lines
      20.times do
          draw_line(i,0, Gosu::Color.argb(0xffffffff), i, 900, Gosu::Color.argb(0xffffffff))
          i+=45
      end
      #horizontal_lines
      i=45
      20.times do
          draw_line(0,i, Gosu::Color.argb(0xffffffff), 900, i, Gosu::Color.argb(0xffffffff))
          i+=45
      end
      @objectsArray.each do |object|
        toDraw = singleImage(object)
        toDraw.draw(object[0],object[1],0)
      end
    else
      i=10
      @results.each do |result|
        @font.draw(result, 30, i, 4, 1.0, 1.0, 0xffffff00)
        i+=50
      end
    end
  end
end
