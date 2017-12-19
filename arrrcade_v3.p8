pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-------------------------------
--arrrcade--
--samia r. & daniel o.
--v2
-------------------------------

-------------------------------
--game loop
function _init()
 debug = true
 player_init()
 level:init()
 colgrid:init()
end


function _update()
 
 colgrid:reset()
 objects:update()
 player_update()

 
 --debug on off
 if btnp(5) then
  if debug then 
   debug = false
  else
   debug = true
  end
 end
 
end


function _draw()
 cls(4)
 palt(0,false)--black -> opaque
 palt(11,true)--green -> transparent


 level:draw()
 objects:draw()
 
 
 --debug....---
 if debug then
 -- colgrid:draw()
  print("cpu: "..stat(1)
   .."\nblc: "..#objects.blocks
   .."\nchr: "..#objects.chars
   .."\nitm: "..#objects.items
   .."\npjt: "..#objects.projectiles
  )
  print(tostr(player.grounded)
  .."\nvy:"..player.vy
  .."\ny:"..player.y
  ,player.x,player.y-20)
 end
end

-------------------------------
--level
--[[
nice to have: randomly arranged
background segments

--]]
level = {
 gravity = 0.25
}


function level:init()
 --create plattform in level center
 for i=0,16 do
  objects.blocks:create(i*8,64,obj_platform)
 end
 --create test player and block
 
 objects.blocks:create(64,16,obj_chest)
 --create random cannonballs
 for i=0,8 do
  objects.blocks:create(
   i * 16 -rnd(8)+8,
   0,
   obj_cannonball
  )
 end
end


function level:draw()
 --background map
 map(0,0,0,0,16,16)
 for i=0,16 do
  spr(32,i*8,64)
 end
 --static objects map
-- map(0,0,0,0,16,16)
end


-------------------------------
--collision
--[[
collision in arrrcade works with
objects in following sizes

 4x4
 8x8 8x16
 16x16 
      
all characters and objects have
an individual hitbox.

dropped objects fall checking 
for hitbox overlapping until 
they hit another object or a
character

--]]
colgrid = {}
colgrid.size = 2

function colgrid:init()
 --fill a blank grid with
 --4x4 pixels each cell
 for ix=1,128/colgrid.size do
  local row = {}
  for iy=1,128/colgrid.size do
   add(row,false)
  end
  add(colgrid,row)
 end
end
function colgrid:reset()
	for ix=1,128/colgrid.size do
  for iy=1,128/colgrid.size do
   colgrid[ix][iy]=false
  end
 end
end

function colgrid:update(obj)
 --upper left point
 local obj_x1 = flr(
  (obj.x - obj.cw * 0.5)
  / colgrid.size
 )
 local obj_y1 = flr(
  (obj.y - obj.ch * 0.5)
  / colgrid.size
 )
 --lower right point
 local obj_x2 = flr(
  (obj.x + obj.cw * 0.5)
  / colgrid.size
 )
 local obj_y2 = flr(
  (obj.y + obj.ch * 0.5)
  / colgrid.size
 )
 
 for ix=obj_x1, obj_x2 do
  for iy=obj_y1, obj_y2 do
   if ix>0 and iy > 0 
   and ix < 128/colgrid.size
   and iy < 128/colgrid.size then
    colgrid[ix][iy] = true
   end
  end
 end
end


function colgrid:draw()
 for ix=1,128/colgrid.size do
  for iy=1,128/colgrid.size do
   if colgrid[ix][iy] then
    rect(
     (ix-1)*colgrid.size,
     (iy-1)*colgrid.size,
     (ix)*colgrid.size+colgrid.size,
     (iy)*colgrid.size+colgrid.size,
     10
    )
   end
  end
 end
end


function collision(obj,other)
 if other.x+other.cw*0.5
  > obj.x-obj.cw*0.5
 and other.y+other.ch*0.5
   > obj.y-obj.ch*0.5
 and other.x-other.cw*0.5
   < obj.x+obj.cw*0.5 
 and other.y-other.ch*0.5
   < obj.y+obj.ch*0.5
 then
   return true
 else
  return false
 end
end
-------------------------------
--objects
--[[
there are 2 kinds of objects in 
arrrcade: falling and static

falling objects become static
objects and are destructible
when destroyed they drop items
or merge into smaller copies of 
themselves
       
 barrels	 ->		blackpowder
  \chests ->  gold
   \ /   
 broken wood

--]]

