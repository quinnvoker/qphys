pal()
cls()

ball_count = 16
max_radius = 16

function _init()
  pal({9,10,11,12,13,2,15,136,137,138,139,140,141,130,143,8},1)
  balls = {}
	collisions = {}
	for i=1,ball_count do
		add(balls, ball:new({
			pos=vec2:new(rnd(127),rnd(127)),
			vel=vec2:new(rnd(2)-1,rnd(2)-1):normal(),
			rad = i < max_radius and i or max_radius,
    }))
	end
end

function _update60()
	for b in all(balls) do
		b:move()
		b:edge_bounce()
	end
	for b in all(balls) do
	 b:check_collisions(balls)
	end 
	handle_collisions(balls)
	collisions = {}
end	

function _draw()
	-- cls()
	for b in all(balls) do
		b:draw(true)
	end
end

function handle_collisions()
	for source,colls in pairs(collisions) do
		for target,diff in pairs(colls) do
  	local n = diff:normal()
 	 local steps = 0
 	 local rewind = 0
 	 local s_xpoint = source.pos
 	 local t_xpoint = target.pos
 	 repeat
 			steps += 1
 			rewind = 0.1 * steps
 			s_xpoint = source.pos - source.vel * rewind
 			t_xpoint = target.pos - target.vel * rewind
 		until rewind > 1 or #(s_xpoint - t_xpoint) >= source.rad + target.rad
    local s_newvel = collision_vel(s_xpoint, source.vel, t_xpoint, target.vel, source:mass(), target:mass())
 		local t_newvel = collision_vel(t_xpoint, target.vel, s_xpoint, source.vel, target:mass(), source:mass())
 		source.pos = s_xpoint + source.vel * rewind
 		target.pos = t_xpoint + target.vel * rewind
    source.vel = s_newvel
    target.vel = t_newvel
		end
	end
end				

function collision_vel(x1,v1,x2,v2,m1,m2)
    m1 = m1 or 1
    m2 = m2 or 1
		local x_diff = x1 - x2
		local v_diff = v1 - v2
		return v1 - x_diff * (2 * m2 / (m1 + m2))  * v_diff:dot(x_diff) / (#x_diff)^2
end
