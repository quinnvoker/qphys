pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
vec2 = {
	x = 0,
	y = 0,
	
  angle = function(self)
    return atan2(y, x);
  end,

	length = function(self)
	 return sqrt(self.x^2+self.y^2)
	end,
	
	dot = function(self,v)
		return self.x * v.x + self.y * v.y
	end,
	
	normal = function(self)
		local length = self:length()
		return vec2:new(self.x/length, self.y/length)
	end,
	
  bounce = function(self, n)
		local n = n:normal()
		return n * -2 * self:dot(n) + self
	end,
}

vec2.__eq = function(v1,v2) return v1.x == v2.x and v1.y == v2.y end
vec2.__add = function(v1,v2) return vec2:new(v1.x+v2.x,v1.y+v2.y) end
vec2.__sub = function(v1,v2) return vec2:new(v1.x-v2.x,v1.y-v2.y) end
vec2.__mul = function(o1,o2)
  local s,v
  if(tonum(o1)) then
    s = o1
    v = o2
  else
    s = o2
    v = o1
  end
  return vec2:new(v.x*s,v.y*s)
end
vec2.__div = function(v,s) return vec2:new(v.x/s,v.y/s) end
vec2.__unm = function(v) return vec2:new(-v.x,-v.y) end
vec2.__tostring = function(v) return "{x: "..v.x..",y: "..v.y.."}" end
vec2.__index = vec2

function vec2:new(x,y)
	local x = x or 0
	local y = y or 0
	local o = {x=x,y=y}
	setmetatable(o, self)
	o.__index = self
	return o
end

function vec2:print_debug(v)
	local v = v or vec2:new(0,1)
	print("vec: "..vec2.__tostring(self))
	print("length: "..self:length())
	print("dot: "..self:dot(v))
	print("normal: "..vec2.__tostring(self:normal()))
	print("bounce: "..vec2.__tostring(self:bounce(v)))
	print("inv: "..vec2.__tostring(-self))
end

-->8
ball = {
	__count = 0,
	id = nil,
	pos = vec2:new(0,0),
  last_pos = vec2:new(0,0),
	vel = vec2:new(0,0),
	rad = 1,
	col = 7,
  
  mass = function(self)
    return self.rad
  end,
	
	draw = function(self, shadow)
    if (shadow == true) then
      circfill(self.last_pos.x, self.last_pos.y, self.rad, self.col + 8)
    end
		circfill(self.pos.x, self.pos.y, self.rad, self.col)
	end,
	
	move = function(self)
    self.last_pos = self.pos
		self.pos += self.vel
	end,
	
	edge_bounce = function(self)
		edge_normal = vec2:new()
		for axis in all({"x","y"}) do
			val = self.pos[axis]
			if (val - self.rad < 0) then
				self.pos[axis] = self.rad
				edge_normal[axis] = 1
			elseif (val + self.rad > 127) then
				self.pos[axis] = 127 - self.rad
				edge_normal[axis] = -1
			end 
		end
		if (edge_normal.x != 0 or edge_normal.y != 0) then
			self.vel = self.vel:bounce(edge_normal)
		end
	end,
	
	check_collisions = function(self, balls)
		for b in all(balls) do
			if (b.id != self.id and (collisions[b] == nil or collisions[b][self] == nil)) then
				local diff = self.pos - b.pos
				if (diff:length() < self.rad + b.rad) then
				 collisions[self] = collisions[self] or {}
				 collisions[self][b] = diff
				end
			end
		end
	end,
}
ball.__index = ball

function ball:new(o)
	ball.__count += 1
	local o = o or {}
	o.id = ball.__count
	o.col = o.col or o.id % 8
	setmetatable(o, self)
	o.__index = self
	return o
end

-->8
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
 		until rewind > 1 or (s_xpoint - t_xpoint):length() >= source.rad + target.rad
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
		return v1 - x_diff * (2 * m2 / (m1 + m2))  * v_diff:dot(x_diff) / x_diff:length()^2
end

__gfx__
01230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89ab0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cdef7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
