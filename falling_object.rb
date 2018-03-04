require 'gosu'

$DEBUG = false

class FallingObject
  attr_accessor :image, :x, :y, :width, :height, :is_hidden
  SPEED = 3

  def initialize(window, image, x, y, width, height)
    @window = window
    @image = image
    @x = x
    @y = y
    @width = width
    @height = height
    is_hidden = false
  end

  def update
    @y = @y + SPEED
    @y = 0 unless @y < @window.height
  end

  def draw
    @image.draw(@x, @y, 1) unless is_hidden

    return unless $DEBUG
    draw_bounding_body(self.body)
  end

  def body
    {:x => @x,
     :y => @y,
     :width => @width,
     :height => @height}
  end

  def draw_bounding_body(rect, z = 10, color = Gosu::Color::GREEN)
    return unless $DEBUG
    Gosu::draw_line(rect[:x], @y, color, rect[:x], @y + rect[:height], color, z)
    Gosu::draw_line(rect[:x], @y + rect[:height], color, rect[:x] + rect[:width], @y + rect[:height], color, z)
    Gosu::draw_line(rect[:x] + rect[:width], @y + rect[:height], color, rect[:x] + rect[:width], @y, color, z)
    Gosu::draw_line(rect[:x] + rect[:width], @y, color, rect[:x], @y, color, z)
  end


end
