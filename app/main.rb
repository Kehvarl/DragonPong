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
    if @y > (720 - 64 - (@h/2))
      @vy = -@vy
    elsif @y < 64
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
  args.state.p1_score ||= 0
  args.state.p1_h ||= 64
  args.state.p2_score ||= 0
  args.state.p2_h ||= 64
  args.state.p1_dragon ||= Dragon.new(x: 72, y: 360, h: 64, w: 64, b: 192,
                                      vy: 1, sprites: sprites, max_delay: 9)
  args.state.p2_dragon ||= Dragon.new(x: 1144, y: 360, h: 64, w: 64,
                                      flip_horizontally: true,
                                      vy: 1, sprites: sprites, max_delay: 11)

  args.state.p1_dragon.tick()
  args.state.p2_dragon.tick()

  handle_input args

  draw_playfield args
  draw_paddles args
end
