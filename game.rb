require_relative 'graphics.rb'

def fillLackingSpots(array) #there are extra classes not defined in the original task so lets make sure they are initialized to zero
  newArray = array
  (7-newArray.count).times do
    array.push(0)
  end
  return newArray
end
window = GameWindow.new(fillLackingSpots([rand(40),rand(40),rand(40)]), rand(20)) #order is zombie, hunter, victim; second argument is max_turns
window.show