objects={
-- static={},
-- moving={}
 chars={},
 blocks={},
 items={},
 projectiles={}
}


--template data
--sprite
obj_sx = {} obj_sy = {} 
obj_sw = {} obj_sh = {}
--collision
obj_cx = {} obj_cy = {}
obj_cw = {} obj_ch = {}

--
obj_cade = 1
obj_sx[obj_cade] = 0
obj_sy[obj_cade] = 0
obj_sw[obj_cade] = 16
obj_sh[obj_cade] = 16
obj_cx[obj_cade]  = 2
obj_cy[obj_cade]  = 1
obj_cw[obj_cade]  = 5
obj_ch[obj_cade]  = 12
--
obj_barrel = 2
obj_sx[obj_barrel]  = 16
obj_sy[obj_barrel]  = 0
obj_sw[obj_barrel]  = 16
obj_sh[obj_barrel]  = 16
obj_cx[obj_barrel]  = 1
obj_cy[obj_barrel]  = 1
obj_cw[obj_barrel]  = 14
obj_ch[obj_barrel]  = 14
--
obj_chest = 3
obj_sx[obj_chest]  = 32
obj_sy[obj_chest]  = 0
obj_sw[obj_chest]  = 16
obj_sh[obj_chest]  = 16
obj_cx[obj_chest]  = 1
obj_cy[obj_chest]  = 1
obj_cw[obj_chest]  = 14
obj_ch[obj_chest]  = 15
--
obj_brokenwood = 4
obj_sx[obj_brokenwood]  = 40
obj_sy[obj_brokenwood]  = 0
obj_sw[obj_brokenwood]  = 12
obj_sh[obj_brokenwood]  = 8
obj_cx[obj_brokenwood]  = 1
obj_cy[obj_brokenwood]  = 1
obj_cw[obj_brokenwood]  = 1
obj_ch[obj_brokenwood] = 1
--
obj_platform = 5
obj_sx[obj_platform]  = 8
obj_sy[obj_platform]  = 16
obj_sw[obj_platform]  = 8
obj_sh[obj_platform]  = 8
obj_cx[obj_platform]  = 0
obj_cy[obj_platform]  = 2
obj_cw[obj_platform]  = 8
obj_ch[obj_platform]  = 2
--
obj_cannonball = 6
obj_sx[obj_cannonball]  = 16
obj_sy[obj_cannonball]  = 16
obj_sw[obj_cannonball]  = 5
obj_sh[obj_cannonball]  = 5
obj_cx[obj_cannonball]  = 1
obj_cy[obj_cannonball]  = 1
obj_cw[obj_cannonball]  = 1
obj_ch[obj_cannonball]  = 1


-----------------------------
--template for object creation
function obj_template()
 return {
  --identity/type
  t,
  --position
  x,y,
  --movement
  vx=0,vy=0,
  --collision
  grounded = false,
  cx,cy,
  cw,ch,
  --
  damage=false,
  hp = 1,
  --sprites
  sx,sy,--pixel position on sheet
  sw,sh--pixel size (width&height)
 }
end


function objects:create(_x,_y,_t)
 local obj = obj_template()
 obj.t = _t
 obj.x = _x
 obj.y = _y
 --get collision (hitbox) data
 obj.cx = obj_cx[_t]
 obj.cy = obj_cy[_t]
 obj.cw = obj_cw[_t]
 obj.ch = obj_ch[_t]
 --get sprite data for sspr
 obj.sx = obj_sx[_t]
 obj.sy = obj_sy[_t]
 obj.sw = obj_sw[_t]
 obj.sh = obj_sh[_t]
 return obj
end

function objects.chars:create(_x,_y,_t)
 local obj = objects:create(_x,_y,_t)
 add(objects.chars,obj)
 return obj
end

function objects.blocks:create(_x,_y,_t)
 local obj = objects:create(_x,_y,_t)
 --individual block data
 if _t ==obj_platform then
  obj.grounded = true
 end
 if _t ==obj_cannonball then
  obj.vx = 1--flr(-rnd(1)+rnd(2))
  obj.vy = 4--flr(4 +rnd(4))
 end
 --save to table
 add(objects.blocks,obj)
 return obj
