pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
pi=3.14159
balls = 8
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
		//grav(b,5)
		move(b)
		edgebounce(b)
		handle_collisions(b)
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
	return vadd(vmul(vmul(n,dot(v,n)),-2),v)
end

function vadd(v1,v2)
	return {x=v1.x+v2.x,y=v1.y+v2.y}
end

function vsub(v1,v2)
	return {x=v1.x-v2.x,y=v1.y-v2.y}
end
	
function vmul(v,s)
	return {x=v.x*s, y=v.y*s}
end

function vdiv(v,s)
	return {x=v.x/s, y=v.y/s}
end

function vinv(v)
 return {x=-v.x,y=-v.y}
end

function handle_collisions(b)
	for t in all(bullets) do
		if t.id != b.id then
			diff = vsub(b.pos,t.pos)
			if (magnitude(diff) < ball_rad*2) then
 			body_bounce(b,t)
			end
		end
	end
end

function body_bounce(b1,b2)
		diff = vsub(b1.pos,b2.pos)
	 ndif = normalize(diff)
		midp = vmul(vadd(b1.pos,b2.pos),0.5)		
		
		add_collision(midp)
		
		b1.pos = vadd(midp,vmul(ndif,ball_rad+0.5))
 	b2.pos = vsub(midp,vmul(ndif,ball_rad+0.5))

		b1.vel = vsub(b1.vel,vmul(vsub(b1.pos,b2.pos),dot(vsub(b1.vel,b2.vel),vsub(b1.pos,b2.pos)),magnitude(vsub(b1.pos,b2.pos))^2))
		b2.vel = vsub(b2.vel,vmul(vsub(b2.pos,b1.pos),dot(vsub(b2.vel,b1.vel),vsub(b2.pos,b1.pos)),magnitude(vsub(b2.pos,b1.pos))^2))
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
