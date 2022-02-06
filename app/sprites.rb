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

class Animated < Sprite
  def initialize opts
    super
    @x = opts[:x]
    @y = opts[:y]
    @w = opts[:w]
    @h = opts[:h]
    @r = opts[:r]
    @g = opts[:g]
    @b = opts[:b]
    @flip_horizontally = opts[:flip_horizontally]
    @current = 0
    @anim_delay = opts[:max_delay]
    @max_delay = opts[:max_delay]
    @sprites = opts[:sprites]
    @path = sprite
  end

  def sprite
    @sprites[@current]
  end

  def tick
    @anim_delay -= 1
    if @anim_delay == 0
      @anim_delay = @max_delay
      @current += 1
      if @current == @sprites.length
        @current = 0
      end
      @path = sprite
    end
  end
end

class Dragon < Animated
  def initialize opts
    super
    @vy = opts[:vy]
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

    super
  end
end

class Ball < Animated
  attr_accessor :out_of_bounds, :out_left, :out_right
  def initialize opts
    super
    @vx = opts[:vx]
    @vy = opts[:vy]
    @rotation = 1
    @angle = 0
    @out_of_bounds = false
    @out_left = false
    @out_right = false
  end

  def off_screen
    @x < (0 - @w) or @x > 1280
  end

  def tick
    @x += @vx
    @y += @vy
    @angle += @rotation

    if @x > (1280 - 64 - @h)
      # @vx = -@vx
      @out_of_bounds = true
      @out_right = true
    elsif @x < 64
      # @vx = -@vx
      @out_of_bounds = true
      @out_left = true
    end

    if @y > (720 - 64 -@h) or @y < 64
      @vy = -@vy
    end

    super
  end
end
