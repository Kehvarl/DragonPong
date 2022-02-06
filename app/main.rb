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
    args.state.ball = Ball.new(x: 624, y: 360, h: 32, w: 32,
                               vy: velocity.sample, vx: velocity.sample, sprites: b_sprites, max_delay: 10)
  end

  handle_input args

  draw_playfield args
  draw_paddles args
  draw_ball args
end
