class Dragon
  def initialize x, y, vx, vy, sprites
    @x ||= x
    @y ||= y
    @vy ||= vy
    @vx ||= vx
    @flip_horizontally ||= false
    @sprites ||= sprites
    @current ||= 0
    @anim_delay ||= 10
    @max_delay ||= 10
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

  def tick
    @x += @vx
    @y += @vy
    if @x > 1280
      @vx = -@vx
      @flip_horizontally = true
    elsif @x < (0 - @size)
      @vx = -@vx
      @flip_horizontally = false
    end
    if @y > (720 - @size)
      @vy = -@vy
    elsif @y < 360
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
  args.outputs.primitives << [72, args.state.p1_y - (args.state.p1_h/2), 16, args.state.p1_h, 0, 128, 128].solids
  args.outputs.primitives << [1192, args.state.p2_y - (args.state.p2_h/2), 16, args.state.p2_h, 0, 128, 128].solids
end

def tick args
  args.state.p1_score ||= 0
  args.state.p1_y ||= 360
  args.state.p1_h ||= 64
  args.state.p2_score ||= 0
  args.state.p2_y ||= 360
  args.state.p2_h ||= 64
  draw_playfield args
  draw_paddles args

  sprites = ['sprites/misc/dragon-1.png', 'sprites/misc/dragon-2.png', 'sprites/misc/dragon-3.png',
             'sprites/misc/dragon-4.png', 'sprites/misc/dragon-3.png','sprites/misc/dragon-2.png']
  @dragon = Dragon.new(@center_x, @center_y, 1, 1, sprites)
end
