pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
pi=3.14159
balls = 16
ball_rad = 4

function _init()
	bullets = {}
	collisions = {}
	for i=1,balls do
		bullets[i] = {id=i,coll=false,pos={x=rnd(127),y=rnd(127)},vel=normalize{x=rnd()-0.5,y=rnd()-0.5}}
	end
end

function _update60()
	for b in all(bullets) do
		grav(b,5)
		move(b)
		edgebounce(b)
		collide(b)
	end
end

function magnitude(v)
	return sqrt(v.x^2 + v.y^2)
end

function normalize(v)
	length = magnitude(v)
	return {x=v.x/length,y=v.y/length}
end

function dot(v1,v2)
 return v1.x*v2.x + v1.y*v2.y
end

function reflect(v,n)
	n = normalize(n)
	return vsub(scale(scale(n,dot(v,n)),2),v)
end

function bounce(v,n)
	n = normalize(n)
	return vadd(scale(scale(n,dot(v,n)),-2),v)
end

function vadd(v1,v2)
	return {x=v1.x+v2.x,y=v1.y+v2.y}
end

function vsub(v1,v2)
	return {x=v1.x-v2.x,y=v1.y-v2.y}
end
	
function scale(v,s)
	return {x=v.x*s, y=v.y*s}
end

function vinv(v)
 return {x=-v.x,y=-v.y}
end

function collide(b)
	for t in all(bullets) do
		if t.id != b.id then
			diff = vsub(b.pos,t.pos)
			ndif = normalize(diff)
			midp = scale(vadd(b.pos,t.pos),0.5)
			if (magnitude(diff) < ball_rad*2) then
				b.vel = bounce(b.vel,ndif)
 			t.vel = bounce(t.vel,vinv(ndif))
 			b.pos = vadd(midp,scale(ndif,ball_rad+0.5))
 			t.pos = vsub(midp,scale(ndif,ball_rad+0.5))
 			add_collision(midp)
			end
		end
	end
end

function add_collision(v)
	add(collisions,v)
	if(#collisions > 10) then
		del(collisions, collisions[1])
	end
end

function move(b)
	b.pos.x += b.vel.x
	b.pos.y += b.vel.y
end

function chaos(b, rate)
	b.vel.x += rnd(rate) - rate/2
	b.vel.y += rnd(rate) - rate/2
end

function edgebounce(b)
	pos = b.pos
	n = {x=0,y=0}
	if (pos.x < 0) then
	 b.pos.x = -pos.x
	 n.x = 1
	elseif (pos.x > 127) then
		b.pos.x = 127 - (pos.x - 127)
		n.x = -1
	end
	if (pos.y < 0) then
		b.pos.y = -pos.y
		n.y = 1
	elseif (pos.y > 127) then
		b.pos.y = 127 - (pos.y - 127)
		n.y = -1
	end
	if (n.x != 0 or n.y != 0) then
		n = normalize(n)
		b.vel = bounce(b.vel, n)
	end  
end

function grav(b, speed)
	b.vel.y += speed/60
end

function _draw()
	cls()
	for c in all(collisions) do
		circfill(c.x, c.y, 1, 10)
	end
	for b in all(bullets) do
		circfill(b.pos.x, b.pos.y, ball_rad, 7)
	end
	//print(bullets[1].vel.x)
	//print(bullets[1].vel.y)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
