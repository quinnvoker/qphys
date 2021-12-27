ball = {
	__count = 0,
	id = nil,
	pos = vec2:new(0,0),
	vel = vec2:new(0,0),
	rad = 1,
	col = 7,
	
	draw = function(self)
		circfill(self.pos.x, self.pos.y, self.rad, self.col)
	end,
	
	move = function(self)
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
				if ((diff):mag() < self.rad + b.rad) then
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
	o.col = o.id % 16
	setmetatable(o, self)
	o.__index = self
	return o
end