end

frame = 0
function objects:update()
 frame += 1 
 frame %= 16
 
 objects.chars:update()
 objects.blocks:update()
end


--delete when leaving the screen
function objects:leftscreen(obj)
 if obj.x < 0 or obj.x > 128 
 or obj.y < 0 or obj.y > 128 
 then
  return true
 end
end


function objects.chars:update()
 for chr in all(objects.chars) do
  --ground if on bottom
  if chr.y+chr.sh*0.5 > 124 then
   chr.grounded = true
   chr.vy = 0
   chr.vx = 0
  end
  --debug: update collision grid
  colgrid:update(chr)
  --not grounded (falling)
  if not chr.grounded then
   --save old position
   local old = {x=chr.x, y=chr.y}
   --move by velocity
   chr.x += chr.vx
   --add gravity
   chr.vy += level.gravity
   --fall 
   chr.y += chr.vy
   
   --check for collision when falling
   if chr.vy > 0 then
    for k, v in pairs(objects) do
     if type(v)=="table" then
      for other in all(v) do
       if collision(chr,other)
       and other ~=chr then
        other.grounded = false
        chr.x = old.x
        chr.y = old.y
        chr.vy = 0
        chr.grounded = true
       end
      end
     end
    end
   end 
  --grounded(not moving)
  else
   --recheck all 8 frames
   if frame == 0 then
    chr.grounded = false
   end
   --delete when out of screen
   if objects:leftscreen(chr) then
    del(objects.chars,chr)
   end
  end
 end
end

function objects.blocks:update()
 for blk in all(objects.blocks) do
  --test destroy a chest when hit by chest
  if blk.damage then
   if blk.t == obj_chest then
    objects.blocks:create(
     blk.x-blk.cw,
     blk.y-blk.ch,
    obj_brokenwood)
    objects.blocks:create(
     blk.x+blk.cw,
     blk.y-blk.ch,
    obj_brokenwood)
    objects.blocks:create(
     blk.x-blk.cw,
     blk.y+blk.ch,
    obj_brokenwood)
    objects.blocks:create(
     blk.x+blk.cw,
     blk.y+blk.ch,
    obj_brokenwood)
    del(objects.blocks,blk)
   end
  end
  --test count down for del
  if blk.t==obj_brokenwood or (blk.t == obj_platform and blk.damage) then
   blk.hp += 1
   if blk.hp > 128 then
    del(objects.blocks,blk)
   end
  end
  --ground if on bottom
  if blk.y+blk.sh*0.5 > 124 then
   blk.grounded = true
  end
  --debug: update collision grid
  colgrid:update(blk)
  --not grounded (falling)
  if blk.grounded == false then
   --save old position
   local old = {x=blk.x, y=blk.y}
   
   --move by velocity
   blk.x += blk.vx
   --add gravity
   blk.vy += level.gravity
   --fall 
   blk.y += blk.vy
   
   --check for collision
   for k, v in pairs(objects) do
    if type(v)=="table" then
     for other in all(v) do
      if collision(blk,other)
      and other ~=blk then
       --individual reactions
       other.grounded = false
       other.damage = true
       blk.x = old.x
       blk.y = old.y
       blk.vy = 0
       blk.grounded = true
      end
     end
    end
   end
   
  --grounded(not moving)
  else
   --recheck all 8 frames
   if frame == 0 and blk.t ~= obj_platform then
    blk.grounded = false
   end
   
   --delete when out of screen
   if objects:leftscreen(blk) then
    del(objects.blocks,blk)
   end
  end
 end
end


function objects:draw()
 for k, v in pairs(objects) do
  if type(v)=="table" then
   for obj in all(v) do
    sspr(
     obj.sx,
     obj.sy,
     obj.sw,
     obj.sh,
     obj.x - obj.sw * 0.5,--upper left corner
     obj.y - obj.sh * 0.5,--of the sprite
     obj.sw,
     obj.sh,
     obj.flip_x,
     obj.flip_y
    )
    if debug then
     pset( 
     
     obj.x,
     obj.y,
     8)
     pset( 
     obj.x-obj.cw*0.5,
     obj.y-obj.cw*0.5,
     9)
     pset( 
     obj.x+obj.cw*0.5,
     obj.y-obj.cw*0.5,
     9)
     pset( 
     obj.x-obj.cw*0.5,
     obj.y-obj.cw*0.5,
     9)
     pset( 
     obj.x-obj.cw*0.5,
     obj.y+obj.cw*0.5,
     9)
    end
   end
  end
 end
 --hardcode overdraw player sprite
 sspr(
     player.sx,
     player.sy,
     player.sw,
     player.sh,
     player.x - player.sw * 0.5,--upper left corner
     player.y - player.sh * 0.5,--of the sprite
     player.sw,
     player.sh,
     player.flip_x,
     player.flip_y
    )
