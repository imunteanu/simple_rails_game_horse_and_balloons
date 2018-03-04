require 'gosu'
load 'falling_object.rb'

class GameWindow < Gosu::Window
  WINDOW_WIDTH = 950

  def initialize(width = WINDOW_WIDTH, height = 590, fullscreen = false)
    super(width, height, fullscreen)
    self.caption = 'L&I Games'
    @background = Gosu::Image.new('assets/background_country_field.png')

    @horse_to_left = Gosu::Image.load_tiles("assets/horse_tiles_to_left.png", 182, 116)
    @horse_to_right = Gosu::Image.load_tiles("assets/horse_tiles_to_right.png", 182, 116)
    @current_horse = @horse_to_left.last
    @horse_position = [770, 350]

    @balloons = [Gosu::Image.new("assets/balloon0.png"),
              Gosu::Image.new("assets/balloon1.png"),
              Gosu::Image.new("assets/balloon2.png"),
              Gosu::Image.new("assets/balloon3.png")]
    @falling_balloons = [FallingObject.new(self, @balloons[0], rand(6) + 140, -rand(100), 30, 19),
                      FallingObject.new(self, @balloons[1], rand(100) + 20, -rand(40), 30, 40),
                      FallingObject.new(self, @balloons[1], rand(100) + 400, -rand(450), 30, 40),
                      FallingObject.new(self, @balloons[2], rand(100) + 300, -rand(800), 35, 30),
                      FallingObject.new(self, @balloons[2], rand(100) + 100, -rand(1200), 35, 30),
                      FallingObject.new(self, @balloons[2], rand(100) + 800, -rand(1200), 35, 30),
                      FallingObject.new(self, @balloons[2], rand(100) + 700, -rand(1200), 35, 30),
                      FallingObject.new(self, @balloons[3], rand(100) + 650, -rand(400), 30, 30)]

    @points_text = Gosu::Font.new(self, "Helvetica", 40)
    @points = 0

    @beep = Gosu::Sample.new("assets/boom.ogg")
    @horse_neigh = Gosu::Sample.new("assets/horse-neigh.wav")
  end

  def update
    step = (Gosu::milliseconds / 100 % 9) + 1
    if Gosu::button_down?(Gosu::KbRight)
      @current_horse = @horse_to_right[step]
      move(:right)
    elsif Gosu::button_down?(Gosu::KbLeft)
      @current_horse = @horse_to_left[step]
      move(:left)
    else
      @running = false
      @current_horse = @last_direction == :right ? @horse_to_right.last : @horse_to_left.last
    end

    @falling_balloons.each {|balloon| balloon.update}

    jump if Gosu::button_down?(Gosu::KbSpace)
    handle_jump if @jumping

    handle_collisions
  end

  def draw
    @background.draw(-2,0,0) #remoe each time update
    @current_horse.draw(@horse_position[0], @horse_position[1], 1)
    @falling_balloons.each {|balloon| balloon.draw}
    @points_text.draw("Points: #{@points}", 720, 20, 4)
  end

  private

  SPEED = 12

  def move(direction)
    @running = true
    @last_direction = direction
    if direction == :right
      @horse_position = [move_to_right_offset, @horse_position[1]]
    else
      @horse_position = [move_to_left_offset, @horse_position[1]]
    end
  end

  def move_to_right_offset
    offset = @horse_position[0] + SPEED
    return offset > WINDOW_WIDTH - 180 ? @horse_position[0] : offset
  end

  def move_to_left_offset
    offset = @horse_position[0] - SPEED
    return offset < -10 ? @horse_position[0] : offset
  end

  def jump
    return if @jumping
    @jumping = true
    @vertical_velocity = 30
  end

  def handle_jump
    gravity = 1.5
    ground_level = 350 # y offset where our hero is on the ground
    @horse_position = [@horse_position[0], @horse_position[1] - @vertical_velocity]

    if @vertical_velocity.round == 0 # top of the jump
      @vertical_velocity = -1
    elsif @vertical_velocity < 0 # falling down
      @vertical_velocity = @vertical_velocity * gravity
    else
      @vertical_velocity = @vertical_velocity / gravity
    end

    if @horse_position[1] >= ground_level
      @horse_position[1] = ground_level
      @jumping = false
    end
  end

  def handle_collisions
    horse_rectangle =  {:x => @horse_position[0],
                        :y => @horse_position[1],
                        :width => @current_horse.width,
                        :height => @current_horse.height}

    @falling_balloons.each do |balloon|
      if did_the_horse_cought_the_ballon?(horse_rectangle, balloon.body)
        balloon.is_hidden = true
        balloon.y = -100
        @points+=1
        @beep.play
        @horse_neigh.play if @points % 10 == 0
      else
        balloon.is_hidden = false
      end
    end
  end

  def did_the_horse_cought_the_ballon?(rect1, rect2)
    return false if ((rect1[:x] > rect2[:x] + rect2[:width]) || (rect1[:x] + rect1[:width] < rect2[:x]))
    return false if ((rect1[:y] > rect2[:y] + rect2[:height]) || (rect1[:y] + rect1[:height] < rect2[:y]))
    return true
  end

end

window = GameWindow.new
window.show
