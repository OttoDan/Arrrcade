pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-------------------------------
--arrrcade--
--samia r. & daniel o.
--v2
-------------------------------

--[[to do
-

-rearrange objects:draw
  objects are drawn in order of 
  appearance -split up in
  unique loops :(
  
-add objects.chars.falldown for 
 enemies
  skeleton follows player verti- 
  cally, jumps when player is 
  higher but does not jump down
  when player is underneath him
  
-improve aiming and shooting
  shooting should feel good(?)
  *projectiles cause damage on
  blocks
   

-add objects.blocks.damage 
  destructible behaviour 
  for blocks
  *blocks use objects.blocks.hp
  *blocks are removed and split
  up into broken parts which fade out

-implement explosion
  *replace test explosion with
   sprite animation
  *add explosion smoke particles
  *add explosion damage area 
  
-test remove stacking
 of characters
  should characters be able to
  stand on each others heads?
--]]
-------------------------------
--game loop
function _init()
 debug = true
 player_init()
 level:init()
end


function _update()
 
 objects:update()
 player_update()
 explosion:update()

 
 --debug on off
 if btnp(0,1) then
  if debug then 
   debug = false
  else
   debug = true
  end
 end
 
end

test = false
function _draw()
 cls(4)
 palt(0,false)--black -> opaque
 palt(11,true)--green -> transparent


 level:draw()
 objects:draw()
 explosion:draw()
 
 print("hp:"..player.hp)
 
 --debug....---
 if debug then
  print("cpu: "..stat(1)
   .."\nblc: "..#objects.blocks
   .."\nchr: "..#objects.chars
   .."\nitm: "..#objects.items
   .."\npjt: "..#objects.projectiles
  ,0,0)
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
 gravity =  0.25
}


function level:init()
 --create plattform in level center
 for i=0,16 do
  objects.blocks:create(i*8,64,obj_platform)
 end
 --create test player and block
 
  objects.chars:create(32,82,obj_jack)
-- objects.blocks:create(64,16,obj_chest)
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
  spr(12,i*8,64)
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


when there are lots of objects 
drop bombs rather than more objects

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
obj_cw = {} obj_ch = {}

--
obj_cade = 1
obj_sx[obj_cade] = 0
obj_sy[obj_cade] = 0
obj_sw[obj_cade] = 16
obj_sh[obj_cade] = 16
obj_cw[obj_cade]  = 5
obj_ch[obj_cade]  = 12
--
obj_jack = 7
obj_sx[obj_jack]  = 0
obj_sy[obj_jack]  = 16
obj_sw[obj_jack]  = 16
obj_sh[obj_jack]  = 16
obj_cw[obj_jack]  = 5
obj_ch[obj_jack]  = 12
--
obj_dan = 8
obj_sx[obj_dan]  = 32
obj_sy[obj_dan]  = 16
obj_sw[obj_dan]  = 16
obj_sh[obj_dan]  = 16
obj_cw[obj_dan]  = 5
obj_ch[obj_dan]  = 12
--
obj_barrel = 2
obj_sx[obj_barrel]  = 0
obj_sy[obj_barrel]  = 32
obj_sw[obj_barrel]  = 16
obj_sh[obj_barrel]  = 16
obj_cw[obj_barrel]  = 12
obj_ch[obj_barrel]  = 16
--
obj_chest = 3
obj_sx[obj_chest]  = 0
obj_sy[obj_chest]  = 48
obj_sw[obj_chest]  = 16
obj_sh[obj_chest]  = 16
obj_cw[obj_chest]  = 12
obj_ch[obj_chest]  = 16
--
obj_brokenwood = 4
obj_sx[obj_brokenwood]  = 120
obj_sy[obj_brokenwood]  = 0
obj_sw[obj_brokenwood]  = 8
obj_sh[obj_brokenwood]  = 8
obj_cw[obj_brokenwood]  = 1
obj_ch[obj_brokenwood] = 1
--
obj_platform = 5
obj_sx[obj_platform]  = 104
obj_sy[obj_platform]  = 0
obj_sw[obj_platform]  = 8
obj_sh[obj_platform]  = 8
obj_cw[obj_platform]  = 8
obj_ch[obj_platform]  = 2
--
obj_cannonball = 6
obj_sx[obj_cannonball]  = 112
obj_sy[obj_cannonball]  = 0
obj_sw[obj_cannonball]  = 5
obj_sh[obj_cannonball]  = 5
obj_cw[obj_cannonball]  = 6
obj_ch[obj_cannonball]  = 6


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
  groundobj = nil,
  letfall = false,
  cx,cy,
  cw,ch,
  --animation
		findex = 1,
  ffreq  = 18,
  astate = 1,--
  frames = {},
  --combat			
  cooldown =0,
  damage=false,
  hp = 5,
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
 if _t == obj_cade then
  obj.frames = { 
		 {0,0}, --1 = none
		 {0,1}, --2 idle
		 {0,5},  --3 jump up
		 {0,3},  --4 jump down
		 {0,4}  --5 walk 
		}
		obj.hp = 100
 elseif _t == obj_jack then
  obj.frames = { 
		 {0,0}, --1 = none
		 {0,1}, --2 idle
		 {0,5},  --3 jump up
		 {0,3},  --4 jump down
		 {0,4}  --5 walk 
		}
		obj.hp = 10
 end
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
  obj.vx = flr(-rnd(1)+rnd(1))
