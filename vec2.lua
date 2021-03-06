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
		return vec2:new(self.x/#self, self.y/#self)
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
vec2.__len = function(v) return v:length() end 
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
