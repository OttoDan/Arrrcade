pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-------------------------------
--arrrcade--
--samia r. & daniel o.
--v10
-------------------------------

--[[to do
- item drop
- switch weapons
- melee combat

- broken not blocking and disappear
-screen shake when hit

-add death animation for skeletons

-dan shall throw bombs vertically

-rearrange objects:draw
  objects are drawn in order of 
  appearance -split up in
  unique loops :(

  
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

--falling blocks controlled by
  player (pobj) get stuck when 
  falling and hitting on x axis

--prevent player from leaving screen

done:
-implement explosion
  *replace test explosion with
   sprite animation
  *add explosion smoke particles
  *add explosion damage area 
-test remove stacking
 of characters
  should characters be able to
  stand on each others heads? 
-add objects.chars.falldown for 
 enemies
  skeleton follows player verti- 
  cally, jumps when player is 
  higher but does not jump down
  when player is underneath him
--]]
-------------------------------
--global defines (finetuning)
--design
player_hp = 5
player_speed = 1

blockdropfreq = 100--64

barrel_hp = 2
chest_hp = 2

enemy_spawnfreq = 64--durchschnittliche spawn freq

jack_hp = 3
jack_speed = 0.5

dan_hp = 3
dan_speed = 0.3
--performance
max_enemies = 16
collision_recheck_freq= 8
-------------------------------
--game loop
 game_intro = 0
 game_menu = 1
 game_running = 2
 game_won = 3
 game_over = 4

game_state = game_running
function _init()
 debug = false
 level:init()
 player_init()
 enemy:init()
 game_state = game_running
end

function _update()
 frame += 1 
 frame %= 128 
 
 if game_state == game_intro then
 
 elseif game_state == game_menu then
 
 elseif game_state == game_running then
  objects:update()
  player_update()
  explosion:update()
  
  block_drop()
  enemy:spawn()
  
  itemparticle:update()
  particles:update()
  spr_particles:update()
  
 elseif game_state == game_won then
 
 elseif game_state == game_over then
  level:clear()
  cam.x = lerp(
  cam.x,
  player.x,--mid( 58, player.x, 68),
  cam.speed
  )
  cam.y = lerp(cam.y,player.y,cam.speed)
  
  if (abs(cam.x-player.x) +
     abs(cam.x-player.x)) < 2
  then
   if player.astate < 6 then
    player.astate = 6
    player.ffindex = 1
    frame = 0
   end
   if frame % 126 == 0 
   and player.ffindex < 6
   then 
    player.ffindex +=1
   end
  end
  
  particles:update()
  if frame % 32 == 0 then
   particles:create(
    player.x-rnd(2)+rnd(2),
    player.y-rnd(2)+rnd(2),
    8,
    8+rnd(8)
   )
  end
 -- _init()
 end
 
 
 --debug on off
 if btnp(0,1) then
  if debug then 
   debug = false
  else
   debug = true
  end
 end
 
end


function _draw()
 cls(0)
 palt(0,false)--black -> opaque
 palt(11,true)--green -> transparent

 if game_state == game_intro then
 
 elseif game_state == game_menu then
 
 elseif game_state == game_running then
  
  level:draw()
  objects:draw()
  explosion:draw()
  particles:draw()
  spr_particles:draw()
  itemparticle:draw()
  --camera()
  
  ui:draw()
    
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
 elseif game_state == game_won then
  print ("game won",0,0,8)
 elseif game_state == game_over then
  print ("captain cade\n  is dead!",player.x-16,player.y-32,8)
  objects:draw()
  particles:draw()
  camera(cam.x-64,cam.y-64)
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
 --[[
 --create plattform in level center
 for i=0,16 do
 -- objects.blocks:create(i*8,64,obj_platform)
 end
 --create test player and block
 
-- objects.blocks:create(64,16,obj_chest)
 --create random cannonballs
 
 for i=0,4 do
  for j=0,8 do
   objects.blocks:create(
    j * 16 -rnd(8)+8,
    j*4,
    obj_cannonball
   )
  end
  objects.chars:create(
  i * 32 -rnd(8)+8,
  120,
  obj_jack)
 end
 ]]--
end


function level:draw()
 --background map
 map(0,8,0,0,16,16)
 for i=0,16 do
  spr(70,i*8,64)
 end
 --static objects map
-- map(0,0,0,0,16,16)
end

function level:clear()

 for k, v in pairs(objects) do
  if type(v)=="table" then
   for obj in all(v) do
    del(v,obj)
   end
  end
 end
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
obj_jack = 2
obj_sx[obj_jack]  = 0
obj_sy[obj_jack]  = 64
obj_sw[obj_jack]  = 16
obj_sh[obj_jack]  = 16
obj_cw[obj_jack]  = 5
obj_ch[obj_jack]  = 13
--
obj_dan = 3
obj_sx[obj_dan]  = 0
obj_sy[obj_dan]  = 80
obj_sw[obj_dan]  = 16
obj_sh[obj_dan]  = 16
obj_cw[obj_dan]  = 5
obj_ch[obj_dan]  = 13
--
obj_barrel = 4
obj_sx[obj_barrel]  = 0
obj_sy[obj_barrel]  = 32
obj_sw[obj_barrel]  = 16
obj_sh[obj_barrel]  = 16
obj_cw[obj_barrel]  = 12
obj_ch[obj_barrel]  = 16
--
obj_chest = 5
obj_sx[obj_chest]  = 0
obj_sy[obj_chest]  = 48
obj_sw[obj_chest]  = 16
obj_sh[obj_chest]  = 16
obj_cw[obj_chest]  = 12
obj_ch[obj_chest]  = 16
--
obj_brokenwood = 6
obj_sx[obj_brokenwood]  = 32
obj_sy[obj_brokenwood]  = 32
obj_sw[obj_brokenwood]  = 8
obj_sh[obj_brokenwood]  = 8
obj_cw[obj_brokenwood]  = 0
obj_ch[obj_brokenwood] = 0
--
obj_platform = 7
obj_sx[obj_platform]  = 56
obj_sy[obj_platform]  = 32
obj_sw[obj_platform]  = 8
obj_sh[obj_platform]  = 8
obj_cw[obj_platform]  = 8
obj_ch[obj_platform]  = 2
--
obj_cannonball = 8
obj_sx[obj_cannonball]  = 64
obj_sy[obj_cannonball]  = 32
obj_sw[obj_cannonball]  = 5
obj_sh[obj_cannonball]  = 5
obj_cw[obj_cannonball]  = 6
obj_ch[obj_cannonball]  = 6
--
obj_gun = 9
obj_sx[obj_gun]  = 0
obj_sy[obj_gun]  = 16
obj_sw[obj_gun]  = 16
obj_sh[obj_gun]  = 16
obj_cw[obj_gun]  = 0
obj_ch[obj_gun]  = 0
--
obj_sword = 10
obj_sx[obj_sword]  = 64
obj_sy[obj_sword]  = 16
obj_sw[obj_sword]  = 16
obj_sh[obj_sword]  = 16
obj_cw[obj_sword]  = 0
obj_ch[obj_sword]  = 0
--
obj_bomb = 11
obj_sx[obj_bomb]  = 72
obj_sy[obj_bomb]  = 40
obj_sw[obj_bomb]  = 7
obj_sh[obj_bomb]  = 8
obj_cw[obj_bomb]  = 8
obj_ch[obj_bomb]  = 8
--
obj_explosion = 12
obj_sx[obj_explosion]  = 48
obj_sy[obj_explosion]  = 40
obj_sw[obj_explosion]  = 8
obj_sh[obj_explosion]  = 8
obj_cw[obj_explosion]  = 0
obj_ch[obj_explosion]  = 0
--
obj_swordstrike = 13
obj_sx[obj_swordstrike]  = 88
obj_sy[obj_swordstrike]  = 24
obj_sw[obj_swordstrike]  = 5
obj_sh[obj_swordstrike]  = 8
obj_cw[obj_swordstrike]  = 5
obj_ch[obj_swordstrike]  = 5
--
obj_coin = 14
obj_sx[obj_coin]  = 72
obj_sy[obj_coin]  = 48
obj_sw[obj_coin]  = 8
obj_sh[obj_coin]  = 8
obj_cw[obj_coin]  = 4
obj_ch[obj_coin]  = 4
--
obj_heart = 15
obj_sx[obj_heart]  = 64
obj_sy[obj_heart]  = 48
obj_sw[obj_heart]  = 7
obj_sh[obj_heart]  = 7
obj_cw[obj_heart]  = 4
obj_ch[obj_heart]  = 4
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
  scale = 1,
  --combat			
  cooldown =0,
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
		 {0,4},  --5 walk 
		 {6,6,6,7,7,7}   --6 die
		}
		obj.hp = player_hp
		obj.speed = player_speed
 elseif _t == obj_jack then
  obj.frames = { 
		 {1,0}, --1 = attack
		 {0,1}, --2 idle
		 {2,3},  --3 jump up
		 {3,4},  --4 jump down
		 {1,2},  --5 walk 
		 {5,6,7,8} --6 die
		}
		obj.hp = jack_hp
		obj.speed = rnd(jack_speed*0.25)+jack_speed*0.75
 elseif _t == obj_dan then
  obj.frames = { 
		 {1,0}, --1 = attack
		 {0,1}, --2 idle
		 {2,3},  --3 jump up
		 {3,4},  --4 jump down
		 {1,2},  --5 walk 
		 {5,6,7,8} --6 die
		}
		obj.hp = dan_hp
		obj.speed = rnd(dan_speed*0.25)+jack_speed*0.75
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
 if _t == obj_chest then
  obj.hp = chest_hp
 end
 if _t == obj_barrel then
  obj.hp = barrel_hp
 end
 --save to table
 add(objects.blocks,obj)
 return obj