--  obj.vy = --flr(4 +rnd(4))
 end
 --save to table
 add(objects.blocks,obj)
 return obj
end


function objects.projectiles:create(_x,_y,_vx,_vy,_t)
 local obj = objects:create(_x,_y,_t)
 obj.vx = _vx
 obj.vy = _vy
 add(objects.projectiles,obj)
 return obj
end

frame = 0
function objects:update()
 frame += 1 
 frame %= 16
 
 objects.chars:update()
 objects.blocks:update()
 objects.projectiles:update()
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
  if chr.damage then
   chr.hp -=1 
   chr.damage = false
  end
  if chr.t ~= obj_cade then
   enemy_update(chr)
  end
  --animation
  chr.astate = 2 -- idle
  if chr.vx ~= 0 then
   chr.astate = 5 -- walk
  end
  if chr.vy < 0 then
   chr.astate = 3 --jump down
  elseif chr.vy > 0 then
   chr.astate = 4 --jump up
  end
     
 	if (frame%chr.ffreq == 0) then
 		chr.findex += 1
 		if (chr.findex > #chr.frames[chr.astate]) then
 			chr.findex = 1
 		end
 	end

  --ground if on bottom
  if chr.y+chr.sh*0.5 > 124 then
   chr.grounded = true
   chr.vy = 0
  end
  --move by velocity
  chr.x += chr.vx
  --not grounded (falling)
  if not chr.grounded then
   --save old position
   local old = {x=chr.x, y=chr.y}
   
   --add gravity
   chr.vy += level.gravity
   --fall 
   chr.y += chr.vy
   
   --check for collision when falling
   if chr.vy > 0 then
    for k, v in pairs(objects) do
     if type(v)=="table" then
      for other in all(v) do
       if other ~=chr 
        and other.t ~= obj_cannonball
        and not (other.t == obj_platform and other.damage)
       then
        if chr.letfall==false or (chr.letfall and other~=chr.groundobj and other.y<=chr.y) then
         if collision(chr,other) then
          other.grounded = false
          chr.x = old.x
          chr.y = old.y
          chr.vy = 0
          chr.groundobj = other
          chr.grounded = true
         end
        end
       end
      end
     end
    end
   end 
  --grounded(not moving)
  else
   chr.letfall = false
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
  
  --delete when out of screen
  if objects:leftscreen(blk) then
   del(objects.blocks,blk)
  end
  
  --test destroy a chest when hit by chest
  if blk.damage then
   blk.hp-=1
   if blk.hp<= 0 then
    if blk.t == obj_chest then
     objects.blocks:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
     obj_brokenwood)
     objects.blocks:create(
      blk.x+blk.cw*0.25,
      blk.y-blk.ch*0.25,
     obj_brokenwood)
     objects.blocks:create(
      blk.x-blk.cw*0.25,
      blk.y+blk.ch*0.25,
     obj_brokenwood)
     objects.blocks:create(
      blk.x+blk.cw*0.25,
      blk.y+blk.ch*0.25,
     obj_brokenwood)
     explosion:create(blk.x,blk.y)
    end
    if blk.t == obj_platform then
     objects.blocks:create(
      blk.x,
      blk.y,
     obj_brokenwood)
    end
    del(objects.blocks,blk)
   end
   --damage calc over .. reset
   blk.damage = false
  end

  --ground if on bottom
  if blk.y+blk.sh*0.5 > 124 then
   --let cannonballs and platforms pass
   if blk.t  ~= obj_platform 
   and blk.t ~= obj_cannonball then
    blk.grounded = true
   end
  end

  --not grounded (falling)
  if blk.grounded == false then
   --save old position
   local old = {x=blk.x, y=blk.y}
   
   --player controlled fall
   if pobj == blk then
    blk.x += blk.vx
    blk.y += blk.vy
   --normal fall
   else
    --move by velocity
    blk.x += blk.vx
    --add gravity
    blk.vy += level.gravity
    --fall 
    blk.y += blk.vy
   end
    
   
   --check for collision
   for k, v in pairs(objects) do
    if type(v)=="table" then
     for other in all(v) do
      if other ~=blk
      --ignore those objects
      and other ~= player 
      and other.t ~= obj_jack
      then
       if collision(blk,other) 
       and (other.t == obj_platform and other.damage) ==false
       and other.t ~= obj_cannonball
       then
        other.grounded = false
        --other.damage = true
        blk.x = old.x
        blk.y = old.y
        blk.vy = 0
        blk.grounded = true
       end
      end
     end
    end
   end
   
   
   
  --grounded(not moving)
  else
  
   --disable pobj
   if pobj == blk then
    pobj = nil
   end
   --recheck all 8 frames
   if frame == 0 and blk.t ~= obj_platform then
    blk.grounded = false
   end
  end
 end
