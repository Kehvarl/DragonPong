require 'app/sprites.rb'

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

def check_collision a, b
  distance = (a.center_x - b.center_x) ** 2 + (a.center_y - b.center_y) ** 2
  if distance <= (a.radius + b.radius) ** 2
    if a.vx > 0
      a.vx += 0
    else
      a.vx -= 0
    end
    a.vx = -a.vx
    return 0

    tangentVector_y = -( a.center_x - b.center_x )
    tangentVector_x = a.center_y - b.center_y
    magnitude = Math.sqrt(tangentVector_x **2 + tangentVector_y**2)
    normalVector_y = tangentVector_y / magnitude
    normalVector_x = tangentVector_x / magnitude
    rvx = a.vx
    rvy = a.vy - b.vy
    length = (normalVector_x * rvx) + (normalVector_y * rvy)
    vtx = normalVector_x * length
    vty = normalVector_y * length
    a.vx -= (rvx - vtx)
    a.vy -= 2* (rvy - vty)
  end
end

def ai ball, dragon
  if dragon.y < (ball.y )
    dragon.vy += 1
    if dragon.vy >= 10
      dragon.vy = 10
    end
  elsif dragon.y > (ball.y)
    dragon.vy -= 1
    if dragon.vy <= -10
      dragon.vy = -10
    end
  end
end

def tick args
  sprites ||= ['sprites/misc/dragon-1.png', 'sprites/misc/dragon-2.png', 'sprites/misc/dragon-3.png',
               'sprites/misc/dragon-4.png', 'sprites/misc/dragon-3.png','sprites/misc/dragon-2.png']
  b_sprites ||= ['sprites/misc/explosion-2.png', 'sprites/misc/explosion-3.png', 'sprites/misc/explosion-4.png',
                 'sprites/misc/explosion-5.png', 'sprites/misc/explosion-4.png', 'sprites/misc/explosion-3.png']
  velocity ||= [-4, -3, -2, 2, 3, 4]
  args.state.p1_score ||= 0
  args.state.p2_score ||= 0
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
    if args.state.ball.out_right
      args.state.p1_score += 1
    elsif args.state.ball.out_left
      args.state.p2_score += 1
    end
    args.state.ball = Ball.new(x: 624, y: 360, h: 32, w: 32,
                               vy: velocity.sample, vx: velocity.sample, sprites: b_sprites, max_delay: 10)
  end

  check_collision args.state.ball, args.state.p1_dragon
  check_collision args.state.ball, args.state.p2_dragon

  handle_input args
  ai args.state.ball, args.state.p1_dragon
  ai args.state.ball, args.state.p2_dragon

  draw_playfield args
  draw_paddles args
  draw_ball args
end