end


function objects.projectiles:create(_x,_y,_vx,_vy,_t,_owner)
 local obj = objects:create(_x,_y,_t)
 obj.vx = _vx
 obj.vy = _vy
 obj.owner = _owner
 if obj.t == obj_bomb then
  obj.cooldown = rnd(24) + 8
 elseif obj.t == obj_swordstrike then
  obj.cooldown = 6
 end
 add(objects.projectiles,obj)
 return obj
end

frame = 0
function objects:update()
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
 
  
  if chr.t ~= obj_cade then
   enemy:update(chr)
  end
  --animation update
  if (frame%chr.ffreq == 0) then
 		chr.findex += 1
 		if (chr.findex > #chr.frames[chr.astate]) then
 			chr.findex = 1
 		end
 	end
  if chr.hp>0 then
   if chr.damage then
    chr.hp -=1 
    particles:create(chr.x,chr.y,8)
    chr.damage = false
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
       
   --grounded if on bottom
   if chr.y+chr.sh*0.5 > 124 then
    chr.grounded = true
    chr.vy = 0
   end
   --move by velocity
   chr.x += chr.vx*chr.speed
   --not grounded (falling)
   if not chr.grounded then
    --save old position
    local old = {x=chr.x, y=chr.y}
    
    --add gravity + velocity
    --to pos (fall)
    chr.y += chr.vy*chr.speed
           + level.gravity
    --add gravity
    chr.vy += level.gravity
    --check for collision when falling
    if chr.vy > 0 then
   --  for k, v in pairs(objects) do
    --  if type(v)=="table" then
     --  for other in all(v) do
      --  if other ~=chr 
     for other in all(objects.blocks) do
      if chr.letfall==false
       or (chr.letfall
       and other ~= chr.groundobj
       and other.y <= chr.y)
      then
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
     --  end
    --  end
   --  end
    end 
    
   --grounded(not moving)
   else
   
    chr.letfall = false
    
    --recheck collision all 8 frames
    if frame%collision_recheck_freq== 0 then
     chr.grounded = false
    end
    
    --delete when out of screen
    if objects:leftscreen(chr) then
     del(objects.chars,chr)
    end
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
  if blk.t == obj_coin
  or blk.t == obj_heart
  then
   item_update(blk)
  end
  --damage
  if blk.damage then
   blk.hp-=1
   if blk.hp<= 0 then
    if blk.t == obj_chest
    or blk.t == obj_barrel then
     item_drop(blk.x,blk.y,blk.t) 
     particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      9,6
     )     
    end
    if blk.t == obj_coin then
     particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      10,6
     )  
    end
    if blk.t == obj_heart then
     particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      8,6
     )     
    end
    --[[
    if blk.t == obj_platform then
     spr_particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      obj_brokenwood,6
     ) 
    end--]]
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
      --ignore these objects
     -- and other ~= player 
      and other.t ~= obj_coin
      and other.t ~= obj_heart
      then
       if collision(blk,other) 
       and (other.t == obj_platform and other.damage) ==false
       and other.t ~= obj_cannonball
       then
        --if fast enough
        if blk.vy > 6
        then
         other.damage = true
        end
        
        --ignore chars for grounding
        if other ~= player 
         and other.t ~= obj_jack
         and other.t ~= obj_dan
        then
         blk.x = old.x
         blk.y = old.y
         blk.vy = 0
         blk.grounded = true
        end
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
   if frame %collision_recheck_freq == 0
    and blk.t ~= obj_platform then
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
  
  
  if pjt.t == obj_bomb then
   --spawn particles for bomb
   if frame%8 == 0 then
    local poffset 
    local pcolor 
    if rnd(10)>7 then
     pcolor = 9
    else
     pcolor = 10
    end
    particles:create(
     pjt.x - 2,
     pjt.y - 2,
     pcolor
     ,
     flr(rnd(4)+4)
    )
   end 
   pjt.cooldown-=1
   if pjt.cooldown<=0 then
    explosion:create(pjt.x-8,pjt.y-8)
    explosion:create(pjt.x+8,pjt.y+8)
    del(objects.projectiles,pjt)
   end
   
   pjt.vy += level.gravity
  elseif pjt.t == obj_swordstrike then
   pjt.cooldown-=1
   if pjt.cooldown<=0 then
    del(objects.projectiles,pjt)
   end
  end
  
  pjt.x += pjt.vx
  pjt.y += pjt.vy
  for chr in all(objects.chars) do
  	if chr ~= pjt.owner 
  	and collision(pjt,chr) then
  	 chr.damage = true
    if pjt.t == obj_bomb then
     explosion:create(pjt.x-8,pjt.y-8)
     explosion:create(pjt.x+8,pjt.y+8)
    end
    
   	del(objects.projectiles,pjt)
  	end
  end
 end