end
-------------------------------
--player (mirror of char 1)
player = {}
function player_init()
 player = objects.chars:create(32,24,obj_cade) 
end
pframe = 0
function player_update()
 pframe +=1 
 pframe %= 64
 if pframe == 0 then
  --spawn object
  pobj = 
  objects.blocks:create(rnd(128),2,obj_chest)
 end
 if btn(0) then
  player.x -= 1
  player.flip_x = true
 end
 if btn(1) then
  player.x += 1
  player.flip_x = false
 end
 if btn(2) and player.grounded then
  player.vy = -3.5
  player.grounded = false
  player.y-=3
  --player.flip_x = true
 end
 --[[not working.. let fall
 if btn(3) and player.grounded
 and player.y+player.ch*0.5<122 then
  player.grounded = false
  player.y+=3
  --player.flip_x = true
 end
 --]]
 
 if btn(4) then
  pobj.vx=-1
 end
 if btn(5) then 
  pobj.vx=1
 end
end

-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------


__gfx__
bbbbbb00000000bbbbbb00000000bbbbbbb0000000000bbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb0000000000bbbbb0044444400bbbb00004544540000bbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb00000000000bbbb004444444400bb0054045445404500bb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb000000000000bbbb066666665560bb0454045445404540bb088008800bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00055f7ff00bbbbb00555555555500b0454045445404540bb078007800bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb555f0ff00bbbbb05454545454540b0454045445404540bb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb15ffffffbbbb00545454545454000454045445404540bbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb155555555bbb04545454545454500454045445404540bbb000000bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb91115555555bbb04545454545454500454045445404540bbbbbb0b0b00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb1111d555555bbb04545454545455500454045995404540bbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb1111d66d10bbbb04545454545454500000000990000000bbbb0bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb1111d66d10bbbb00666666656555000222022992202220bbbb00bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb110009900bbbbbb05555555555550b0444044444204420bbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbff444b555bbbbbb00454545454500b0442024444204220bbbbb0bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb44b555bbbbbbb005454555500bb0922022222202290bbbbb0bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb99bb555bbbbbbb0000000000bbb0000000000000000bbbbb0bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b5b5b5b5bbbbbbbb50065bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
050505056565565650605bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
404040405454545450005bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4040404045454544b555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0505050565655656bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b5b5b5b500000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444454445444454444444544444454444444544454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454444444544444454444445444454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454444444544444454444445444454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454454444544444454444445444454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454454444544444454444445444454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454454444544444454444445444454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454454444544444454444445444454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444545445444454454444544444454444445454454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445445445444454454444544444454444454454454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445445445444454454444544444454444454454454444544544445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445445445444454444444544444454444454454454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444445444454444444544444454444454444454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444445444454444444544544454444454444454444544444445445444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444445444454444444544544454444454444454444544444445445444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454444444544544454444445444454444544444445445444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444454444444544444454444445444454444544444445444444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444445444444454444454444445444454444454444444544444544bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444445444444454444544444445444454444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544445444445444444454444544444445444454444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544454444445444444454444544444445444544444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544454444445444444454444544444445444544444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544454445445444444454444544444445444544454454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544454445445444444454444544444445444544454454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4444544454445444544444454444544444445444544454445444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444454445444544444454444544444454444544454445444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444454445444544444454444544444454444544454445444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444454444444544444454444544444454444544444445444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445444454444444544444454444544444454444544444445444544544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4555555555555544544444454444544444445444544444444444544544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4555555544444455555555555555555544445444544444454444544544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
5554444455555555555555555555555544445445544444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
4445555555555555555555444444444444445445444444454444444544445444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8888eee8888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55ee5eee5e5555555566566656665555565656665555555555555bbb5b555bbb5575555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5555555656565655655555565655565555577755555b555b555b5b5755555555555555555555555555555555555555555555555555555555555555
5e555eee5e5555555656566555655555566656665555555555555bb55b555bb55755555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5555555656565655655555555656555555577755555b555b555b5b5755555555555555555555555555555555555555555555555555555555555555
55ee5e5e5eee55555665566656655666566656665555555555555b555bbb5b5b5575555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
556656665666555556565555555555555566566656665555556656565555555555555566566656665555556656565555575755555ccc55555ccc557555555555
565656565565555556565555557555555656565655655555565556565555557555555656565655655555565556565555557555555c5c55555c55555755555555
565656655565555556665555577755555656566555655555565556665555577755555656566555655555565556665555577755555c5c55555ccc555755555555
565656565565555555565555557555555656565655655555565555565555557555555656565655655555565556565555557555555c5c5555555c555755555555
566556665665557556665555555555555665566656655575556656665555555555555665566656655575556656565555575755555ccc55c55ccc557555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555566556656555566566656665665555555665666566656665555555555555555555555555555555555555555555555555555555555555555555555555555
55555655565656555655565655655656555556555565555656555555555555555555555555555555555555555555555555555555555555555555555555555555
55555655565656555655566555655656555556665565556556655555555555555555555555555555555555555555555555555555555555555555555555555555
55555655565656555656565655655656555555565565565556555555555555555555555555555555555555555555555555555555555555555555555555555555
55555566566556665666565656665666557556655666566656665555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ddd55dd5d5d5ddd55555d555ddd5ddd5ddd5ddd5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ddd5d5d5d5d5d5555555d555d555d5555d5555d5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5d5d5d5d5dd555555d555dd55dd555d555dd5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5d5d5ddd5d5555555d555d555d5555d555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5dd555d55ddd55555ddd5ddd5d5555d555d55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555aaaaa55555555555555555555555
55555566566656665555565656565555555755555ccc55555eee5ee55ee55555556656665666555556565665555557555555accaa5555eee5e5e5eee5ee55555
55555656565655655555565656565555557555555c5c55555e5e5e5e5e5e5555565656565565555556565565555555755555aacaa55555e55e5e5e555e5e5555
55555656566555655555565655655555575555555c5c55555eee5e5e5e5e5555565656655565555555655565555555575555aacaa55555e55eee5ee55e5e5555
55555656565655655555566656565555557555555c5c55555e5e5e5e5e5e5555565656565565555556565565555555755555aacaa55555e55e5e5e555e5e5555
55555665566656655575556556565555555755555ccc55555e5e5e5e5eee5555566556665665566656565666555557555555accca55555e55e5e5eee5e5e5555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55ee5eee5555566656565555555555555566566656665555565656655555555555665666566655555656566655555ee555ee5555555555555555555555555555
5e5e5e5e5555556556565555577755555656565655655555565655655555555556565656556555555656555655555e5e5e5e5555555555555555555555555555
5e5e5ee55555556556665555555555555656566555655555566655655555555556565665556555555666566655555e5e5e5e5555555555555555555555555555
5e5e5e5e5555556555565555577755555656565655655555555655655575555556565656556555555556565555555e5e5e5e5555555555555555555555555555
5ee55e5e5555566656665555555555555665566656655666566656665755555556655666566556665666566655555eee5ee55555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5eee55555566556656555566566656665665577555665666566655555656566555555cc555775775566656565577555551ee5e5e5eee5ee5555555555555
55e55e55555556555656565556555656556556565755565656565565555556565565555555c555575755556556565557555517155e5e5e555e5e555555555555
55e55ee5555556555656565556555665556556565755565656655565555555655565577755c555575755556556665557555517715eee5ee55e5e555555555555
55e55e55555556555656565556565656556556565755565656565565555556565565555555c555575755556555565557555517771e5e5e555e5e555555555555
5eee5e5555555566566556665666565656665666577556655666566556665656566655555ccc5577577556665666557755551777715e5eee5e5e555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555551771155555555555555555555555
55555eee5eee5eee5e5e5eee5ee555555ccc5ccc5c5c5ccc55555555555555555555555555555555555555555555555555555117155555555555555555555555
55555e5e5e5555e55e5e5e5e5e5e555555c55c5c5c5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ee55ee555e55e5e5ee55e5e555555c55cc55c5c5cc555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e5e5e5555e55e5e5e5e5e5e555555c55c5c5c5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e5e5eee55e555ee5e5e5e5e555555c55c5c55cc5ccc55555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5ee55ee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ee55e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5e5e5eee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ee55ee5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5e5e555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5e5e555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5e5e555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5eee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ddd55dd5d5d5ddd55555ddd5ddd55dd5d5d5ddd5ddd555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ddd5d5d5d5d5d5555555d5d55d55d555d5d55d5555d555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5d5d5d5d5dd555555dd555d55d555ddd55d555dd555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5d5d5ddd5d5555555d5d55d55d5d5d5d55d55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5d5d5dd555d55ddd55555d5d5ddd5ddd5d5d55d555d5555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555566566656665555565656565555575555555ccc55555eee5ee55ee555555566566656665555565656665555555755555cc55ccc5ccc5557556655665655
55555656565655655555565656565555557555555c5c55555e5e5e5e5e5e555556565656556555555656555655555575555555c5555c5c5c5575565556565655
55555656566555655555565655655555555755555c5c55555eee5e5e5e5e555556565665556555555565566655555755555555c55ccc5ccc5575565556565655
55555656565655655555566656565555557555555c5c55555e5e5e5e5e5e555556565656556555555656565555555575555555c55c555c5c5575565556565655
55555665566656655575556556565555575555555ccc55555e5e5e5e5eee55555665566656655666565656665555555755555ccc5ccc5ccc5755556656655666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55ee5eee5555566656565555555555555566566656665555565656655555555555665666566655555656566655555ee555ee5555555555555555555555555555
5e5e5e5e5555556556565555577755555656565655655555565655655555555556565656556555555656555655555e5e5e5e5555555555555555555555555555
5e5e5ee55555556556665555555555555656566555655555566655655555555556565665556555555666566655555e5e5e5e5555555555555555555555555555
5e5e5e5e5555556555565555577755555656565655655555555655655575555556565656556555555556565555555e5e5e5e5555555555555555555555555555
5ee55e5e5555566656665555555555555665566656655666566656665755555556655666566556665666566655555eee5ee55555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5eee55555566556656555566566656665665577555665666566655555656566555555cc55577577556665656557755555eee5e5e5eee5ee5555555555555
55e55e55555556555656565556555656556556565755565656565565555556565565557555c555575755556556565557555555e55e5e5e555e5e555555555555
55e55ee5555556555656565556555665556556565755565656655565555555655565577755c555575755556556665557555555e55eee5ee55e5e555555555555
55e55e55555556555656565556565656556556565755565656565565555556565565557555c555575755556555565557555555e55e5e5e555e5e555555555555
5eee5e5555555566566556665666565656665666577556655666566556665656566655555ccc55775775566656665577555555e55e5e5eee5e5e555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5eee5eee5e5e5eee5ee555555ccc5ccc5c5c5ccc55555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e5e5e5555e55e5e5e5e5e5e555555c55c5c5c5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ee55ee555e55e5e5ee55e5e555555c55cc55c5c5cc555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e5e5e5555e55e5e5e5e5e5e555555c55c5c5c5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e5e5eee55e555ee5e5e5e5e555555c55c5c55cc5ccc55555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228222888282828222822288888888888888888888888888888888888882288222822882228882822282288222822288866688
82888828828282888888888282828882882882828882828888888888888888888888888888888888888888288882882882888828828288288282888288888888
82888828828282288888822282828822882882228882822288888888888888888888888888888888888888288222882882228828822288288222822288822288
82888828828282888888828882828882882888828882888288888888888888888888888888888888888888288288882888828828828288288882828888888888
82228222828282228888822282228222828888828882822288888888888888888888888888888888888882228222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
6061626363626160616260616263636200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445464744454647444546474445464700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455565754555657545556575455565700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465666764656667646566676465666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3435363734353637343536373435363700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445464744454647444546474445464700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455565754555657545556575455565700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465666764656667646566676465666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3435363734353637373435363735363700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445464744454647474445464745464700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455565754555657575455565755565700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465666764656667676465666765666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5444646566674546473132333031323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6454555657545556574142434041424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5064656667646566675152535051525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626360616263606162636061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
