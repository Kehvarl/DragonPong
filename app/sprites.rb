##
# This class defines a Sprite primitive for DRGTK.
# Contains ALL sprite properties AND primitive_marker
# From http://docs.dragonruby.org/#---different-sprite-representations
#
class Sprite
  attr_accessor :x, :y, :z, :w,:h, :path, :angle, :a, :r, :g, :b,
                :source_x, :source_y, :source_w, :source_h,
                :tile_x, :tile_y, :tile_w, :tile_h,
                :flip_horizontally, :flip_vertically,
                :angle_x, :angle_y,
                :angle_anchor_x, :angle_anchor_y, :blendmode_enum

  def primitive_marker
    :sprite
  end
end

##
# This class represents a multi-frame animated Sprite
class Animated < Sprite
  def initialize opts
    super
    @x = opts[:x] || 0
    @y = opts[:y] || 0
    @w = opts[:w] || 16
    @h = opts[:h] || 16
    @r = opts[:r] || 255
    @g = opts[:g] || 255
    @b = opts[:b] || 255
    @flip_horizontally = opts[:flip_horizontally] || false
    @current = 0
    @anim_delay = opts[:max_delay] || 10
    @max_delay = opts[:max_delay] || 10
    @sprites = opts[:sprites] || ['sprites/error.png']
    @path = sprite
  end

  def sprite
    @sprites[@current]
  end

  def tick
    @anim_delay -= 1
    if @anim_delay == 0
      @anim_delay = @max_delay
      @current = (@current + 1) % @sprites.length
      @path = sprite
    end
  end
end

class Dragon < Animated
  attr_accessor :vy
  def initialize opts
    super
    @vy = opts[:vy] || 1
  end

  def center
    [center_x, center_y]
  end

  def center_x
    @x + @w/2
  end

  def center_y
    @y + @h/2
  end

  def radius
    (@w + @h) /4
  end
  
  def up
    @vy += 1
  end

  def down
    @vy -= 1
  end

  def tick
    @y += @vy
    if @y > (720 - 64 - (@h/2)) or @y < 64
      @vy = -@vy
    end


    if @vy > 0
      @angle  = 15
    elsif @vy < 0
      @angle  = -15
    end

    if @flip_horizontally
      @angle = -@angle
    end

    super
  end
end

class Ball < Animated
  attr_accessor :out_of_bounds, :out_left, :out_right, :vx, :vy, :contact
  def initialize opts
    super
    @vx = opts[:vx] || 1
    @vy = opts[:vy] || 1
    @rotation = opts[:rotation] || 3
    @angle = 0
    @out_of_bounds = false
    @out_left = false
    @out_right = false
    @contact = false
  end

  def off_screen
    @x < (0 - @w) or @x > 1280 or @y < (0 - @h) or @y > 720
  end

  def center
    [center_x, center_y]
  end

  def center_x
    @x + @w/2
  end

  def center_y
    @y + @h/2
  end

  def radius
    (@w + @h) /4
  end

  def tick
    @x += @vx
    @y += @vy
    @angle += @rotation

    if @x > (1280 - 64 - @h)
      @out_of_bounds = true
      @out_right = true
    elsif @x < 64
      @out_of_bounds = true
      @out_left = true
    end

    if @y > (720 - 64 -@h) or @y < 64
      @vy = -@vy
    end

    super
  end
end

class Player < Dragon
  attr_accessor :score
  def initialize opts
    super
    @score = opts[:score] || 0
  end

  def display
    @score.to_s.rjust(3, '0')
  end
end