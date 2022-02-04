class Dragon
  def initialize x, y, vx, vy, sprites, flipped = false, max_delay = 10
    @x ||= x
    @y ||= y
    @vy ||= vy
    @vx ||= vx
    @flip_horizontally ||= flipped
    @sprites ||= sprites
    @current ||= 0
    @anim_delay ||= 10
    @max_delay ||= max_delay
    @size ||= 64
  end

  def x
    @x
  end

  def y
    @y
  end

  def sprite
    @sprites[@current]
  end

  def flip_horizontally
    @flip_horizontally
  end

  def size
    @size
  end

  def up
    @vy += 1
  end

  def down
    @vy -= 1
  end

  def tick
    @x += 0
    @y += @vy
    if @x > 1280
      @vx = -@vx
      @flip_horizontally = true
    elsif @x < (0 - @size)
      @vx = -@vx
      @flip_horizontally = false
    end
    if @y > (720 - 64 - @size)
      @vy = -@vy
    elsif @y < 64
      @vy = -@vy
    end

    @anim_delay -= 1
    if @anim_delay == 0
      @anim_delay = @max_delay
      @current += 1
      if @current == @sprites.length
        @current = 0
      end
    end
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
  args.outputs.primitives << {x: args.state.p1_dragon.x, y: args.state.p1_dragon.y, w: 64, h: 64,
                              path: args.state.p1_dragon.sprite, r: 255, g: 255, b: 128,
                              flip_horizontally: args.state.p1_dragon.flip_horizontally}.sprite!
  args.outputs.primitives << {x: args.state.p2_dragon.x, y: args.state.p2_dragon.y, w: 64, h: 64,
                              path: args.state.p2_dragon.sprite,
                              flip_horizontally: args.state.p2_dragon.flip_horizontally}.sprite!
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
  args.state.p1_dragon ||= Dragon.new(72, 360, 1, 1, sprites, false, 9)
  args.state.p2_dragon ||= Dragon.new(1192 - 64, 360, 1, 1, sprites, true, 11)

  args.state.p1_dragon.tick()
  args.state.p2_dragon.tick()

  handle_input args

  draw_playfield args
  draw_paddles args
end