end

function objects:draw()
 --for k, v in pairs(objects) do
 -- if type(v)=="table" then
  -- for obj in all(v) do
   -- if obj.t ~= obj_cade then
 objects.blocks:draw()
 objects.chars:draw()
 player_draw()
 objects.projectiles:draw()
end
function objects.chars:draw()
 for obj in all(objects.chars) do
  local sxanimation =0
  if obj.t == obj_jack or obj.t == obj_dan then
   sxanimation = obj.frames[obj.astate][obj.findex]*obj.sw
 	end
  if obj ~= player then
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
   end
  end
 end
end
function objects.blocks:draw()
 for obj in all(objects.blocks) do
  local sxanimation = 0
  if obj.t == obj_chest or obj.t == obj_barrel then
   if obj.hp==1 then 
    sxanimation = 16
   end
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
  end 
 end
end

function objects.projectiles:draw()
 for obj in all(objects.projectiles) do
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
  end
 end
end

function player_draw()
 --hardcode overdraw player sprite
 sspr(
  player.sx+player.frames[player.astate][player.findex]*player.sw,
  player.sy,
  player.sw,
  player.sh,
  player.x - player.sw * 0.5,--upper left corner
  player.y - player.sh * 0.5,--of the sprite
  player.sw*player.scale,
  player.sh*player.scale,
  player.flip_x,
  player.flip_y
 )
 --playergun
 if player.invobj == obj_gun then
  sspr(
   playergun.sx+playergun.frames[playergun.astate][playergun.findex]*playergun.sw,
   playergun.sy,
   playergun.sw,
   playergun.sh,
   playergun.x - playergun.sw * 0.5,--upper left corner
   playergun.y - playergun.sh * 0.5,--of the sprite
   playergun.sw,
   playergun.sh,
   playergun.flip_x,
   playergun.flip_y
  )
 --player sword
 elseif player.invobj == obj_sword then
  sspr(
   playersword.sx+playersword.frames[playersword.astate][playersword.findex]*playersword.sw,
   playersword.sy,
   playersword.sw,
   playersword.sh,
   playersword.x - playersword.sw * 0.5,--upper left corner
   playersword.y - playersword.sh * 0.5,--of the sprite
   playersword.sw,
   playersword.sh,
   playersword.flip_x,
   playersword.flip_y
  )
 end
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
  
  sx = obj_sx[obj_explosion],
  sy = obj_sy[obj_explosion],
  sw = obj_sw[obj_explosion],
  sh = obj_sh[obj_explosion],
  cw = 1,
  ch = 1,
  
  damage = true,
  --animation
		findex = 1,
  ffreq  = 4,
  frames = {0,1,2}
 }
 add(explosion,exp)
 particles:create(_x,_y,9)
end
function explosion:update()
 for exp in all(explosion) do
  if frame % exp.ffreq == 0 then
   exp.findex += 1
    --cycled through animation frames?
   if exp.findex > #exp.frames then
    --smoke frame remains..
    exp.findex = #exp.frames
   end
  end
  --half through animation?
 -- if frame / exp.ffreq
 -- < exp.ffreq*#exp.frames*0.5
  if exp.findex == 1 then
   exp.cw += 3
   exp.ch += 3
 -- elseif frame / exp.ffreq
 -- == exp.ffreq*0.5
  elseif exp.findex == 2 then
   exp.cw += 4
   exp.ch += 4
   if exp.damage == true then
    --spread damage
    for k, v in pairs(objects) do
     if type(v)=="table" then
      for other in all(v) do
       if other.t ~= obj_coin
       and other.t ~= obj_heart then
        if collision(exp,other) then
         other.damage = true
        end
       end
      end
     end
    end
    exp.damage = false
   end
 -- elseif frame / exp.ffreq
 -- > exp.ffreq*0.5
  elseif exp.findex == 3 then
   exp.y -= 3
   
   exp.cw -= 0.5
   exp.ch -= 0.5
   
   if exp.cw < 0 then
    del(explosion,exp)
   end
  end
 end
end
function explosion:draw()
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
   exp.sx+exp.frames[exp.findex]*exp.sw,
   exp.sy,
   exp.sw,
   exp.sh,
   exp.x-exp.cw,exp.y-exp.ch,
   exp.cw*1.25,exp.ch*1.25
  )
 end
end


-------------------------------
--block drop
blockdropadd = 0
function block_drop()
 if frame % (blockdropfreq+blockdropadd) == 0 then
--  blockdropadd = flr(-rnd(32)+rnd(32))
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
   --snapped spawn? flr((rnd(128))/8)*8,0
   objects.blocks:create(flr((rnd(128))/8)*8,2,nextobj)
   pobj.vy = 1
  end
 end
end
-------------------------------
--player (mirror of char 1)
player = {}
playergun ={}
function player_init()
 player = objects.chars:create(64,8,obj_cade) 
 player.grounded = false 
 player.invobj = obj_sword
 player.coins = 0
 
 playersword = objects:create(player.x,player.y,obj_sword)
 playersword.frames = { 
		{0,0},--just hold it..
		{0,1}--swing
	}
	playersword.ffreq = 4
 
 playergun = objects:create(player.x,player.y,obj_gun)

 playergun.frames = { 
		{0,0},--just hold it..
		{0,1,2,3}--shoot
	}
	playergun.ffreq = 4
