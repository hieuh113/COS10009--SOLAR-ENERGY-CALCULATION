require 'gosu'

class HouseWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "House Drawing in Gosu"
  end

  def draw
    draw_house
  end

  def draw_house
    # Draw the main house rectangle
    draw_rect(200, 300, 240, 150, Gosu::Color::WHITE)
    
    # Draw the roof
    draw_triangle(200, 300, Gosu::Color::GREEN, 440, 300, Gosu::Color::YELLOW, 320, 200, Gosu::Color::YELLOW)

    # Define brown color
    brown = Gosu::Color.argb(0xff8B4513)
    
    # Draw the door
    draw_rect(300, 380, 40, 70, brown)

   
  end

  def draw_rect(x, y, width, height, color, z = 0)
    Gosu.draw_rect(x, y, width, height, color, z)
  end

  def draw_triangle(x1, y1, color1, x2, y2, color2, x3, y3, color3, z = 0)
    Gosu.draw_triangle(x1, y1, color1, x2, y2, color2, x3, y3, color3, z)
  end
end

window = HouseWindow.new
window.show