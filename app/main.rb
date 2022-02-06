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

def new_game args
  args.state.p1_score = 0
  args.state.p1_y = 360
  args.state.p1_h = 64
  args.state.p2_score = 0
  args.state.p2_y = 360
  args.state.p2_h = 64
end

def draw_playfield args
  args.outputs.primitives << [0, 0, 1280, 720, 0, 0, 0].solids
  args.outputs.primitives << [64, 64, 1152, 592, 0, 200, 0].borders
  args.outputs.primitives << [640, 0, 640, 720, 0, 200, 0].lines
  args.outputs.primitives << [320, 715, args.state.p1_score.to_s.rjust(3, '0'), 16, 1, 0, 200, 0].labels
  args.outputs.primitives << [960, 715, args.state.p2_score.to_s.rjust(3, '0'), 16, 1, 0, 200, 0].labels
end

def draw_paddles args
  args.outputs.primitives << args.state.p1_dragon
  args.outputs.primitives << args.state.p2_dragon
end

def draw_ball args
  args.outputs.primitives << args.state.ball
end

def handle_input args
  if args.inputs.keyboard.key_down.up
    args.state.p1_dragon.up
  elsif args.inputs.keyboard.key_down.down
    args.state.p1_dragon.down
  end
end

def tick args
  sprites ||= ['sprites/misc/dragon-1.png', 'sprites/misc/dragon-2.png', 'sprites/misc/dragon-3.png',
               'sprites/misc/dragon-4.png', 'sprites/misc/dragon-3.png','sprites/misc/dragon-2.png']
  b_sprites ||= ['sprites/misc/explosion-2.png', 'sprites/misc/explosion-3.png', 'sprites/misc/explosion-4.png',
                 'sprites/misc/explosion-5.png', 'sprites/misc/explosion-4.png', 'sprites/misc/explosion-3.png']
  velocity ||= [-4, -3, -2, 2, 3, 4]
  args.state.p1_score ||= 0
  args.state.p1_h ||= 64
  args.state.p2_score ||= 0
  args.state.p2_h ||= 64
  args.state.p1_dragon ||= Dragon.new(x: 72, y: 360, h: 64, w: 64, b: 192,
                                      vy: 1, sprites: sprites, max_delay: 9)
  args.state.p2_dragon ||= Dragon.new(x: 1144, y: 360, h: 64, w: 64,
                                      flip_horizontally: true,
                                      vy: 1, sprites: sprites, max_delay: 11)
  args.state.ball ||= Ball.new(x: 624, y: 360, h: 32, w: 32,
                                      vy: velocity.sample, vx: velocity.sample, sprites: b_sprites, max_delay: 10)

  args.state.ball.tick()
  args.state.p1_dragon.tick()
  args.state.p2_dragon.tick()
  if args.state.ball.off_screen()

    args.state.ball = Ball.new(x: 624, y: 360, h: 32, w: 32,
                               vy: velocity.sample, vx: velocity.sample, sprites: b_sprites, max_delay: 10)
  end

  handle_input args

  draw_playfield args
  draw_paddles args
  draw_ball args
end