end

function objects.projectiles:update()
 for pjt in all(objects.projectiles) do
 
  --delete when out of screen
  if objects:leftscreen(pjt) then
   del(objects.projectiles,pjt)
  end
  
  pjt.x += pjt.vx
  pjt.y += pjt.vy
  for chr in all(objects.chars) do
  	if chr ~= player 
  	and collision(pjt,chr) then
  	 chr.damage = true
    explosion:create(pjt.x,pjt.y)
   	del(objects.projectiles,pjt)
  	end
  end
 end
end

function objects:draw()
 for k, v in pairs(objects) do
  if type(v)=="table" then
   for obj in all(v) do
    if obj.t ~= obj_cade then
     local sxanimation =0
     if obj.t == obj_jack or obj.t == obj_dan then
      sxanimation = obj.frames[obj.astate][obj.findex]*obj.sw
     end
     sspr(
      obj.sx+sxanimation,
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
    end
    if debug then
     
     rect(
      obj.x-obj.cw*0.5,
      obj.y-obj.ch * 0.5,
      obj.x+obj.cw*0.5,
      obj.y+obj.ch * 0.5,
      7
     )
     line(obj.x,obj.y,obj.x+obj.vx,obj.y+obj.vy)
     print("hp: "..obj.hp
           .."\ngrnd: "..tostr(obj.grounded)
     
     ,obj.x-20,obj.y-20)
     
     line(obj.x-20,obj.y-20,obj.x,obj.y)
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
     player.sx+player.frames[player.astate][player.findex]*player.sw,
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
    if debug then
     rect(
      player.x-player.cw*0.5,
      player.y-player.ch * 0.5,
      player.x+player.cw*0.5,
      player.y+player.ch * 0.5,
      7
     )
    end
end
-------------------------------
--explosion
explosion = {}

function explosion:create(_x,_y)
 local exp = {
  x = _x,
  y = _y,
  cw = 1,
  ch = 1,
  fr = 0
 }
 add(explosion,exp)
end
function explosion:update()
 for exp in all(explosion) do
  exp.cw +=0.25
  exp.ch +=0.25 
  exp.x-=0.01
  exp.y-=0.01
 
  if exp.cw > 8 then
   --spread damage
   for k, v in pairs(objects) do
    if type(v)=="table" then
     for other in all(v) do
      if collision(exp,other) then
       other.damage = true
      end
     end
    end
    del(explosion,exp)
   end
  end
 end
end
function  explosion:draw()
 for exp in all(explosion) do
  --debug circ
 --[[ circfill(
   exp.x,
   exp.y,
   exp.cw,
   8
  )
  circ(
   exp.x,
   exp.y,
   exp.cw*1.5,
   8
  )
  --]]
  sspr(
   112,8,
   8,8,
   exp.x,exp.y,
   exp.cw*4,exp.ch*4
  )
 end
end
-------------------------------
--player (mirror of char 1)
player = {}
function player_init()
 player = objects.chars:create(32,2,obj_cade) 
end
pframe = 0
function player_update()
 --reset vel x
 player.vx = 0 
 --block drop
 pframe +=1 
 pframe %= 64
 if pframe == 0 then
  --spawn object
  local nextobj
  if rnd(10)>=5 then 
   nextobj = obj_chest
  else
   nextobj = obj_barrel
  end
  
  if pobj~=nil and pobj.grounded == false 
  or pobj == nil then
   pobj = 
   objects.blocks:create(rnd(128),2,nextobj)
   pobj.vy = 1
  end
 end
 
 if player.cooldown > 0 then
  player.cooldown-= 1
 end
 --shoot with space
 if btn(1,1) then
  if player.cooldown<=0 then
   local _vx=0
   local _vy=0
   if btn(0) then
    _vx = -1
   end
   if btn(1) then
    _vx = 1
   end
   if btn(2) then
    _vy = -1
   end
   if btn(3) then
    _vy = 1
   end
   
   player.vx += - _vx
   if _vx ~= 0 or _vy ~= 0 then
    player.cooldown = 12
    objects.projectiles:create(
     player.x,player.y,
     _vx*4,_vy*4,
     obj_cannonball)
   end
  end
 --no violence? move then...
 else
  if btn(0) then
   player.vx = -1
   player.flip_x = true
  end
  if btn(1) then
   player.vx = 1
   player.flip_x = false
  end
  
  if btn(2) and player.grounded then
   player.vy = -3.5
   player.grounded = false
   player.y-=3
   --player.flip_x = true
  end
  if btn(3) and player.grounded 
  and player.groundobj ~= nil then
   player.letfall = true
   player.grounded = false
  -- player.vy = 1
  -- player.y+=2
  end
 end
 --[[not working.. let fall
 if btn(3) and player.grounded
 and player.y+player.ch*0.5<122 then
  player.grounded = false
  player.y+=3
  --player.flip_x = true
 end
 --]]
 
 if btnp(4) and pobj~=nil then
  pobj.x-=8
 end
 if btnp(5) and pobj~=nil then 
  pobj.x+=8
 end
end
function enemy_update(chr)
 if chr.cooldown>0 then
  chr.cooldown-=1
 end
 if chr.hp <= 0 then
  del(objects.chars,chr)
 end
--jack .. a skeleton with a sword
 if chr.t == obj_jack then
  
  --get horizontal distance to player
  if abs(player.x-chr.x) < 10 then
   --close enough for melee?
   if abs(player.y-chr.y) < 8 
   --cooldown passed
   and chr.cooldown <= 0 then
    --player.hp -= 1
    chr.astate = 2
    player.damage = true
    chr.cooldown = 24
   --to high for melee? jump randomly
   elseif chr.grounded then
    chr.vy = -3.5
    chr.y-=3
    chr.grounded = false
   end
  --not close enough .. get closer
  else
   if player.x > chr.x then
    chr.vx = 1
    chr.flip_x = true
   else
    chr.vx = -1
    chr.flip_x = false
   end
  end
 end
--dan a skeleton with a bomb 
 if chr.t == obj_dan then
   
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
bbbbbb0006600bbbbbbbbbbbbbbbbbbbbbbbb000660bbbbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbbbbbbbbbbbbb555bbbbbbbb000b
bbbb0000600000bbbbbbbb0006600bbbbbb0000600000bbbbbbb0000600000bbbbbb0000600000bbbbbb0000600000bbb5b5b5b5bbbbbbbb50065bbbb0004440
bbb00000600000bbbbbb0000600000bbbb00000600000bbbbbb00000600000bbbbb00000600000bbbbb00000600000bb050505056565565650605bbb04444540
bb000000066000bbbbb00000600000bbb000000066000bbbbb000000066000bbbb000000066000bbbb000000066000bb404040405454545450005bbb04544540
b00055f7ff00bbbbbb000000066000bb00055f7ff00bbbbbb000bbbbbbbbbbbbb00055f7ff00bbbbb00055f7ff00bbbb4040404045454544b555bbbb04555540
bbb555f0ff00bbbbb00055f7ff00bbbbbb555f0ff00bbbbbbbbb55f7ff00bbbbbbb555f0ff00bbbbbbb555f0ff00bbbb0505050565655656bbbbbbbb0445440b
bbbb15ffffffbbbbbbb555f0ff00bbbbbbb15ffffffbbbbbbbb555f0ff00bbbbbbbb15ffffffbbbbbbbb15ffffffbbbbb5b5b5b5bbbbbbbbbbbbbbbbb044040b
bbbb155555555bbbbbbb15ffffffbbbbbbb155555555bbbbbbbb15ffffffbbbbbbbb155555555bbbbbbb155555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbb00b0bb
bb91115555555bbbbbbb155555555bbbb91115555555b555bbbb155555555bbbbb91115555555bbbbb91115555555bbbbbbbbbbbb98888b9abbbbbabbbb9bbbb
bb1111d555555bbbbb91115555555bbbb1111d555555045bbb91115555555bbbbb1111d555555bbbbb1111d555555bbbbbbbbb9b8899988bbab66bbbbbb5bbbb
bb1111d66d10bbbbbb1111d555555bbbb1111d66d10004bbbb1111d555555bbbb11111d66d10bbbbb11111d66d10bbbbb99aaabb89aa998bbb66666bbb000bbb
bb1111d66d10bbbbbb1111d66d10bbbbb1111d66d10bb4bbb11111d66d10bbbbb11b11166d10bbbbb11b11d66d10b0bbbb99aaabbaa77a88b666666ab00550bb
bb110009900bbbbbbb1111d66d10bbbbb110009900bbbbbbb11b11d66d10bbbbbffb00099000bbbbbffb0009900000bbbb9aaaab89a77798b566666b0000550b
bbff444b000bbbbbbb110009900bbbbbbff444b000bbbbbbbffb0009900bbbbbbbbbb444000bbbbbbbbb444bb00000bbbb9a999b899aa989bb56665b0000000b
bbbbb44b000bbbbbbbffb44b000bbbbbbbbb44b000bbbbbbbbbbb44400bbbbbbbbbbbb4440bbbbbbbb9444bbbbbbbbbbb9bb99bbb889888bb566655b0100000b
bbbbb99bb000bbbbbbbbb99bb000bbbbbbbb99bb000bbbbbbbbbbb99000bbbbbbbbbbbb0900bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbb9b555b9b01110bb
bbbbbbb05550bbbbbbbbbbb05550bbbbbbbbbbb05550bbbbbbbbbbb05550bbbbb6bbbbb05550bbbbb6bbbbb05550bbbbb00b00bbbb0000bbbbbbbbbbbbbbbbbb
bbbbbb0555550bbbbbbbbb0555550bbbbbbbbb0555550bbbbbbbbb0555550bbbb66bbb0555550bbbb66bbb0555550bbb0e80880bb0aaa40bbbbbbbbbbbbbbbbb
bbbbb055555550bbbbbbb055555550bbbbbbb055555550bbbbbbb055555550bbb66bb055555550bbb66bb055555550bb08e8820b0a999940bbbbbbbbbbbbbbbb
b6bbb088558850bbbbbbb088558850bbb6bbb088558850bbb6bbb088558850bbb66bb088558850bbb66bb088558850bb0888820b0a9a9940bbbbbbbbbbbbbbbb
b66bb008557850bbbbbbb078557850bbb66bb078557850bbb66bb008557850bbb66bb008557850bbb66bb008557850bbb08820bb0a9aa440bbbbbbbbbbbbbbbb
b66bb055555550bbbbdbb055555550bbb66bb055555550bbb66bb055555550bbb66bb055555550bbb66bb055555550bbbb020bbb04994a40bbbbbbbbbbbbbbbb
b66bbb05555509bbbbdbbb05555509bbb66bbb05555509bbb66bbb05555509bbbb66bb05555509b8bb66bb05555509b8bbb0bbbbb044440bbbbbbbbbbbbbbbbb
b66bbb0505050bbbbdbbbb0505050bbbb66bbb0505050bbbb66bbb0505050bbbbb65bb0505050bb0bb65bb0505050bb0bbbbbbbbbb0000bbbbbbbbbbbbbbbbbb
b66bbbbbbb050bbbbdbbbbbbbb050bbbb66bbbbbbb050bbbb66bbbbbbb050bbbbbb50bbbbb050b0bbbb50bbbbb050b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb66bbb22211222bbdbdbbb22211222bbb66bbb22211222bbb66bbb22211222bbbb55bb02211220bbbb55bb02211220bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb65b0002211220bdbbdbbb02211220bbd65b0002211220bbb65b0002211220bbbbb500b221122bbbbbb500b221122bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb500bb221122b0dbbdbb0b221122b0dbb500bb221122b0bbb500bb221122b0bbbbbbbb221122bbbbbbbbbb221122bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb55bbbb11111b8dbbbd055b111118bdbb55bbbb11111b8bbb55bbbb11111b8bbbbbbbbb11111bbbbbbbbbbb11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb5bbb0bbbb0bbdbb6655b0bbb00bbdbbb5bbb0bbbb0bbbbbb5bbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bb66666bbbb0bb0bbbdbdbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb00bbb00bbbbbbbbb00bbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bb666bbbbbb0b0bbbbbbddbbbb0bbbb0bbbbbbbbbbb0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0044444400bbbbb44bb44bbbb4bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb004424222200bbb44bb55bbbbbb54bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00555555555500b44b455bbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbb6bbbbabbbbbbbbbb666bb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b05555111111110bbbb55bbbbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0445245255425440bbb4bbbbb554bbbbbbbbbb6bbbbbbbbbb555555b589bbbbbb555555b8a9bbbbbb555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0452452442522540bbbbbbbbbb554bbbbbbbbbbbbbbbbbbbb065666b5aa77bbbb065666baa7b77bbb065666bb6b99b9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0452452442542540bbbb54bbbbb554bbbbbbbbbbbbbbbbbbb0455bb589abbbbbb0455bb59aabbbbbb0455bbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0452452442542540bbbb54bbbbbb54bbbbbb6bbbbbbb666bb44bbbbb589bbbbbb44bbbbb569bbbbbb44bbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0452452442542520bbbb45bbbbbbbbbbbb6bbbbbbbbb66bbb4bbbbbbbbbbbbbbb4bbbb6b9bbbbbbbb4bbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0452452442522510bbbb455bbbbbbbbbbbbbbbbbbbbbb5bbb0bbbbb9b9bbbbbbb0bbb66bbb9bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0445245422525110bb44b455bbbbb44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb666bbbbabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b05555551521210bbbb44bbbbb555bbb66b4455bb44b44b6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00115111212100bbbbb44bbb44bbb4b666b444455555466bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb002221221200bbbbbbb4bbbbbbbbbb5644444444b44466bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000000bbbbbbbbbbbbbbbbbbb55b66444bb444b55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000000bbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00054444450000bbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0044544444450400bbb9b0ddddddd0bbbb9bb0ddddddd0bbb9bbb0ddddddd0bbbb9bb0ddddddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444544444452440b9bbb088dd88d0bbbbbbb088dd88d0bbbbb9b088dd88d0bbb9b9b088dd88d0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444544444452440bb89b078dd78d0bbb98bb078dd78d0bbbb8bb078dd78d0bbbb8bb078dd78d0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444544444452440bb5bb00dddddd0bbbb59b00dddddd0bbb95bb00dddddd0bbbb5bb00dddddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444044444252440bb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0424524442402420b000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444044242452240b0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0242042424202210b000b0018dddd81bb000b0018dddd81bb000b0018dddd81bb000b0018dddd80bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0525021995101120bbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb11bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000990000000bbbbbbbb11dbd8b8bbbbbbbb11dbd88bbbbbbbbb11dbd8b8bbbbbbbb11dbd8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0222022991101110bbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0222022222101110bbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0911021111101190bbbbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb0bbbbb0bbbbbbbbb00bbb08bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000000000000bbbbbbbb0bbbb8bbbbbbbbbbb0b8bbbbbbbbbbb0bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb05550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb055b550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb05b555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b6bbb088558b50bbbbbbbbbb5b55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b66bb008557850bbbbbbbb5bbbb550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb6bb055555550bbb6bbbbbb5b8b50bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b66bbb055555095bbbbbb00bbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b6bb5b0505050bbbbbbbb05bb5b550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb6bbbb22211222bb6b6bb0b5555095bbbbbbbbbbb5b5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb65b00b2211220bb6bb5bb5b5050bbbbbbbbbbb5bbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
6bb500b0b2b122b0bbbbbbbbbbbbbb0bbbb6bbbbbb51bb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb5bbbb111b1b8bb65b00b2211bbbbbbbbbbb01b1b78bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b6bbbb2b0bbb102b6bb500b0b2b122b0bbbbb2b05188b550bbbbbbbb651bb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0b1bb0bbbbbbbbbbb00bb0b8bbb5b5b512151152bbb60b01b157805bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb0ddd0bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0ddddd0bbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb9b0ddddddd0bbbb89bbb0ddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b9bbb088dd88d0bbbb5bbb0bddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb89b078dd78d0bbbb5bb0dbbdddb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bb00dddddd0bbbbb0b088dd88b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bbb0ddddd0bbbb00bb078bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000bb0d0d0d0bbbb000b0bbddddd0bbb9bbbbbbbbb0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0000bbbbb0d0bbbbbbbbb0dddd70bbbbb89bbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000b0018dddd81bbbbbbb0d0d0d0b0bbbb0bbbdbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11bbb10bbbbbbbbbbb0d0bb8b00bbbbddb88d0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11dbd8b8bbbbb0b1bbddd0b8bbb0bb088bbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbb1db88b8bbbbbbbb11bbbbbbbbbbbb078d0d0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbdddbbdbd8bbbbbbbbbbbb0bbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbbbbb1db88bbbbbbb0b1bbd7d0b8bbbbb9bbdb8bdb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb0bbbb8bbbbbbbbdb0bb0b0bbbbbbbbbb11bbbbbbbbb980d78b0d000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
149414521442134214941442144214421442111111111442d494d452d442d342d494d442d442d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144414521223344214441445122215421453555555553342d444d452d2233442d444d445d222d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111114521111334211111445111115421553555555555332ddddd452dddd3342ddddd445d111d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14421455144213421342144514321542155511111111d332d442d455d4421342d342d445d432d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1442145214421345144214451432154215511111111d1351d442d452d4421345d442d445d432d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144214521452134514321445153215421551111111d11352d442d452d4521345d432d445d532d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144214551452134514351445153215421551111111111332d442d455d452d345d435d445d532d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1442145514521345143514451533154515511111d1111d52d442d455d452d345d435d445d5331545bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144214551452144513451445153315451551111d111d1d52d442d4551452d445d345d445d533d545bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14451445144214451342144515451545155111d111d11d52d445d4451442d445d342d4451545d545bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1445144514421442134214451445154215511d111d111352d445d4451442d442d342d4451445d542bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144514451445144214421452144514421551d11111111d52d445d4451445d442d442d452d445d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14421445144514421452145214451442155d111111115d52d442d4451445d4421452d4521445d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1442144214421442145214521445144215555dddddddd551d442d442d442d442145214521445d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144212221442122214521223334512221255555555555521d442d222d442d222145212233345d222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
144211111342111115421111334511111222133213331231d442ddddd342d1dd1542dddd3345ddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1452144213421442154215323445144211dddd1111111111d452d442d342d4421542d5323445d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
145214421342144215451332144514424144444444433333d4521442d34214421545d3321445d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
145214421345144215451342144214422155224225522232d4521442d3451442d545d34214421442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14551442144514421545154215421442111111111111ddddd4551442d4451442d545d542d5421442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
145214421445144215451542154214424444441444444333d4521442d445d442d545d542d542d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
145215421442144215451442154214422422221225552222d4521542d442d442d545d442d542d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
145215421442145515451445154214421ddddd111111111dd452154214421455d545d445d542d442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14521542142514521445144515451445224233345544414514521542d425145214451445d545d445bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14521542142514521445144515451442bbbbbbbbbbbbbbbb14521542d425145214451445d5451442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14521542142514521445144514451452bbbbbbbbbbbbbbbb14521542d42514521445144514451452bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14551542145514521445144514451452bbbbbbbbbbbbbbbbd4551542d4551452d445144514451452bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14551542145514421445145514421452bbbbbbbbbbbbbbbbd4551542145514421445145514421452bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
12221542122214521252154512221455bbbbbbbbbbbbbbbbd222154212221452125215451222d455bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
11111522111114551111154211111455bbbbbbbbbbbbbbbbd11115221ddd145511111542d1111455bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14441522144214551444154514421445bbbbbbbbbbbbbbbb14441522144214551444154514421445bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14941422144214551494144514421445bbbbbbbbbbbbbbbb14941422144214551494144514421445bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
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
c6c7c8c9c6c7c8c9c6c7c8c9c6c7c8c900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6d7d8d9d6d7d8d9d6d7d8d9d6d7d8d900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e8e9e6e7e8e9e6e7e8e9e6e7e8e900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f8f9f6f7f8f9f6f7f8f9f6f7f8f900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c4c5c0f6f7f8f9c1c4c5c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d4d5d0d6d7d8d9d1d4d5d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e0e6e7e8e9e1e2e3e0e1e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f0f6f7f8f9f1f2f3f0f1f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d0d1d2d3d0d1d2d3d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1c4c5e0e1e2e3e0e1c4c5e0e1e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1d4d5f0f1f2f3f0f1d4d5f0f1f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d0d1d2d3d0d1d2d3d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e5e4e5e4e5e4e5e4e5e4e5e4e5e4e500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e5e4e5e4e5e4e5e4e4e5e4e5e4e5e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