end

function player_update()
 if player.damage then
  itemparticle:create(ui.x+ player.hp * 10,ui.y,obj_heart,true)
 end
 --losing condition
 if player.hp <= 0 then
  game_state = game_over
 end
 --winning condition
 if player.y < 0 then 
  game_state = game_won
 end
 --player weapons lil messy hard code :(
 --gun---
 playersword.flip_x = player.flip_x
 playergun.flip_x = player.flip_x
 
 local psword_offset = 0
 if playersword.flip_x then 
  psword_offset = -14
 else
  psword_offset = 14
 end
 
 local pgun_offset = 0
 if playergun.flip_x then 
  pgun_offset = -14
 else
  pgun_offset = 14
 end

 playersword.x = player.x+psword_offset
 playersword.y = player.y+2
 
 if (frame%playersword.ffreq == 0) then
		playersword.findex += 1
		if (playersword.findex > #playersword.frames[playersword.astate]) then
			playersword.findex = 1
			playersword.astate = 1
		end
	end
 
 playergun.x = player.x+pgun_offset
 playergun.y = player.y+2
 
 if (frame%playergun.ffreq == 0) then
		playergun.findex += 1
		if (playergun.findex > #playergun.frames[playergun.astate]) then
			playergun.findex = 1
			playergun.astate = 1
		end
	end
	
 	
 --reset vel x
 player.vx = 0 
  
 if player.cooldown > 0 then
  player.cooldown-= 1
 end
 --attack !
 if btn(5) then
  if player.cooldown<=0 then
   local _vx=0
   local _vy=0
   if btn(0) then
    _vx = -1
    player.flip_x = true
   end
   if btn(1) then
    _vx = 1
    player.flip_x = false
   end
   if btn(2) then
    _vy = -1
   end
   if btn(3) then
    _vy = 1
   end
   --throwback from gun
   if player.invobj == obj_gun then
    if _vx~=0
    and player.x > 2 
    and player.x < 126
    then
     player.vx =  -(_vx*1.5)
    end
    if _vy~=0 then
     player.vy =  -(_vy*1.1)
    end
   end
   if _vx ~= 0 or _vy ~= 0 then
    player.cooldown = 8
    if player.invobj == obj_gun then
     objects.projectiles:create(
      playergun.x,playergun.y,
      _vx*4,_vy*4,
      obj_cannonball,
      player)
     playergun.astate = 2
    elseif player.invobj == obj_sword then
     --check if hit something
     for chr in all(objects.chars) do
      if chr ~= player
      --other is in range
      and abs(player.x-chr.x)<8
      and abs(player.y-chr.y)<6
      then
       chr.damage=true
      end
     end
     objects.projectiles:create(
      player.x,player.y,
      _vx*4,_vy*4,
      obj_swordstrike,
      player)
     playersword.astate = 2
    end
   end
  end
 --move tetris blocks and
 --navigate through inventory
 elseif btn(4) then
  
  if btn(0) and pobj~=nil 
  and pobj.x > 8 then
   pobj.x-=4
  end
  if btn(1) and pobj~=nil
  and pobj.x < 120 then 
   pobj.x+=4
  end
  --throw tetris block down
  if btn(3) and pobj~=nil 
  and player.coins > 0
  then
   player.coins-=1
   itemparticle:create(ui.x,ui.y,obj_coin,true)
   pobj.vy = 4
   pobj = nil
  end 
  --switch inventory item
  if btnp(2) then 
   if player.invobj == obj_gun then
    player.invobj = obj_sword
   elseif player.invobj == obj_sword then
    player.invobj = obj_gun
   end
  end
 --no violence? move then...
 else
  if btn(0) and player.x > 2 then
   player.vx = -1
   player.flip_x = true
  end
  if btn(1) and player.x < 126 then
   player.vx = 1
   player.flip_x = false
  end
  --jump
  if btn(2)
  and player.grounded then
   player.vy = -3.5*player.speed
   player.grounded = false
   player.y-=3
   --player.flip_x = true
  end
  --let fall (jump down)
  if btn(3) 
  and player.grounded 
  and player.groundobj ~= nil then
   player.letfall = true
   player.grounded = false
  -- player.vy = 1
  -- player.y+=2
  end
 end
end
--------------------------------
--enemy
enemy={
 jacks,--how many jack and dans 
 dans  --are there?
}
function enemy:init()
 enemy.spawnfreq = enemy_spawnfreq
end
function enemy:create(obj)
 local x
 local y= rnd(120)
 if rnd(10)>5 then
  x = 124
 else
  x = 2
 end
 objects.chars:create(x,y,obj)
end
function enemy:spawn()
 if frame % enemy.spawnfreq == 0
  and #objects.chars < max_enemies+1
 then
  local obj
  if rnd(10)>4 then
   obj = obj_jack 
  else
   obj = obj_dan
  end
  if player.y < 70 then
   obj = obj_dan
  end
  enemy:create(obj)
  --only player ingame? 
  if #objects.chars < 2 then 
   enemy:create(obj)
   --more spawns!
   enemy.spawnfreq = rnd(enemy_spawnfreq*0.5)
  else
   enemy.spawnfreq = rnd(enemy_spawnfreq)+enemy_spawnfreq
  end
 end 
end
function enemy:update(chr)
 --cooldown decrease
 if chr.cooldown>0 then
  chr.cooldown-=1
 end
 --kill if necessary
 if chr.hp <= 0 and chr.hp > -100 then
  if chr.t == obj_dan then
   explosion:create(chr.x-4,chr.y)
   explosion:create(chr.x+4,chr.y)
  else--eif rnd(10)>6 then
   explosion:create(chr.x,chr.y)
  end
  
  item_drop(chr.x,chr.y)
  chr.astate = 6
  chr.findex = 1
 --lastminute code alert!
  chr.hp = -100
 end
 --hardcode death state wait for anim
 if chr.hp == -100 and chr.findex==#chr.frames[chr.astate]-1 
 and frame%chr.ffreq*0.9 == 0
 then
  del(objects.chars,chr)
 end
 if chr.hp > 0 then
  --randomize velocity
  if chr.vx ~= 0 then
   chr.vx += rnd()*chr.vx*0.25
  end
 --jack .. a skeleton with a sword
  if chr.t == obj_jack then
   
   --get horizontal distance to player
   if abs(chr.x-player.x) <= 8 then
    --close enough for melee?
    if abs(chr.y-player.y) < 8 
    and abs(chr.x-player.x) >= 4
    then
     --cooldown passed
     if chr.cooldown <= 0 then
      --player.hp -= 1
      chr.astate = 1
      player.damage = true
      chr.cooldown = 24
     --idle for cooldown
     else
      chr.astate = 2
     end
    --to high or low for melee?
    elseif chr.grounded then
     --player above? -> jump
     if chr.y > player.y then
      chr.vy = -3.5*chr.speed
      chr.y-=3
      chr.grounded = false
     --player below? -> fall 
     elseif chr.groundobj ~= nil then
      chr.letfall = true
      chr.grounded = false
     end
    end
   --not close enough .. get closer
   else
    if player.x > chr.x then
     chr.vx = 1+rnd()*0.125
     chr.flip_x = true
    else
     chr.vx = -1-rnd()*0.125
     chr.flip_x = false
    end
   end
  end
 --skeleton with a bomb 
 --he will stay on the groundlane,
 --if the player is to high, he will
 --throw boms, otherwise he will
 --detonate
  if chr.t == obj_dan then
   --spawn particles for bomb
   if frame%8 == 0 then
    local poffset 
    if chr.flip_x then
     poffset = 4
    else
     poffset = -4
    end
    local pcolor 
    if rnd(10)>7 then
     pcolor = 9
    else
     pcolor = 10
    end
    particles:create(
     chr.x + poffset,
     chr.y - 2,
     pcolor
     ,
     flr(rnd(4)+4)
    )
   end 
   --ai logic
   --get horizontal distance to player
   if abs(chr.x-player.x) < 8 then
    --close enough for detonation?
    if abs(chr.y-player.y) < 8 then
     --detonate!!!!
     explosion:create(chr.x,chr.y)
     chr.hp=0
    -- del(objects.chars,chr)
    --to high or low for detonation?
    elseif chr.grounded then
     --player above? -> jump
     if chr.y > player.y then
      
      --cooldown passed?
      --throw bomb upwards!
      if chr.cooldown <= 0 then
       objects.projectiles:create(
        chr.x,chr.y,
        0,-7,
        obj_bomb,chr)
       chr.cooldown = 32
      --idle for cooldown
      else
       chr.astate = 2
      end
     --player below? -> fall 
     elseif chr.groundobj ~= nil then
      chr.letfall = true
      chr.grounded = false
     end
    end
   --not close enough .. get closer
   else
    if player.x > chr.x then
     chr.vx = 1+rnd()*0.125
     chr.flip_x = true
    else
     chr.vx = -1-rnd()*0.125
     chr.flip_x = false
    end
   end
  end
 end
end
-------------------------------
--items
--item drop
function item_drop(_x,_y,_t)
 if rnd(10)>4 then
  if _t == nil then
   if rnd(10)>4 then
    _t = obj_chest
   else
    _t = obj_barrel
   end
  end
  local idrop-- = obj_coin
  if _t == obj_chest then
   idrop = obj_coin
  end
  if _t == obj_barrel then
   idrop = obj_heart
  end
  if idrop ~= nil then
   objects.blocks:create(_x,_y,idrop)
  end
 end
end
function item_update(obj)
 obj.y = obj.y + sin(frame/8)*0.3
 if abs(player.x-obj.x)
   +abs(player.y-obj.y)
   < 10
 then
  --if obj.t == obj_coin then
  -- player.coins +=1
 -- end
  --if obj.t == obj_heart then
  -- player.hp +=1
  --end
 itemparticle:create(obj.x,obj.y,obj.t)
 del(objects.blocks,obj)
 end
end
-------------------------------
--cam
cam = {x=64,y=64,speed=0.05}
function lerp(a,b,t)
 if (t<0) then return a end
 if (t>1) then return b end
 return a + (b-a)*t
end
-------------------------------
--ui
ui = {
 x = 2,
 y = 2
}
function ui:draw()
 --inventory draw
 local length =
 frame % (blockdropfreq+blockdropadd)
 line(
  ui.x,
  ui.y-2,
  ui.x+length,
 	ui.y-2,
 	15
 )
  
 rectfill(
  ui.x+112,
  ui.y+2,
  ui.x+122,
  ui.y+12,
  7
 )
 rect(
  ui.x+112,
  ui.y+2,
  ui.x+122,
  ui.y+12,
  0
 )
 --[[
 local ox = 112  local oy = 2
 local osx = 8 local osy = 8
 if player.invobj == obj_gun then
  ox += 2
  oy += -2
  osx = 16
  osy = 16
 elseif player.invobj == obj_sword then
  ox += 2
  oy += 0
  osx = 24
  osy = 11
 end
 
 sspr(
  obj_sx[player.invobj],
  obj_sy[player.invobj],
  obj_sw[player.invobj],
  obj_sh[player.invobj],
  ui.x+ox,
  ui.y+oy,
  32,32
 )
 --]]
 --health display
 for i=1,player.hp do
  spr(
   104,
   ui.x+ i * 10,
   ui.y
  )
 end 
 --coin display
 spr(
  105,
  ui.x,
  ui.y+6
  )
 print(player.coins,ui.x+10,ui.y+8,7)
end
-------------------------------
--particles

particles = {}
function particles:create(_x,_y,_c,_a)
 if _a == nil then
  _a = 16
 end
 for i=1, _a do 
  local speed = 1 + rnd()
  local p = {
   x = _x,
   y = _y,
   vx = (-rnd(1)+rnd(1))*speed,
   vy = (-rnd(1)+rnd(1))*speed,
   c = _c,--rnd(15) for random color
   life = 8+ rnd(20)
  }
  add(particles,p)
 end
end
function particles:update()
 for p in all(particles) do
  if p.life > 32 then 
   del(particles,p)
  else
   p.x += p.vx
   p.y += p.vy 
   p.life += 1
  end
 end
end
function particles:draw()
 for p in all(particles) do
  pset(p.x,p.y,p.c)
 end
end

spr_particles = {}
function spr_particles:create(_x,_y,_t,_a)
 for i=1, _a do 
  local speed = rnd(1)+1
  local p = {
   x = _x,
   y = _y,
   vx = (-rnd(1)+rnd(1))*speed,
   vy = (-rnd(1)+rnd(1))*speed,
   t = _t,
   life =  32 + rnd(32)
  }
  add(spr_particles,p)
 end
end

function spr_particles:update()
 for p in all(spr_particles) do
  if p.life > 32 then 
   del(spr_particles,p)
  else
   p.x += p.vx
   p.y += p.vy 
   p.life += 1
  end
 end
end
function spr_particles:draw()
 for p in all(spr_particles) do
  if p.t == obj_brokenwood then
   spr(68,p.x,p.y)
  end
 end 
end
-------------------------------
--item particles
itemparticle = {}
function itemparticle:create(_x,_y,_t,_lost)
 local p = {
  x=_x,
  y=_y,
  t=_t,
  vx=-rnd()+rnd(),
  vy = 1,
  l=false
 }
 if _lost then p.l = true end
 add(itemparticle,p)
end
function itemparticle:update()
 for p in all(itemparticle) do
  if p.l == false then
   if p.t == obj_coin then
    p.x = lerp(p.x,ui.x,0.1)
    p.y = lerp(p.y,ui.y,0.1)
    if (abs(p.x-ui.x)+abs(p.y-ui.y) )
    < 8 then
     player.coins +=1
     del(itemparticle,p)
    end
   elseif p.t == obj_heart then
    p.x = lerp(p.x,ui.x+ (player.hp+1) * 10,0.1)
    p.y = lerp(p.y,ui.y,0.1)
    if (abs(p.x-(ui.x+ (player.hp+1) * 10))+abs(p.y-ui.y) )
    < 10 then
     player.hp +=1
     del(itemparticle,p)
    end 
   end
  else
   p.x += p.vx
   p.vy += level.gravity
   p.y += p.vy
  end
 end
end
function itemparticle:draw()
 for p in all(itemparticle) do
  sspr(
   obj_sx[p.t],
   obj_sy[p.t],
   obj_sw[p.t],
   obj_sh[p.t],
   p.x,
   p.y,
   obj_sw[p.t]*0.8,
   obj_sh[p.t]*0.8
  )
 end
end
 
-------------------------------

-------------------------------

-------------------------------

-------------------------------

-------------------------------

__gfx__
bbbbbb0006600bbbbbbbbbbbbbbbbbbbbbbbb000660bbbbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbbbbbbbbbbbbbbbbb0006600bbbb
bbbb0000600000bbbbbbbb0006600bbbbbb0000600000bbbbbbb0000600000bbbbbb0000600000bbbbbb0000600000bbbbbbbbb0006600bbbbb0000600000bbb
bbb00000600000bbbbbb0000600000bbbb00000600000bbbbbb00000600000bbbbb00000600000bbbbb00000600000bbbbbbb0000600000bbb00000600000bbb
bb000000066000bbbbb00000600000bbb000000066000bbbbb000000066000bbbb000000066000bbbb000000066000bbbbbb00000600000bb000000066000bbb
b00055f7ff00bbbbbb000000066000bb00055f7ff00bbbbbb000bbbbbbbbbbbbb00055f7ff00bbbbb00055f7ff00bbbbbbb000000066000b00055ffff00bbbb8
bbb555f0ff00bbbbb00055f7ff00bbbbbb555f0ff00bbbbbbbbb55f7ff00bbbbbbb555f0ff00bbbbbbb555f0ff00bbbbbb00055ffff00bbbbb555f00f00bbbbb
bbbbd5ffffffbbbbbbb555f0ff00bbbbbbb15ffffffbbbbbbbb555f0ff00bbbbbbbb15ffffffbbbbbbbb15ffffffbbbbbbbb555f00f00bbbbbb15ffffffb8bbb
bbbb155555555bbbbbbb15ffffffbbbbbbb155555555bbbbbbbb15ffffffbbbbbbbb155555555bbbbbbb155555555bbbbbbbbd5ffffffbbbbbb155555555bbbb
bb91115555555bbbbbbb155555555bbbb91115555555b555bbbb155555555bbbbb91115555555bbbbb91115555555bbbbbbbb155555555bbb91815855555bb8b
bb1111d555555bbbbb91115555555bbbb1111d555555045bbb91115555555bbbbb1111d555555bbbbb1111d555555bbbbbb91115555555bb811118885555b88b
bb1111d66d10bbbbbb1111d555555bbbb1111d66d10004bbbb1111d555555bbbb11111d66d10bbbbb11111d66d10bbbbbbb1111d588888bbbb8888888808bbbb
bb1111d66d10bbbbbb1111d66d10bbbbb1111d66d10bb4bbb11111d66d10bbbbb11b11166d10bbbbb11b11d66d10b0bbbbb1111d66d10b8b11188d88d10bb8b8
bbdd0009900bbbbbbb1111d66d10bbbbb110009900bbbbbbb11b11d66d10bbbbbffb00099000bbbbbffb0009900000bbbbb1181886d888bb11b18868d10b88bb
bbff444b000bbbbbbb110009900bbbbbbff444b000bbbbbbbffb0009900bbbbbbbbbb444000bbbbbbbbb444bb00000bbbbbdd00099008bb8ffb0009900bbb88b
bbbbb44b000bbbbbbbffb44b000bbbbbbbbb44b000bbbbbbbbbbb44400bbbbbbbbbbbb4440bbbbbbbb9444bbbbbbbbbbbbbff444b000b8bbbbb444b800bbbb8b
bbbbb99bb000bbbbbbbbb99bb000bbbbbbbb99bb000bbbbbbbbbbb99000bbbbbbbbbbbb0900bbbbbbbbbbbbbbbbbbbbbbbb9444b0000b8bbb9444bb000bbbb8b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb67bbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbb88bbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbb6bbbbbb667bbbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbbbbbbbbbb8bb88bbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbb6bbbbabbbbbbbbbb666bb6bbbbbb6666bbbbbbbbbbbbdbbbbbbbdbbbbbbbbbbbbbbbbbbbbbbbbbb8b8bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb66bbbbbbbb6667bbbbbbbbbbbbdddbbbbbbb6667bbbbbbbbbbbbbbbbbb8bb88bbbbb00bbb
555555bbbbbbbbbb555555b589bbbbbb555555b8a9bbbbbb555555bbbbbbbbbbb6667bbbbbbbbbbbbbbddbbbbb66667bbbbbbbbbbbbbbbbbbbbbb8bbbbb000bb
065666bbbbbbbbbb065666b5aa77bbbb065666baa7b77bbb065666bb6b99bbbbb6667bbbbbbbbbbbbbbbdbbbb66666bbbbbbbbbbbbbbbbbbbbb11819bbb0000b
0455bbbbbbbbbbbb0455bb589abbbbbb0455bb59aabbbbbb0455bbb66bbbbbbbb666bbbbbbbbbbbbbbbbddbb66667bbbbbbbbbbbbbbbbbbb9fd11811bb50000b
44bbbbbbbbbbbbbb44bbbbb589bbbbbb44bbbbb569bbbbbb44bbbb66bbbbbb9bb667bbbbbbbbbbbbbbbbbdb666667bbbbbbbbbbbbbbbbbbb4fd188111d550000
4bbbbbbbbbbbbbbb4bbbbbbbbbbbbbbb4bbbb6b9bbbbbbbb4bbbb66bbbbbbbbbb66bbbbbbbbbbbbbbbbbbb666667bbbbbbbbbbbbbbbbbbbb4401881155550000
0bbbbbbbbbbbbbbb0bbbbb9b9bbbbbbb0bbb66bbb9bbbbbb0bbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbb566667bbbbbbbbbbbbbbbbbbbbb440888d85fff0660
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb666bbbbabbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbb55677bbbbbbbbbbbbbbbbbbbbbbbb40888855f0f6006
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbb0b9888585f0f6006
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbbbb009d88555fff0000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbbbbb000818855f000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb880888555f000888
bbbb00000000bbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0044444400bbbbbb0044444400bbbbbb49bb99bbbb4bbb5b5b5b5bbbbbbbb50065bbb000bb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb004424222200bbbbbb4424222200bbbb44bb55bbbbbb59050505056565565650605bbb00bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00555555555500bb00bbb555555500bb44b455bbbbbbb55404040405454545450005bbb0bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b05555111111110bb05000111111110bbbbb55bbbbbbbbbb4040404045454544b555bbbb0bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04452452554254400445240255425440bbbb4bbbbb559bbb0505050565655656bbbbbbbb00bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04524524425225400452452442522540bbbbbbbbbbb559bbb5b5b5b5bbbbbbbbbbbbbbbb000bb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04524524425425400452452042542540bbbbb59bbbbb559bbbbbbbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04524524425425400452452402542540bbbbb59bbbbbb59bbbbbbbbbb98888b9abbbbbabbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04524524425425200452452442542520bbbbb45bbbbbbbbbbbbbbb9b8899988bbab66bbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04524524425225100452452442522510bbbbb455bbbbbbbbb99aaabb89aa998bbb66666bbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0445245422525110044524502250b110bbb99b455bbbbb44bb99aaabbaa77a88b666666ab00550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b05555551521210bb055555015200b0bbbbb44bbbbb555bbbb9aaaab89a77798b566666b0000550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00115111212100bb0011510121200bbbbbbb49bbb44bbb4bb9a999b899aa989bb56665b0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb002221221200bbbb00200b021200bbbbbbbb4bbbbbbbbbb9bb99bbb889888bb566655b0100000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000000bbbbbb000bb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbb9b555b9b01110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000000bbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00b00bbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00054444450000bb00054444450000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0e80880bb0aaa40bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0044544444450400bb04544444450400bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb08e8820b0a999940bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444544444452440bb00044444452400bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0888820b0a9a9940bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0444544444452440000bb0444445240bbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbb08820bb0a9aa440bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04445444444524400400b0444445240bbbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbb020bbb04994a40bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
044404444425244004440444442520bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbb044440bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
042452444240242004245244424000b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
04440442424522400444044242450000bbbbb6bbbbbbb666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
02420424242022100242042424202210bbb6bbbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
05250219951011200525021995101120bbbbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000009900000000000000990000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
02220224411011100200002441101110b66b4455bb44b44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0222022222101110020bb02222101110b666b44445555546bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
091102111110119009bbb01111101190b5644444444b4446bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000000bbb00000000000b55b66444bb444b5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb05550bbbbbbbbbbb05550bbbbbbbbbbb05550bbbbb6bbbbb05550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb0555550bbbbbbbbb0555550bbbbbbbbb0555550bbbb66bbb0555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb055555550bbbbbbb055555550bbbbbbb055555550bbb66bb055555550bbbbbbbbbbb05550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb088558850bbb6bbb088558850bbb6bbb088558850bbb66bb088558850bbbbbbbbbb055b550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb078557850bbb66bb078557850bbb66bb008557850bbb66bb008557850bbbbbbbbb05b555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bdbb055555550bbb66bb055555550bbb66bb055555550bbb66bb055555550bbbbb6bbb088558b50bbbbbbbbbb5b55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bdbbb05555509bbb66bbb05555509bbb66bbb05555509bbbb66bb05555509b8bbb66bb008557850bbbbbbbb5bbbb550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbbbb0505050bbbb66bbb0505050bbbb66bbb0505050bbbbb65bb0505050bb0bbbb6bb055555550bbb6bbbbbb5b8b50bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbbbbbbbb050bbbb66bbbbbbb050bbbb66bbbbbbb050bbbbbb50bbbbb050b0bbbb66bbb055555095bbbbbb00bbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbdbbb22211222bbb66bbb22211222bbb66bbb22211222bbbb55bb02211220bbbb6bb5b0505050bbbbbbbb05bb5b550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbdbbb02211220bbd65b0002211220bbb65b0002211220bbbbb500b221122bbbbbb6bbbb22211222bb6b6bb0b5555095bbbbbbbbbbb5b5bbbbbbbbbbbbbbbbbb
bbdbb0b221122b0dbb500bb221122b0bbb500bb221122b0bbbbbbbb221122bbbbbb65b00b2211220bb6bb5bb5b5050bbbbbbbbbbb5bbbbb5bbbbbbbbbbbbbbbb
bbbd055b111118bdbb55bbbb11111b8bbb55bbbb11111b8bbbbbbbbb11111bbbb6bb500b0b2b122b0bbbbbbbbbbbbbb0bbbb6bbbbbb51bb5bbbbbbbbbbbbbbbb
bb6655b0bbb00bbdbbb5bbb0bbbb0bbbbbb5bbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbb5bbbb111b1b8bb65b00b2211bbbbbbbbbbb01b1b78bbbbbbbbbbbbbbbbb
6666bbbb0bb0bbbdbdbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb00bbb00bbbb6bbbb2b0bbb102b6bb500b0b2b122b0bbbbb2b05188b550bbbbbbbb651bb5b
66bbbbbb0b0bbbbbbddbbbb0bbbb0bbbbbbbbbbb0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0b1bb0bbbbbbbbbbb00bb0b8bbb5b5b512151152bbb60b01b157805
bbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbbb0ddd0bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbbb0ddddd0bbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb9b0ddddddd0bbbb9bb0ddddddd0bbb9bbb0ddddddd0bbbb9bb0ddddddd0bbbbbb9b0ddddddd0bbbb89bbb0ddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b9bbb088dd88d0bbbbbbb088dd88d0bbbbb9b088dd88d0bbb9b9b088dd88d0bbbb9bbb088dd88d0bbbb5bbb0bddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb89b078dd78d0bbb98bb078dd78d0bbbb8bb078dd78d0bbbb8bb078dd78d0bbbbb89b078dd78d0bbbb5bb0dbbdddb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bb00dddddd0bbbb59b00dddddd0bbb95bb00dddddd0bbbb5bb00dddddd0bbbbb5bb00dddddd0bbbbb0b088dd88b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bb8bbb5bbb0ddddd0bbbb00bb078bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bb8bb000bb0d0d0d0bbbb000b0bbddddd0bbb9bbbbbbbbb0b0bbbbbbbbbbbbbbbbb
b0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bb8bb0000bbbbb0d0bbbbbbbbb0dddd70bbbbb89bbbbbbbbb0bbbbbbbbbbbbbbbbb
b000b0018dddd81bb000b0018dddd81bb000b0018dddd81bb000b0018dddd80bbb000b0018dddd81bbbbbbb0d0d0d0b0bbbb0bbbdbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb11bbbbbbbbbb11bbb10bbbbbbbbbbb0d0bb8b00bbbbddb88d0bbbbbbbbbbbbbbbbb
bbbbbbbb11dbd8b8bbbbbbbb11dbd88bbbbbbbbb11dbd8b8bbbbbbbb11dbd8bbbbbbbbbbb11dbd8b8bbbbb0b1bbddd0b8bbb0bb088bbb0bbbbbbbbbbbbbbbbbb
bbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbbb1db88b8bbbbbbbb11bbbbbbbbbbbb078d0d0b0bbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbbb0bbbb0bbbbbbbdddbbdbd8bbbbbbbbbbbb0bbbb8bbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb0bbbbb0bbbbbbbbb00bbb08bbbbbbbbbb0bbbb0bbbbbbbbbbb1db88bbbbbbb0b1bbd7d0b8bbbbb9bbdb8bdb0
bbbbbbbb0bbbb8bbbbbbbbbbb0b8bbbbbbbbbbb0bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbb0bbbb8bbbbbbbbdb0bb0b0bbbbbbbbbb11bbbbbbbbb980d78b0d000
149414521442134214941442144214421442111111111442d494d452d442d342d494d442d442d442ccccccccccccccccccccccccccc45666ccccccccbbbbbbbb
144414521223344214441445122215421453555555553342d444d452d2233442d444d445d222d542cccccccccccccccccccccccccc5566666cccccccbbbbbbbb
111114521111334211111445111115421553555555555332ddddd452dddd3342ddddd445d111d542cccccccccccccccccccccccc5556666666ccccccbbbbbbbb
14421455144213421342144514321542155511111111d332d442d455d4421342d342d445d432d542cccccccccccccccccccccc5556666666666cccccbbbbbbbb
1442145214421345144214451432154215511111111d1351d442d452d4421345d442d445d432d542ccccccccccccccccccccc566666666666666ccccbbbbbbbb
144214521452134514321445153215421551111111d11352d442d452d4521345d432d445d532d542ccccccccccccccccccc55666666666666666ccccbbbbbbbb
144214551452134514351445153215421551111111111332d442d455d452d345d435d445d532d542ccccccccccccccccc55566666666666666666cccbbbbbbbb
1442145514521345143514451533154515511111d1111d52d442d455d452d345d435d445d5331545ccccccccccccccccc55556566666666666666cccbbbbbbbb
144214551452144513451445153315451551111d111d1d52d442d4551452d445d345d445d533d545ccccccccccc42cccbb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbb
14451445144214451342144515451545155111d111d11d52d445d4451442d445d342d4451545d545ccccccccccc42cccb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbbb
1445144514421442134214451445154215511d111d111352d445d4451442d442d342d4451445d542ccccccccccc444ccbb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbb
144514451445144214421452144514421551d11111111d52d445d4451445d442d442d452d445d442ccccccccccc42cccb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbbb
14421445144514421452145214451442155d111111115d52d442d4451445d4421452d4521445d4424444444444444444bb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbb
1442144214421442145214521445144215555dddddddd551d442d442d442d442145214521445d442cc2ccc2cccc22cccb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbbb
144212221442122214521223334512221255555555555521d442d222d442d222145212233345d222cc4ccc4cccc42cccbb6b6b6bbbbbbbbbbbbbbbbbbbbbbbbb
144211111342111115421111334511111222133213331231d442ddddd342d1dd1542dddd3345ddddcc4ccc4cccc42ccc66b6b6b6bbbbbbbbbbbbbbbbbbbbbbbb
1452144213421442154215323445144211dddd1111111111d452d442d342d4421542d5323445d4422242224222242222cccccccccccc4444bbbbbbbbbbbbbbbb
145214421342144215451332144514424144444444433333d4521442d34214421545d3321445d4424444444444444444ccccccccccc44445bbbbbbbbbbbbbbbb
145214421345144215451342144214422155224225522232d4521442d3451442d545d342144214425555444422222555cccccccccc444454bbbbbbbbbbbbbbbb
14551442144514421545154215421442111111111111ddddd4551442d4451442d545d542d54214424445444444444444ccccccccc4444544bbbbbbbbbbbbbbbb
145214421445144215451542154214424444441444444333d4521442d445d442d545d542d542d4424555422244555524cccccccc4444544cbbbbbbbbbbbbbbbb
145215421442144215451442154214422422221225552222d4521542d442d442d545d442d542d4424425444425442224ccccccc4444544ccbbbbbbbbbbbbbbbb
145215421442145515451445154214421ddddd111111111dd452154214421455d545d445d542d4422255222222224444cccccc4444544cccbbbbbbbbbbbbbbbb
14521542142514521445144515451445224233345544414514521542d425145214451445d545d4455225555544555555ccccc4444544ccccbbbbbbbbbbbbbbbb
14521542142514521445144515451442bbbbbbbbbbbbbbbb14521542d425145214451445d545144224422222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14521542142514521445144514451452bbbbbbbbbbbbbbbb14521542d4251452144514451445145244444444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14551542145514521445144514451452bbbbbbbbbbbbbbbbd4551542d4551452d44514451445145244445555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14551542145514421445145514421452bbbbbbbbbbbbbbbbd455154214551442144514551442145222245442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
12221542122214521252154512221455bbbbbbbbbbbbbbbbd222154212221452125215451222d45544445555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
11111522111114551111154211111455bbbbbbbbbbbbbbbbd11115221ddd145511111542d111145544445442bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14441522144214551444154514421445bbbbbbbbbbbbbbbb1444152214421455144415451442144555522222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
14941422144214551494144514421445bbbbbbbbbbbbbbbb1494142214421455149414451442144522222555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
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
cacacacacacacacacacacacacacacacacaca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacadbcacacacacacacacadbcacacacaca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacccdcdcdcecacacacacccdcdcdcecacaca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacccdcdcdcecacacacacccdcdcdcecacaca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacadbcacacacacacacacadbcacacacaec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacadbcacacacacacacacadbcacacaeced0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dadadadbdadacacadadadadadbdadaeced000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebebebebebeacacafaebebebebebebeb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
