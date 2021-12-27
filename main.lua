ball_count = 10
max_radius = 8

function _init()
	balls = {}
	collisions = {}
	for i=1,ball_count do
		add(balls, ball:new({
			pos=vec2:new(rnd(127),rnd(127)),
			vel=vec2:new(rnd(2)-1,rnd(2)-1):normal(),
			rad=2+flr(rnd(max_radius)),
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
	cls()
	for b in all(balls) do
		b:draw()
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
 		until rewind > 1 or (s_xpoint - t_xpoint):mag() >= source.rad + target.rad					
    local s_newvel = collision_vel(s_xpoint, source.vel, t_xpoint, target.vel)
 		local t_newvel = collision_vel(t_xpoint, target.vel, s_xpoint, source.vel)
 		source.pos = s_xpoint + source.vel * rewind
 		target.pos = t_xpoint + target.vel * rewind
    source.vel = s_newvel
    target.vel = t_newvel
		end
	end
end				

function collision_vel(x1,v1,x2,v2)
		local x_diff = x1 - x2
		local v_diff = v1 - v2
		return v1 - x_diff * v_diff:dot(x_diff) / x_diff:mag()^2
end
