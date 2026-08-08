--[[
    *** functions ***
    
    •doMoveInAreaWithMiss(cid, area, effect, cd, atkName, paralize, element, min, max)
         •Da uma atk com efeito que deixa os alvos com efeito de 'MISS'...
         
    •doMoveInArea(cid, rounds, effect, area, min, max, element, atkName)
         •Da um atk 'nomal' e tb atks que deixam os alvos com efeito de 'Confuso'...
         
    •doMoveInAreaMulti(cid, effDistance, effMagic, areaEff, areaDano, element, min, max)
         •Da um atk estilo 'Multi-Kick, Bullet Seed' e afins... 
--]]

const_distance_delay = 56

function getMasterTarget(cid)
    if isSummon(cid) then
	    return getCreatureTarget(getCreatureMaster(cid))
	else
	    return getCreatureTarget(cid)
    end
end

function doAreaCombatWithDelay(cid, target, pos, area, type, effect, a, b)
	if not isCreature(cid) then return true end
	if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
	local topos = {}
		if isCreature(target) then topos = getThingPosWithDebug(target) else topos = pos end
	doAreaCombatHealth(cid, type, topos, area, -math.abs(a), -math.abs(b), effect)
end 

function doAreaCombatHealthAtDistance(cid, type, pos, area, min, max, effect)
	local delay = 0
	if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
	if isCreature(cid) and isCreature(target) then
		delay = getDistanceBetween(getThingPosWithDebug(cid), getThingPosWithDebug(target)) * const_distance_delay
		addEvent(doAreaCombatWithDelay, delay, cid, target, getThingPosWithDebug(target), area, type, effect, -min, -max)
	return true
	end
	doAreaCombatHealth(cid, type, pos, area, min, max, effect)
end

function docastspell(cid, spell, mina, maxa)

local getThingPositionWithDebug = getThingPosWithDebug
local target = 0
local getDistDelay = 0

if isCreature(getMasterTarget(cid)) then
	target = getMasterTarget(cid)
	getDistDelay = getDistanceBetween(getThingPositionWithDebug(cid), getThingPositionWithDebug(target)) * const_distance_delay
end

if not isCreature(cid) or getCreatureHealth(cid) <= 0 then return false end
if isSleeping(cid) then return true end
if isMonster(cid) and not isSummon(cid) then
	if getCreatureCondition(cid, CONDITION_EXHAUST) then
	return true
	end
	doCreatureAddCondition(cid, wildexhaust)
end

local mydir = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

local movetype = getSpecialAttack(cid)

local min = 0
local max = 0
local healMultiplier = 1

local tooBad = {"Scyther", "Scizor", "Hitmonlee", "Hitmonchan", "Hitmontop", "Tyrogue", "Shiny Scyther", "Shiny Hitmonchan", "Shiny Hitmonlee", 
                "Shiny Hitmontop", "Ledian", "Ledyba", "Sneasel"}  --alterado v2.4

    if ehMonstro(cid) and isCreature(getMasterTarget(cid)) and isInArray(tooBad, getCreatureName(getMasterTarget(cid))) and math.random(1, 100) <= 10 then 
       local target = getMasterTarget(cid)                                                                                       --10 = 10% chance
       
       doSendMagicEffect(getThingPos(target), 211)
	   doSendAnimatedText(getThingPos(target), "Too Bad", 215)                                 --edited passiva TOO BAD!!
	   doTeleportThing(target, getClosestFreeTile(target, getThingPos(cid)), false)
	   doSendMagicEffect(getThingPos(target), 211)
	   doFaceCreature(target, getThingPos(cid))    		
	return false 
	end
	
if mina and maxa then
min = math.abs(mina)
max = math.abs(maxa)
elseif not isPlayer(cid) then
	if movesinfo[spell] then
		if movesinfo[spell].t == "fighting" then
			movetype = getOffense(cid) * 0.95 + getSpecialAttack(cid) * 0.45      ---original, 1.4 / 0.45
		elseif movesinfo[spell].t == "normal" then
			movetype = movetype * 0.6 + getOffense(cid) * 0.6
		end
	min = 5 + getPokemonLevel(cid) + (movesinfo[spell].f / 100 * movetype * specialoffenseRate)
	max = min + getPokemonLevel(cid) * levelFactor
		if not isSummon(cid) then
			doCreatureSay(cid, string.upper(spell).."!", TALKTYPE_MONSTER)
		end
		if isNpcSummon(cid) then
			local mnn = {" use ", " "}
			local use = mnn[math.random(#mnn)]
			doCreatureSay(getCreatureMaster(cid), getPlayerStorageValue(cid, 1007)..","..use..""..doCorrectString(spell).."!", 1)
		end
	else
	print("Error trying to use move "..spell..", move not specified in moves table.")
	end
	
end
--- FEAR / ROAR ---
if getPlayerStorageValue(cid, 3894) >= 1 then
return true                                      --alterado!!
end
--alterado v2.4  retirado a skill burn skin
--- FOCUS ----------------------------------
if getPlayerStorageValue(cid, 253) >= 0 and movesinfo[spell] and movesinfo[spell].f ~= 0 then
	min = min * 2
	max = max * 2
	setPlayerStorageValue(cid, 253, -1)
end
--- Shredder Team -------------------------------
if getPlayerStorageValue(cid, 637501) >= 1 then
   if #getCreatureSummons(cid) == 1 then
      docastspell(getCreatureSummons(cid)[1], spell)
   elseif #getCreatureSummons(cid) == 2 then
      docastspell(getCreatureSummons(cid)[1], spell)
      docastspell(getCreatureSummons(cid)[2], spell)
   end    
      
elseif getPlayerStorageValue(cid, 637500) >= 1 then
   min = 0
   max = 0                                     
end
------------------Miss System--------------------------
local cd = getPlayerStorageValue(cid, 32659)
local cd2 = getPlayerStorageValue(cid, 3891) 
if cd > 0 or cd2 > 0 then                                      --alterado v2.4
   if not isInArray({"Aromateraphy", "Emergency Call", "Magical Leaf", "Sunny Day", "Safeguard"}, spell) then
      if math.random(1, 100) > 30 then
         doSendAnimatedText(getThingPos(cid), "MISS", 215)
         return false
      end
   end
end
---------------GHOST DAMAGE-----------------------
ghostDmg = GHOSTDAMAGE
psyDmg = PSYCHICDAMAGE     --alterado v2.4

if getPlayerStorageValue(cid, 999457) >= 1 then
   ghostDmg = NORMALDAMAGE
   psyDmg = NORMALDAMAGE           --alterado v2.4
   addEvent(setPlayerStorageValue, 50, cid, 999457, -1)
end
---------------SelfDestruction-----------------
canDoSelf = true
----------------REFLECT-------------------------  
local uid = checkAreaUid(getCreaturePosition(cid), BigArea2, 1, 1)
for _,pid in pairs(uid) do
    if isCreature(pid) then
       if getPlayerStorageValue(cid, 21099) >= 1 then
          if getPlayerStorageValue(pid, 21101) >= 1 then
             target = pid
             setPlayerStorageValue(cid, 21099, 0)
             setPlayerStorageValue(pid, 21101, 0)
             if getCreatureName(cid) == "Wobbuffet" then
                doRemoveCondition(cid, CONDITION_OUTFIT)    --alterado v2.4
             end
          end
       elseif getPlayerStorageValue(pid, 21099) >= 1 and pid ~= cid then                --alterado v2.4
             if not isInArray({"Reflect", "Team Slice", "Magic Coat", "Shredder Team", "Double Team"}, spell) then
                addEvent(docastspell, 100, pid, spell)
                doSendMagicEffect(getThingPos(pid), 135)
                doSendAnimatedText(getThingPos(pid), "REFLECT", COLOR_GRASS)
                setPlayerStorageValue(cid, 21101, 1)
                canDoSelf = false
                min = 0
                max = 0
             end
       end
    end                                 
end 
--------------------------------------------------

if spell == "Reflect" or spell == "Magic Coat" then

    if spell == "Magic Coat" then
      eff = 11
    else
      eff = 135
    end

	doSendMagicEffect(getThingPositionWithDebug(cid), eff)
	setPlayerStorageValue(cid, 21099, 1)     --alterado v2.4

elseif spell == "Quick Attack" then

    doSendMagicEffect(getThingPositionWithDebug(cid), 211)
	local x = getClosestFreeTile(cid, getThingPositionWithDebug(target))
	doTeleportThing(cid, x, false)
	doFaceCreature(cid, getThingPositionWithDebug(target))
	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 3)
	
elseif spell == "Razor Leaf" or spell == "Magical Leaf" then --alterado v2.4

local eff = spell == "Razor Leaf" and 8 or 21

local function throw(cid, target)
if not isCreature(cid) or not isCreature(target) then return false end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), eff)   --alterado v2.4
	doAreaCombatHealthAtDistance(cid, GRASSDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 245)
end

addEvent(throw, 0, cid, target)
addEvent(throw, 350, cid, target)
		
elseif spell == "Vine Whip" then

local area = getThingPositionWithDebug(cid)
local dano = {}
local effect = 255

	if mydir == 0 then
		area.x = area.x + 1
		area.y = area.y - 1
		dano = whipn
		effect = 80
	elseif mydir == 1 then
		area.x = area.x + 2
		area.y = area.y + 1
		dano = whipe
		effect = 83
	elseif mydir == 2 then
		area.x = area.x + 1
		area.y = area.y + 2		
		dano = whips
		effect = 81
	elseif mydir == 3 then
		area.x = area.x - 1
		area.y = area.y + 1
		dano = whipw
		effect = 82
	end

		doSendMagicEffect(area, effect)
		doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(cid), dano, -min, -max, 255)
		
elseif spell == "Headbutt" then
       
       doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 118)
       
elseif spell == "Leech Seed" then

	local leecher = cid
	local leeched = target
	local dmg = 3 * getPokemonLevel(cid)

		local function drain(cid, target, dmg)
		if isCreature(cid) and isCreature(target) then
		   local life = getCreatureHealth(target)
		   doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(target), 0, -dmg, -dmg, 45)
		   local newlife = life - getCreatureHealth(target)
		   if newlife >= 1 then
		      doSendMagicEffect(getThingPositionWithDebug(cid), 14)
		      doCreatureAddHealth(cid, newlife)
		      doSendAnimatedText(getThingPositionWithDebug(cid), "+"..newlife.."", 32)
           end
		end
		end

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 1)
	for rounds = 1, 5 do
	    addEvent(drain, 2000 * rounds, leecher, leeched, dmg)
	end
	
elseif spell == "Solar Beam" then
	
local function useSolarBeam(cid)
		if not isCreature(cid) then
		return true
		end
		if isSleeping(cid) then
		return true
		end
			local effect1 = 255
			local effect2 = 255
			local effect3 = 255
			local effect4 = 255
			local effect5 = 255
			local area = {}
			local pos1 = getThingPositionWithDebug(cid)
			local pos2 = getThingPositionWithDebug(cid)
			local pos3 = getThingPositionWithDebug(cid)
			local pos4 = getThingPositionWithDebug(cid)
			local pos5 = getThingPositionWithDebug(cid)
		if getCreatureLookDir(cid) == 1 then
			effect1 = 4
			effect2 = 10
			effect3 = 10
			effect4 = 10
			effect5 = 26
			pos1.x = pos1.x + 2
			pos1.y = pos1.y + 1
			pos2.x = pos2.x + 3
			pos2.y = pos2.y + 1
			pos3.x = pos3.x + 4
			pos3.y = pos3.y + 1
			pos4.x = pos4.x + 5
			pos4.y = pos4.y + 1
			pos5.x = pos5.x + 6
			pos5.y = pos5.y + 1
			area = solare
		elseif getCreatureLookDir(cid) == 0 then
			effect1 = 36
			effect2 = 37
			effect3 = 37
			effect4 = 38
			pos1.x = pos1.x + 1
			pos1.y = pos1.y - 1
			pos2.x = pos2.x + 1
			pos2.y = pos2.y - 3
			pos3.x = pos3.x + 1
			pos3.y = pos3.y - 4
			pos4.x = pos4.x + 1
			pos4.y = pos4.y - 5
			area = solarn
		elseif getCreatureLookDir(cid) == 2 then
			effect1 = 46
			effect2 = 50
			effect3 = 50
			effect4 = 59
			pos1.x = pos1.x + 1
			pos1.y = pos1.y + 2
			pos2.x = pos2.x + 1
			pos2.y = pos2.y + 3
			pos3.x = pos3.x + 1
			pos3.y = pos3.y + 4
			pos4.x = pos4.x + 1
			pos4.y = pos4.y + 5
			area = solars
		elseif getCreatureLookDir(cid) == 3 then
			effect1 = 115
			effect2 = 162
			effect3 = 162
			effect4 = 162
			effect5 = 163
			pos1.x = pos1.x - 1
			pos1.y = pos1.y + 1
			pos2.x = pos2.x - 3
			pos2.y = pos2.y + 1
			pos3.x = pos3.x - 4
			pos3.y = pos3.y + 1
			pos4.x = pos4.x - 5
			pos4.y = pos4.y + 1
			pos5.x = pos5.x - 6
			pos5.y = pos5.y + 1
			area = solarw
		end

		if effect1 ~= 255 then
			doSendMagicEffect(pos1, effect1)
		end
		if effect2 ~= 255 then
			doSendMagicEffect(pos2, effect2)
		end
		if effect3 ~= 255 then
			doSendMagicEffect(pos3, effect3)
		end
		if effect4 ~= 255 then
			doSendMagicEffect(pos4, effect4)
		end
		if effect5 ~= 255 then
			doSendMagicEffect(pos5, effect5)
		end
	
		doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(cid), area, -min, -max, 255)	
		doRegainSpeed(cid)
	end

	local function ChargingBeam(cid)
		if not isCreature(cid) then
		return true
		end
		if isSleeping(cid) then
		return true
		end
		local tab = {}

		for x = -2, 2 do
			for y = -2, 2 do
				local pos = getThingPositionWithDebug(cid)
				pos.x = pos.x + x
				pos.y = pos.y + y
					if pos.x ~= getThingPositionWithDebug(cid).x and pos.y ~= getThingPositionWithDebug(cid).y then
					table.insert(tab, pos)
					end
			end
		end
	doSendDistanceShoot(tab[math.random(#tab)], getThingPositionWithDebug(cid), 37)
	end

doChangeSpeed(cid, -getCreatureSpeed(cid))

for r = 1, 100 do
	addEvent(ChargingBeam, r*9, cid)
end

addEvent(useSolarBeam, 1000, cid)

elseif spell == "Sleep Powder" then

	local calc = math.floor(getPokemonLevel(cid) / 20)
	local v1 = 6
	local v2 = v1 + calc
	doAreaCombatHealth(cid, SLEEP_POWDERDAMAGE, getThingPositionWithDebug(cid), powders, -v1, -v2, 27)

elseif spell == "Stun Spore" then
        
    doMoveInAreaWithMiss(cid, confusion, 85, 9, spell, 1, GRASSDAMAGE, 0, 0)

elseif spell == "Poison Powder" then

	local v1 = (10 + getPokemonLevel(cid)) * 2
		setPlayerStorageValue(cid, 919231, v1)
	local v3 = getPokemonLevel(cid) / 10 + 5

	doAreaCombatHealth(cid, POISON_POWDERDAMAGE, getThingPositionWithDebug(cid), powders, -v3, -v3, 84)
	
elseif spell == "Bullet Seed" then
               --cid, effDist, effDano, areaEff, areaDano, element, min, max
doMoveInAreaMulti(cid, 1, 45, bullet, bulletDano, GRASSDAMAGE, min, max)

elseif spell == "Body Slam" then
	
	doBodyPush(cid, target, true)
	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 3)
    
elseif spell == "Leaf Storm" or tonumber(spell) == 73 then

	addEvent(doAreaCombatHealth, 150, cid, GRASSDAMAGE, getThingPositionWithDebug(cid), grassarea, -min, -max, 255)

	local pos = getThingPositionWithDebug(cid)

	local function doSendLeafStorm(cid, pos)              --alterado!!
		if not isCreature(cid) then return true end
	doSendDistanceShoot(getThingPositionWithDebug(cid), pos, 8)
	end

	for a = 1, 100 do
		local lugar = {x = pos.x + math.random(-6, 6), y = pos.y + math.random(-5, 5), z = pos.z}
		addEvent(doSendLeafStorm, a * 2, cid, lugar)
	end
    
elseif spell == "Scratch" then

	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 142)
    
elseif spell == "Ember" then

		doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 3)
		doAreaCombatHealthAtDistance(cid, FIREDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 15)

elseif spell == "Flamethrower" then

	local flamepos = getThingPos(cid)
    local effect = 255
    local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if a == 0 then
		flamepos.x = flamepos.x+1
		flamepos.y = flamepos.y-1
		effect = 106
	elseif a == 1 then
		flamepos.x = flamepos.x+3
		flamepos.y = flamepos.y+1
		effect = 109
	elseif a == 2 then
		flamepos.x = flamepos.x+1
		flamepos.y = flamepos.y+3
		effect = 107
	elseif a == 3 then
		flamepos.x = flamepos.x-1
		flamepos.y = flamepos.y+1
		effect = 108
	end

        doMoveInArea(cid, 0, 2, flamek, min, max, FIREDAMAGE)
		doSendMagicEffect(flamepos, effect)  
     

elseif spell == "Fireball" then

	doSendDistanceShoot(getThingPos(cid), getThingPositionWithDebug(target), 3)

	local function damage(cid, target)
		if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, FIREDAMAGE, getThingPositionWithDebug(target), waba, -min, -max, 5)
	end

	addEvent(damage, 100, cid, target)
	
elseif spell == "Fire Fang" then

	doSendMagicEffect(getThingPositionWithDebug(target), 138)

		local function doBite(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, FIREDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 15)
		end

	addEvent(doBite, 200, cid, target)
	
elseif spell == "Fire Blast" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area, eff)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, FIREDAMAGE, area, 0, 0, 0, eff)
   doAreaCombatHealth(cid, FIREDAMAGE, area, whirl3, -min, -max, 35)
end
end

for a = 0, 4 do

local t = {
[0] = {60, {x=p.x, y=p.y-(a+1), z=p.z}},           --alterado v2.4
[1] = {61, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {62, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {63, {x=p.x-(a+1), y=p.y, z=p.z}}
}   
addEvent(sendAtk, 300*a, cid, t[d][2], t[d][1])
end
	
elseif spell == "Rage" then
       
       doBuffSyst(cid, 15, 13, getPlayerStorageValue(cid, 36847), spell, true)
      
elseif spell == "Raging Blast" then

                 --cid, effDist, effDano, areaEff, areaDano, element, min, max
       doMoveInAreaMulti(cid, 3, 6, bullet, bulletDano, FIREDAMAGE, min, max) 
       
elseif spell == "Dragon Claw" then

       doAreaCombatHealth(cid, DRAGONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 141)
       
elseif spell == "Wing Attack" or spell == "Steel Wing" then --alterado v2.4

local effectpos = getThingPositionWithDebug(cid)
local effect = 255
local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if a == 0 then
		effect = spell == "Steel Wing" and 251 or 128
		effectpos.x = effectpos.x + 1
		effectpos.y = effectpos.y - 1                   --alterado v2.4
	elseif a == 1 then
		effectpos.x = effectpos.x + 2
		effectpos.y = effectpos.y + 1
		effect = spell == "Steel Wing" and 253 or 129
	elseif a == 2 then
		effectpos.x = effectpos.x + 1
		effectpos.y = effectpos.y + 2
		effect = spell == "Steel Wing" and 252 or 131
	elseif a == 3 then
		effectpos.x = effectpos.x - 1
		effectpos.y = effectpos.y + 1
		effect = spell == "Steel Wing" and 254 or 130
	end

		doSendMagicEffect(effectpos, effect)
		doMoveInArea(cid, 0, 2, wingatk, min, max, FLYINGDAMAGE)
		
elseif spell == "Magma Storm" then

local eff = {35, 35, 6}
local area = {flames2, flames3, flames4}

doMoveInArea(cid, 0, 6, flames1, min, max, FIREDAMAGE)
addEvent(doMoveInArea, 2*450, cid, 0, 2, flames0, min, max, FIREDAMAGE)
for i = 1, 3 do
    addEvent(doMoveInArea, i*450, cid, 0, eff[i], area[i], min, max, FIREDAMAGE)
end

elseif spell == "Bubbles" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 2)
	doAreaCombatHealthAtDistance(cid, WATERDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 25)
	
elseif spell == "Clamp" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 2)
	doAreaCombatHealthAtDistance(cid, WATERDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 53)

elseif spell == "Water Gun" then

	if mydir == 0 then
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg1n, -min, -max, 74)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg2n, -min, -max, 75)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg3n, -min, -max, 76)
	elseif mydir == 2 then
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg1s, -min, -max, 77)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg2s, -min, -max, 75)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg3s, -min, -max, 78)
	elseif mydir == 1 then
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg1e, -min, -max, 69)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg2e, -min, -max, 70)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg3e, -min, -max, 71)
	elseif mydir == 3 then
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg1w, -min, -max, 72)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg2w, -min, -max, 70)
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), wg3w, -min, -max, 73)
	end
	
elseif spell == "Waterball" then
		             
    doSendDistanceShoot(getThingPos(cid), getThingPositionWithDebug(target), 2)

	local function damage(cid, target)
		if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(target), waba, -min, -max, 68)
	end

	addEvent(damage, 100, cid, target)
	
elseif spell == "Aqua Tail" then

	local function rebackSpd(cid, sss)
		if not isCreature(cid) then return true end
		doChangeSpeed(cid, sss)
		setPlayerStorageValue(cid, 446, -1)
	end

	local x = getCreatureSpeed(cid)
	doFaceOpposite(cid)
	doChangeSpeed(cid, -x)
	addEvent(rebackSpd, 400, cid, x)
	setPlayerStorageValue(cid, 446, 1)
	doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 68)
	
elseif spell == "Hydro Cannon" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area, eff)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, WATERDAMAGE, area, 0, 0, 0, eff)
   doAreaCombatHealth(cid, WATERDAMAGE, area, whirl3, -min, -max, 68)
end
end

for a = 0, 4 do

local t = {                                     --alterado v2.4
[0] = {64, {x=p.x, y=p.y-(a+1), z=p.z}},
[1] = {65, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {66, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {67, {x=p.x-(a+1), y=p.y, z=p.z}}
}   
addEvent(sendAtk, 300*a, cid, t[d][2], t[d][1])
end
	
elseif spell == "Harden" or spell == "Calm Mind" or spell == "Defense Curl" or spell == "Charm" then	
                                                                    --alterado v2.4
    if spell == "Calm Mind" then
       eff = 133
    elseif spell == "Charm" then
       eff = 147                ----alterado v2.4   efeito n eh esse..
    else                             
       eff = 144
    end
	doBuffSyst(cid, 8, eff, getPlayerStorageValue(cid, 36847), spell, true)


elseif spell == "Bubble Blast" then

                 --cid, effDist, effDano, areaEff, areaDano, element, min, max
       doMoveInAreaMulti(cid, 2, 68, bullet, bulletDano, WATERDAMAGE, min, max)
      
elseif spell == "Skull Bash" then

       doMoveInArea(cid, 0, 118, reto5, min, max, NORMALDAMAGE, spell)              

elseif spell == "Hydropump" then

local pos = getThingPositionWithDebug(cid)

	local function doSendBubble(cid, pos)
		if not isCreature(cid) then return true end
		if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		if isSleeping(cid) then return true end
		doSendDistanceShoot(getThingPositionWithDebug(cid), pos, 2)
		doSendMagicEffect(pos, 53)
	end
	                                                          --alterado!!
	for a = 1, 20 do
	    local lugar = {x = pos.x + math.random(-4, 4), y = pos.y + math.random(-3, 3), z = pos.z}
	    addEvent(doSendBubble, a * 25, cid, lugar)
	end
	addEvent(doAreaCombatHealth, 150, cid, WATERDAMAGE, pos, waterarea, -min, -max, 255)

elseif spell == "String Shot" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 23)
if canAttackOther(cid, target) == "Can" then
   addEvent(doMissSyst, 100, target, 6, 137, getPlayerStorageValue(target, 32659), 1)
end

elseif spell == "Bug Bite" then

	doSendMagicEffect(getThingPositionWithDebug(target), 244)

		local function doBite(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, BUGDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 8)
		end

	addEvent(doBite, 200, cid, target)

elseif spell == "Super Sonic" then

	local rounds = math.random(4, 7)
	rounds = rounds + math.floor(getPokemonLevel(cid) / 35)

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 32)
    doAdvancedConfuse(target, rounds, getPlayerStorageValue(target, 3891), cid)
    
elseif spell == "Whirlwind" then

addEvent(doMoveInArea, 0, cid, 0, 42, SL1, min, max, FLYINGDAMAGE, spell)
addEvent(doMoveInArea, 300, cid, 0, 42, SL2, min, max, FLYINGDAMAGE, spell)
addEvent(doMoveInArea, 600, cid, 0, 42, SL3, min, max, FLYINGDAMAGE, spell)
addEvent(doMoveInArea, 900, cid, 0, 42, SL4, min, max, FLYINGDAMAGE, spell)
	
elseif spell == "Psybeam" then

local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)
local t = {
[0] = 57,
[1] = 234,
[2] = 58,
[3] = 209,
}

doMoveInArea(cid, 0, t[a], reto4, min, max, psyDmg, spell)   --alterado v2.4

elseif spell == "Sand Attack" then

mydirr = getCreatureLookDir(cid)
if mydir == 0 then    --norte	
   effect = 120	
elseif mydir == 2 then  --sul                   
   effect = 122		
elseif mydir == 1 then  --leste
   effect = 121	
elseif mydir == 3 then   --oeste
   effect = 119	
end

                  --(cid, area, eff, cd, nameAtk, cond, element, min, max)
doMoveInAreaWithMiss(cid, reto5, effect, 9, spell, 1, null, 0, 0)


elseif spell == "Confusion" or spell == "Night Shade" then

    local rounds = math.random(4, 7)       --rever area...
    rounds = rounds + math.floor(getPokemonLevel(cid) / 35)
    
    if spell == "Confusion" then
       dano = psyDmg --alterado v2.4
    else
       dano = ghostDmg
    end

	doMoveInArea(cid, rounds, 136, selfArea1, min, max, dano)
	
elseif spell == "Horn Attack" then
       
       doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 15)
	   addEvent(doAreaCombatWithDelay, getDistDelay, cid, target, getThingPositionWithDebug(target), 0, NORMALDAMAGE, 3, -min, -max)

elseif spell == "Poison Sting" then
       
		doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 15)
		doAreaCombatHealthAtDistance(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 8)
		
elseif spell == "Fury Cutter" or spell == "Red Fury" then  --alterado v2.4

       local effectpos = getThingPositionWithDebug(cid)
       local effect = 255
       local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if a == 0 then
	    if getCreatureName(cid) == "Scizor" then
	       effect = 236
	    else
		   effect = 128
	    end
		effectpos.x = effectpos.x + 1
		effectpos.y = effectpos.y - 1
	elseif a == 1 then
		effectpos.x = effectpos.x + 2
		effectpos.y = effectpos.y + 1
		if getCreatureName(cid) == "Scizor" then
	       effect = 232
	    else
		   effect = 129
	    end
	elseif a == 2 then
		effectpos.x = effectpos.x + 1
		effectpos.y = effectpos.y + 2
		if getCreatureName(cid) == "Scizor" then
	       effect = 233
	    else
		   effect = 131
	    end
	elseif a == 3 then
		effectpos.x = effectpos.x - 1
		effectpos.y = effectpos.y + 1
		if getCreatureName(cid) == "Scizor" then
	       effect = 224
	    else
		   effect = 130
	    end
	end
        local function doFury(cid, effect)
        if not isCreature(cid) then return true end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
        if isSleeping(cid) then return true end
		   doSendMagicEffect(effectpos, effect)
		   doMoveInArea(cid, 0, 2, wingatk, min, max, BUGDAMAGE)
        end 
        
        addEvent(doFury, 0, cid, effect)
        addEvent(doFury, 350, cid, effect)
        
elseif spell == "Pin Missile" then

       doMoveInAreaMulti(cid, 13, 7, bullet, bulletDano, BUGDAMAGE, min, max)
       
elseif spell == "Strafe" or spell == "Agility" then

doBuffSyst(cid, 15, 14, getPlayerStorageValue(cid, 36847), spell, true)
    
elseif spell == "Gust" then

       doMoveInArea(cid, 0, 42, reto5, min, max, FLYINGDAMAGE, spell) 
       
elseif spell == "Drill Peck" then
	
doAreaCombatHealth(cid, FLYINGDAMAGE, getThingPos(target), 0, -min, -max, 148)

elseif spell == "Tornado" then

    local pos = getThingPositionWithDebug(cid)

	local function doSendTornado(cid, pos)
		if not isCreature(cid) then return true end
		if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		if isSleeping(cid) then return true end
		doSendDistanceShoot(getThingPositionWithDebug(cid), pos, 22)
		doSendMagicEffect(pos, 42)
	end

	for b = 1, 3 do
		for a = 1, 20 do
			local lugar = {x = pos.x + math.random(-4, 4), y = pos.y + math.random(-3, 3), z = pos.z}
			addEvent(doSendTornado, a * 75, cid, lugar)
		end
	end
	doAreaCombatHealth(cid, FLYINGDAMAGE, pos, waterarea, -min, -max, 255)
	
elseif spell == "Bite" or tonumber(spell) == 5 then

	doAreaCombatHealth(cid, DARKDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 146)
	
elseif spell == "Super Fang" then

	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 244)
	
elseif spell == "Poison Fang" then

	doSendMagicEffect(getThingPositionWithDebug(target), 244)

		local function doBite(cid, target)
		if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 114)
		end

	addEvent(doBite, 200, cid, target)
	
elseif spell == "Sting Gun" then
       
       local function doGun(cid, target)
       if not isCreature(cid) or not isCreature(target) then return true end
       if getPlayerStorageValue(cid, 3894) >= 1 then return true end
       if isSleeping(cid) then return true end
       doSendDistanceShoot(getThingPos(cid), getThingPositionWithDebug(target), 13)
       doAreaCombatHealthAtDistance(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 8)
       end

	   addEvent(doGun, 0, cid, target)
       addEvent(doGun, 100, cid, target)
       addEvent(doGun, 200, cid, target)  
       
elseif spell == "Acid" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 14)
	doAreaCombatHealthAtDistance(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 20)
	
elseif spell == "Fear" or spell == "Roar" then

    local rounds = 5

	local uid = checkAreaUid(getCreaturePosition(cid), confusion, 1, 1)
    for _,pid in pairs(uid) do
        if isSummon(cid) and (isMonster(pid) or isSummon(pid)) and pid ~= cid then
           if isSummon(pid) and canAttackOther(cid, pid) == "Can" then
              addEvent(doAdvancedFear, 300, pid, rounds, getPlayerStorageValue(pid, 3894), cid, spell)
           elseif isMonster(pid) then
              addEvent(doAdvancedFear, 300, pid, rounds, getPlayerStorageValue(pid, 3894), cid, spell)
           end
        elseif isMonster(cid) and (isSummon(pid) or isPlayer(pid)) and pid ~= cid then
           if isPlayer(pid) and #getCreatureSummons(pid) <= 0 then
              addEvent(doAdvancedFear, 300, pid, rounds, getPlayerStorageValue(pid, 3894), cid, spell)
           elseif isSummon(pid) then
              addEvent(doAdvancedFear, 300, pid, rounds, getPlayerStorageValue(pid, 3894), cid, spell)
           end
        end
    end 
    
elseif spell == "Iron Tail" then

	local function rebackSpd(cid, sss)
		if not isCreature(cid) then return true end
		doChangeSpeed(cid, sss)
		setPlayerStorageValue(cid, 446, -1)
	end

	local x = getCreatureSpeed(cid)
	doFaceOpposite(cid)
	doChangeSpeed(cid, -x)
	addEvent(rebackSpd, 400, cid, x)
	setPlayerStorageValue(cid, 446, 1)
	doAreaCombatHealth(cid, STEELDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 160)
	
elseif spell == "Thunder Shock" then
                                     
	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 40)
	doAreaCombatHealthAtDistance(cid, ELECTRICDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 48)

elseif spell == "Thunder Bolt" then

		local function doThunderHit(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
			if getPlayerStorageValue(cid, 3894) >= 1 then return true end
            if isSleeping(cid) then return true end
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 48)
		end

		local function doThunderFall(cid, frompos, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local ry = math.abs(frompos.y - pos.y)
		doSendDistanceShoot(frompos, getThingPositionWithDebug(target), 41)
		addEvent(doThunderHit, ry * 11, cid, target)
		end

		local function doThunderUp(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local mps = getThingPositionWithDebug(cid)
		local xrg = math.floor((pos.x - mps.x) / 2)
		local topos = mps
		topos.x = topos.x + xrg
		local rd =  7
		topos.y = topos.y - rd
		doSendDistanceShoot(getThingPositionWithDebug(cid), topos, 41)
		addEvent(doThunderFall, rd * 49, cid, topos, target)
		end		

	local alvo = target

	for thnds = 1, 2 do
		addEvent(doThunderUp, thnds * 155, cid, alvo)
	end
	
elseif spell == "Thunder Wave" then

                  --(cid, area, eff, cd, nameAtk, cond, element, min, max)
doMoveInAreaWithMiss(cid, tw1, 48, 9, spell, 1, ELECTRICDAMAGE, min, max)

elseif spell == "Thunder" then

                  --(cid, area, eff, cd, nameAtk, cond, element, min, max)
doMoveInAreaWithMiss(cid, thunderr, 48, 9, spell, 1, ELECTRICDAMAGE, min, max)

elseif spell == "Mega Kick" then

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
	doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 113)
	
elseif spell == "Thunder Punch" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
    doSendMagicEffect(getThingPositionWithDebug(target), 112)

		local function doPunch(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 48)
		end

	addEvent(doPunch, 200, cid, target)
	
elseif spell == "Electric Storm" then             

local master = isSummon(cid) and getCreatureMaster(cid) or cid

local function doFall(cid)
for rocks = 1, 42 do
    addEvent(fall, rocks*35, cid, master, ELECTRICDAMAGE, 41, 48)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, 41)
end                                         --alterado v2.4
addEvent(doFall, 450, cid)
addEvent(doMoveInAreaWithMiss, 1400, cid, BigArea2, 48, 9, spell, 1, ELECTRICDAMAGE, min, max)	

elseif spell == "Mud Shot" or spell == "Mud Slap" then
    
	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 6)
	doTargetCombatHealth(cid, target, GROUNDDAMAGE, -min, -max, 34)
	if canDoMiss(target, spell) then
	   doMissSyst(target, 9, 34, getPlayerStorageValue(target, 32659), 1)
    end
 
elseif spell == "Rollout" then
local outfits = {
["Voltorb"] = {lookType = 638},
["Electrode"] = {lookType = 637},
["Sandshrew"] = {lookType = 635},
["Sandslash"] = {lookType = 636},
["Phanpy"] = {lookType = 1005},
["Donphan"] = {lookType = 1456},  --alterado v2.4
["Miltank"] = {lookType = 1006},
["Golem"] = {lookType = 639},
["Shiny Electrode"] = {lookType = 1387},
["Shiny Sandshrew"] = {lookType = 1390},
["Shiny Sandslash"] = {lookType = 1389},
["Shiny Golem"] = {lookType = 639},
["Shiny Voltorb"] = {lookType = 1388}
}

	if outfits[getCreatureName(cid)] then
		doSetCreatureOutfit(cid, outfits[getCreatureName(cid)], 8300)
	end

	--doCreatureAddCondition(cid, rollspeedcondition)

	local outfit = getCreatureOutfit(cid).lookType

    local function roll(cid, outfit)
    if not isCreature(cid) then return true end
    if getCreatureOutfit(cid).lookType ~= outfit then return true end
       doAreaCombatHealth(cid, ROCKDAMAGE, getThingPositionWithDebug(cid), splash, -min, -max, 255)
    end

    for r = 1, 11 do  --8
        addEvent(roll, 750 * r, cid, outfit)
    end
    
elseif spell == "Shockwave" then

	local posicao = getThingPositionWithDebug(cid)
		
	local function doShockWave(cid, pos, varx, vary, effect)
	if isCreature(cid) and isSightClear(posicao, pos, false) then
	if getPlayerStorageValue(cid, 3894) >= 1 then return true end
    if isSleeping(cid) then return true end
	   doAreaCombatHealth(cid, GROUNDDAMAGE, pos, whirl3, -min, -max, 255)
	   doSendMagicEffect({x = pos.x + varx, y = pos.y + vary, z = pos.z}, effect)
	end
	end

	local effect = 255
	local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if a == 0 then
		effect = 126
		for sw = 0, 5 do
			addEvent(doShockWave, 325 * sw, cid, {x = posicao.x, y = posicao.y - (sw + 1), z = posicao.z}, 1, 1, effect)
		end
	elseif a == 2 then
		effect = 125
		for sw = 0, 5 do
			addEvent(doShockWave, 325 * sw, cid, {x = posicao.x, y = posicao.y + (sw + 1), z = posicao.z}, 1, 1, effect)
		end
	elseif a == 1 then
		effect = 124
		for sw = 0, 5 do
			addEvent(doShockWave, 325 * sw, cid, {x = posicao.x + (sw + 1), y = posicao.y, z = posicao.z}, 1, 1, effect)
		end
	elseif a == 3 then
		effect = 123
		for sw = 0, 5 do
			addEvent(doShockWave, 325 * sw, cid, {x = posicao.x - (sw + 1), y = posicao.y, z = posicao.z}, 1, 1, effect)
		end
	end
	
elseif spell == "Earthshock" then

	doAreaCombatHealth(cid, GROUNDDAMAGE, getThingPositionWithDebug(cid), splash, -min, -max, 255)

	local sps = getThingPositionWithDebug(cid)
	sps.x = sps.x+1
	sps.y = sps.y+1
	doSendMagicEffect(sps, 127)
	
elseif spell == "Earthquake" then

local eff = getCreatureName(cid) == "Shiny Onix" and 175 or 118
 
local function doQuake(cid)
if not isCreature(cid) then return false end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
doMoveInArea(cid, 0, eff, confusion, min, max, GROUNDDAMAGE, spell)
end

times = {0, 500, 1000, 1500, 2300, 2800, 3300, 3800, 4600, 5100, 5600, 6100, 6900, 7400, 7900, 8400, 9200, 10000}

for i = 1, #times do                   --alterado v2.4
    addEvent(doQuake, times[i], cid)
end
	
	
elseif spell == "Stomp" then
       
       doMoveInAreaWithMiss(cid, stomp, 34, 9, spell, 1, GROUNDDAMAGE, min, max)
       
elseif spell == "Toxic Spikes" then
       
       local function doToxic(cid, target)
       if not isCreature(cid) or not isCreature(target) then return true end
       if isSleeping(cid) then return false end
       if getPlayerStorageValue(cid, 3894) >= 1 then return true end
          doSendDistanceShoot(getThingPos(cid), getThingPositionWithDebug(target), 15)
          doAreaCombatHealthAtDistance(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 114)
       end

	   addEvent(doToxic, 0, cid, target)
       addEvent(doToxic, 300, cid, target)
       --addEvent(doToxic, 400, cid, target) 
       
elseif spell == "Horn Drill" then
       
       local function doHorn(cid, target)
       if not isCreature(cid) or not isCreature(target) then return true end
       if isSleeping(cid) then return false end
       if getPlayerStorageValue(cid, 3894) >= 1 then return true end
          doSendDistanceShoot(getThingPos(cid), getThingPositionWithDebug(target), 25)
          doAreaCombatHealthAtDistance(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 0)
       end

	   addEvent(doHorn, 0, cid, target)
       addEvent(doHorn, 300, cid, target)
       
elseif spell == "Doubleslap" then
       
	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPos(target), 0, -min, -max, 148)
    
elseif spell == "Lovely Kiss" then 
    
	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 16)
	doSendMagicEffect(getThingPos(target), 147)
	if canAttackOther(cid, target) == "Can" then
	   doMissSyst(target, 9, 147, getPlayerStorageValue(target, 32659), 1)
    end
    
elseif spell == "Sing" then

	doAreaCombatHealth(cid, SLEEP_POWDERDAMAGE, getThingPositionWithDebug(cid), powders, -6, -10, 33) 
    
elseif spell == "Multislap" then

       doAreaCombatHealth(cid, NORMALDAMAGE, getThingPos(cid), splash, -min, -max, 3)
       
elseif spell == "Metronome" then

local spells = {"Shadow Storm", "Electric Storm", "Magma Storm", "Blizzard", "Leaf Storm", "Hydropump", "Falling Rocks"}

    local random = math.random(1, #spells)

	local randommove = spells[random]
	local pos = getThingPos(cid)
	pos.y = pos.y - 1

	doSendMagicEffect(pos, 161)
	
	local function doMetronome(cid, spell)
	if not isCreature(cid) then return true end
    docastspell(cid, spell)
    doCreatureSay(cid, ""..string.upper(spell).."!", TALKTYPE_MONSTER)
    end
    
    addEvent(doMetronome, 100, cid, randommove)
    
elseif spell == "Focus" or spell == "Charge" or spell == "Swords Dance" then
                                                    --alterado v2.4
       if spell == "Charge" then
          doSendAnimatedText(getThingPos(cid), "CHARGE", 168)
          doSendMagicEffect(getThingPos(cid), 177)
       elseif spell == "Swords Dance" then
           doSendMagicEffect(getThingPos(cid), 132) 
       else
           doSendAnimatedText(getThingPos(cid), "FOCUS", 144)
           doSendMagicEffect(getThingPos(cid), 132)
       end
       setPlayerStorageValue(cid, 253, 1)
       
elseif spell == "Flame Wheel" then

    local function sendFireEff(cid, dir)
    if not isCreature(cid) then return true end
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
       doAreaCombatHealth(cid, FIREDAMAGE, getPosByDir(getThingPositionWithDebug(cid), dir), 0, -min, -max, 15)
	end

	local function doWheel(cid)
	if not isCreature(cid) then return true end
	local t = {
	      [1] = SOUTH,
	      [2] = SOUTHEAST,
	      [3] = EAST,
	      [4] = NORTHEAST,
	      [5] = NORTH,        --alterado!
	      [6] = NORTHWEST,
	      [7] = WEST,
	      [8] = SOUTHWEST,
		}
		for a = 1, 8 do
            addEvent(sendFireEff, a * 140, cid, t[a])
		end
	end

	doWheel(cid, false, cid)
    
elseif spell == "Hyper Voice" then

       doMoveInAreaWithMiss(cid, tw1, 22, 9, spell, 0, NORMALDAMAGE, min, max)

elseif spell == "Restore" or spell == "Selfheal" then
	
	local min = (getCreatureMaxHealth(cid) * 75) / 100
	local max = (getCreatureMaxHealth(cid) * 85) / 100
	
	local function doHealArea(cid, min, max)
    local amount = math.random(min, max)
    if (getCreatureHealth(cid) + amount) >= getCreatureMaxHealth(cid) then
        amount = -(getCreatureHealth(cid)-getCreatureMaxHealth(cid))
    end
    if getCreatureHealth(cid) ~= getCreatureMaxHealth(cid) then
       doCreatureAddHealth(cid, amount)
       doSendAnimatedText(getThingPos(cid), "+"..amount.."", 65)
    end
    end
    
	doSendMagicEffect(getThingPositionWithDebug(cid), 132)
    doHealArea(cid, min, max)
    
	
elseif spell == "Healarea" then
	
	local min = (getCreatureMaxHealth(cid) * 50) / 100
	local max = (getCreatureMaxHealth(cid) * 60) / 100
    
    local function doHealArea(cid, min, max)
    local amount = math.random(min, max)
    if (getCreatureHealth(cid) + amount) >= getCreatureMaxHealth(cid) then
        amount = -(getCreatureHealth(cid)-getCreatureMaxHealth(cid))
    end
    if getCreatureHealth(cid) ~= getCreatureMaxHealth(cid) then
       doCreatureAddHealth(cid, amount)
       doSendAnimatedText(getThingPos(cid), "+"..amount.."", 65)
    end
    end
    
    local pos = getPosfromArea(cid, heal)
    local n = 0

    while n < #pos do
    n = n+1
    thing = {x=pos[n].x,y=pos[n].y,z=pos[n].z,stackpos=253}
    local pid = getThingFromPosWithProtect(thing)
    doSendMagicEffect(pos[n], 12)
    doHealArea(cid, min, max)
    if isCreature(pid) then
       if isSummon(cid) and (isSummon(pid) or isPlayer(pid)) then
          if canAttackOther(cid, pid) == "Cant" then
             doHealArea(pid, min, max)
          end
       elseif isSummon(cid) and isMonster(pid) then
          
       elseif isMonster(cid) and isMonster(pid) then
          doHealArea(pid, min, max)
       end
    end 
    end
    
elseif spell == "Toxic" then

       doMoveInArea(cid, 0, 114, reto5, min, max, POISONDAMAGE, spell)
       
elseif spell == "Absorb" then

	local life = getCreatureHealth(target)

	doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(target), 0, -min*2, -max*2, 14)
    
	local newlife = life - getCreatureHealth(target)

	doSendMagicEffect(getThingPositionWithDebug(cid), 14)
	if newlife >= 1 then
	doCreatureAddHealth(cid, newlife)
	doSendAnimatedText(getThingPositionWithDebug(cid), "+"..newlife.."", 32)
	end  
	
elseif spell == "Poison Bomb" then

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 14)
    doAreaCombatHealthAtDistance(cid, POISONDAMAGE, getThingPositionWithDebug(target), bombWee2, -min, -max, 20)

elseif spell == "Poison Gas" then 

local function gas(cid)
		if not isCreature(cid) then return true end
		if isSleeping(cid) then return false end
		if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		   doMoveInAreaWithMiss(cid, confusion, 114, 13, spell, 0, POISONDAMAGE, min, max)
	end
    	
times = {0, 500, 1000, 1500, 2300, 2800, 3300, 3800, 4600, 5100, 5600, 6100, 6900, 7400, 7900, 8400, 9200, 10000}

for i = 1, #times do
    addEvent(gas, times[i], cid)                                --alterado v2.4
end
	
elseif spell == "Petal Dance" then

       doMoveInAreaMulti(cid, 21, 245, bullet, bulletDano, GRASSDAMAGE, min, max)
       
elseif spell == "Slash" then

	doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 159)
	
elseif spell == "X-Scissor" then

local a = getThingPos(cid)
 
local X = {
{{x = a.x+1, y = a.y, z = a.z}, 16}, --norte
{{x = a.x+2, y = a.y+1, z = a.z}, 221}, --leste
{{x = a.x+1, y = a.y+2, z = a.z}, 223}, --sul
{{x = a.x, y = a.y+1, z = a.z}, 243}, --oeste
}

local pos = X[mydir+1]

for b = 1, 3 do
    addEvent(doSendMagicEffect, b * 70, pos[1], pos[2])
end
	
doMoveInArea(cid, 0, 2, xScissor, min, max, BUGDAMAGE, spell)
	
elseif spell == "Psychic" then
                                 
	doAreaCombatHealth(cid, psyDmg, getThingPositionWithDebug(cid), selfArea2, -min, -max, 133)      --alterado v2.4
	
elseif spell == "Pay Day" then
                   
        local function doThunderHit(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
			if isSleeping(cid) then return false end
		    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		       doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 28)
		end

		local function doThunderFall(cid, frompos, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local ry = math.abs(frompos.y - pos.y)
		doSendDistanceShoot(frompos, getThingPositionWithDebug(target), 39)
		addEvent(doThunderHit, ry * 11, cid, target)
		end

		local function doThunderUp(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local mps = getThingPositionWithDebug(cid)
		local xrg = math.floor((pos.x - mps.x) / 2)
		local topos = mps
		topos.x = topos.x + xrg
		local rd =  7
		topos.y = topos.y - rd
		doSendDistanceShoot(getThingPositionWithDebug(cid), topos, 39)
		addEvent(doThunderFall, rd * 49, cid, topos, target)
		end		

	local alvo = target

	for thnds = 1, 2 do
		addEvent(doThunderUp, thnds * 155, cid, alvo)
	end 
    
elseif spell == "Psywave" then

          --(cid, rounds, eff, area, min, max, element, spell)
doMoveInArea(cid, 0, 133, tw1, min, max, psyDmg, spell)      --alterado v2.4             

elseif spell == "Triple Kick" or spell == "Triple Kick Lee" then

	doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPos(target), 0, -min, -max, 110)
	
elseif spell == "Karate Chop" then
    
    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
	doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPos(target), 0, -min, -max, 113)
	
elseif spell == "Ground Chop" then

      doMoveInArea(cid, 0, 111, reto5, min, max, FIGHTINGDAMAGE, spell)
      
elseif spell == "Mega Punch" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
	doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPos(target), 0, -min, -max, 112)
    
elseif spell == "Tri Flames" then

       doMoveInArea(cid, 0, 6, triflames, min, max, FIREDAMAGE)
       
elseif spell == "War Dog" then

     doBuffSyst(cid, 15, 28, getPlayerStorageValue(cid, 36847), spell, true)
            
elseif spell == "Hypnosis" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 24)
	doAreaCombatHealthAtDistance(cid, SLEEP_POWDERDAMAGE, getThingPositionWithDebug(target), 0, -5, -9, 255)
	
elseif spell == "Dizzy Punch" then

		doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 26)
		doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 112)
		local rounds = getPokemonLevel(cid) / 12
		rounds = rounds + 2
		doAdvancedConfuse(target, rounds, getPlayerStorageValue(target, 3891))
		
elseif spell == "Ice Punch" then

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 28)
	doSendMagicEffect(getThingPositionWithDebug(target), 112)

		local function doPunch(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 43)
		end

	addEvent(doPunch, 200, cid, target)
	
elseif spell == "Ice Beam" then

	local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

    doMoveInAreaWithMiss(cid, reto5, 43, 9, spell, 1, ICEDAMAGE, 0, 0)
	if a == 0 then
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg1n, -min, -max, 99)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg2n, -min, -max, 105)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg3n, -min, -max, 103)
	elseif a == 2 then
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg1s, -min, -max, 98)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg2s, -min, -max, 105)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg3s, -min, -max, 102)
	elseif a == 1 then
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg1e, -min, -max, 96)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg2e, -min, -max, 104)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg3e, -min, -max, 100)
	elseif a == 3 then
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg1w, -min, -max, 97)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg2w, -min, -max, 104)
		doAreaCombatHealth(cid, ICEDAMAGE, getThingPositionWithDebug(cid), wg3w, -min, -max, 101)
	end
	
elseif spell == "Psy Pulse" or spell == "Cyber Pulse" or spell == "Dark Pulse" then

damage = skill == "Dark Pulse" and DARKDAMAGE or psyDmg

local function doPulse(cid, eff)
if not isCreature(cid) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
   doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 3)
   doTargetCombatHealth(cid, target, damage, -min, -max, eff)      --alterado v2.4
end

   if spell == "Cyber Pulse" then
      eff = 11
   elseif spell == "Dark Pulse" then
      eff = 47  --alterado v2.4 efeito n eh esse mas... ;p
   else
      eff = 133
   end 
   addEvent(doPulse, 0, cid, eff)                
   addEvent(doPulse, 250, cid, eff)
    
elseif spell == "Psyusion" then

       local rounds = math.random(4, 7)
       rounds = rounds + math.floor(getPokemonLevel(cid) / 35)
       local eff = {136, 133, 136, 133}
       local area = {psy1, psy2, psy3, psy4}

        --doMoveInArea(cid, rounds, eff, area, min, max, element, spell)
       doMoveInArea(cid, rounds, 136, psy1, min, max, psyDmg, spell) --alterado v2.4
       addEvent(doMoveInArea, 3*400, cid, rounds, 137, psy5, min, max, psyDmg, spell) --alterado v2.4
       for i = 1, 3 do
           addEvent(doMoveInArea, i*400, cid, rounds, eff[i+1], area[i+1], min, max, psyDmg, spell)     --alterado v2.4
       end	
       
elseif spell == "Triple Punch" then

	doAreaCombatHealth(cid, FIGHTINGDAMAGE, getThingPos(target), 0, -min, -max, 110)
	
elseif spell == "Fist Machine" then

	local mpos = getThingPositionWithDebug(cid)
	local b = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)
	local effect = 0
	local xvar = 0
	local yvar = 0

	if b == SOUTH then
		effect = 218
		yvar = 2
	elseif b == NORTH then
		effect = 217
	elseif b == WEST then
		effect = 216
	elseif b == EAST then
		effect = 215
		xvar = 2
	end

	mpos.x = mpos.x + xvar
	mpos.y = mpos.y + yvar         

	doSendMagicEffect(mpos, effect)
	doMoveInArea(cid, 0, 0, machine, min, max, FIGHTINGDAMAGE)
	
elseif spell == "Destroyer Hand" then

       doMoveInAreaMulti(cid, 26, 0, bullet, bulletDano, FIGHTINGDAMAGE, min, max)
       
elseif spell == "Rock Throw" then

local effD = getCreatureName(cid) == "Shiny Onix" and 0 or 11
local eff = getCreatureName(cid) == "Shiny Onix" and 176 or 44  --alterado v2.4

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), effD)
	doAreaCombatHealthAtDistance(cid, ROCKDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, eff)
	
elseif spell == "Rock Slide" or spell == "Stone Edge" then

atk = {
["Rock Slide"] = {11, 44, 0, 176},--alterado v2.4
["Stone Edge"] = {11, 239}
}                          

local effD = getCreatureName(cid) == "Shiny Onix" and atk[spell][3] or atk[spell][1]
local eff = getCreatureName(cid) == "Shiny Onix" and atk[spell][4] or atk[spell][2]

		local function doRockHit(cid, target)
        if not isCreature(target) or not isCreature(cid) then return true end
        if isSleeping(cid) then return false end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		   doAreaCombatHealth(cid, ROCKDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, eff)
		end

		local function doRockFall(cid, frompos, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local ry = math.abs(frompos.y - pos.y)
		doSendDistanceShoot(frompos, getThingPositionWithDebug(target), effD)
		addEvent(doRockHit, ry * 11, cid, target)
		end

		local function doRockUp(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local mps = getThingPositionWithDebug(cid)
		local xrg = math.floor((pos.x - mps.x) / 2)
		local topos = mps
		topos.x = topos.x + xrg
		local rd =  7
		topos.y = topos.y - rd
		doSendDistanceShoot(getThingPositionWithDebug(cid), topos, effD)
		addEvent(doRockFall, rd * 49, cid, topos, target)
		end		

	local alvo = target

	for thnds = 1, 2 do
		addEvent(doRockUp, thnds * 155, cid, alvo)
	end 
	
elseif spell == "Falling Rocks" then

local effD = getCreatureName(cid) == "Shiny Onix" and 0 or 11
local eff = getCreatureName(cid) == "Shiny Onix" and 176 or 44
local master = isSummon(cid) and getCreatureMaster(cid) or cid
------------

local function doFall(cid)
for rocks = 1, 62 do
    addEvent(fall, rocks*35, cid, master, ROCKDAMAGE, effD, eff)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, effD)        --alterado v2.4
end
addEvent(doFall, 450, cid)
addEvent(doAreaCombatHealth, 1400, cid, ROCKDAMAGE, getThingPos(cid), waterarea, -min, -max, 255)

elseif spell == "Selfdestruct" then
                                         
		local function death(cid)
			if isCreature(cid) then
			if pokes[getCreatureName(cid)].type == "psychic" or pokes[getCreatureName(cid)].type2 == "psychic" then return true end
			doCreatureAddHealth(cid, -getCreatureMaxHealth(cid))
			end
		end

        doMoveInArea(cid, 0, 5, selfArea1, 0, 0, null, spell)
        
        local life = getCreatureHealth(cid)
        local uid = checkAreaUid(getCreaturePosition(cid), selfArea1, 1, 1)
        for _,pid in pairs(uid) do
            if isCreature(pid) then                                   --alterado!
               if (getCreatureHealth(pid)-life) <= 0 then
                  dano = getCreatureHealth(pid)
               else
                  dano = life
               end
               if isSummon(cid) and canDoSelf and pid ~= cid then
                  if isSummon(pid) then
                     if canAttackOther(cid, pid) == "Cant" then
                     else
                        doSendAnimatedText(getThingPos(pid), "-"..dano.."", COLOR_NORMAL)
                        doCreatureAddHealth(pid, -dano)
                     end
                  elseif isMonster(pid) then
                     doSendAnimatedText(getThingPos(pid), "-"..dano.."", COLOR_NORMAL)
                     doCreatureAddHealth(pid, -dano)
                  elseif isPlayer(pid) and #getCreatureSummons(pid) <= 0 and canAttackOther(cid, pid) == "Can" then
                     doSendAnimatedText(getThingPos(pid), "-"..dano.."", COLOR_NORMAL)
                     doCreatureAddHealth(pid, -dano)
                  end
               elseif isMonster(cid) and canDoSelf and pid ~= cid then
                  if isSummon(pid) then
                     doSendAnimatedText(getThingPos(pid), "-"..dano.."", COLOR_NORMAL)  --144
                     doCreatureAddHealth(pid, -dano)
                  elseif isPlayer(pid) and #getCreatureSummons(pid) <= 0 then
                     doSendAnimatedText(getThingPos(pid), "-"..dano.."", COLOR_NORMAL)  --144
                     doCreatureAddHealth(pid, -dano)
                  end
               end
            end
        end
             
		addEvent(death, 300, cid)
		
elseif spell == "Crusher Stomp" then
       
local pL = getThingPos(cid)
pL.x = pL.x+5
pL.y = pL.y+1 
-----------------
local pO = getThingPos(cid)
pO.x = pO.x-3
pO.y = pO.y+1 
------------------
local pN = getThingPos(cid)
pN.x = pN.x+1
pN.y = pN.y+5 
-----------------
local pS = getThingPos(cid)
pS.x = pS.x+1
pS.y = pS.y-3 

local po = {pL, pO, pN, pS}
local po2 = {
{x = pL.x, y = pL.y-1, z = pL.z},
{x = pO.x, y = pO.y-1, z = pO.z},
{x = pN.x-1, y = pN.y, z = pN.z},
{x = pS.x-1, y = pS.y, z = pS.z},
}
for i = 1, 4 do
    doSendMagicEffect(po[i], 127)
    doAreaCombatHealth(cid, GROUNDDAMAGE, po2[i], crusher, -min, -max, 255)
end
doMoveInAreaWithMiss(cid, stomp, 34, 9, spell, 1, GROUNDDAMAGE, min, max)  

elseif spell == "Water Pulse" then

       doMoveInArea(cid, 0, 68, reto5, min, max, WATERDAMAGE, spell) 
       
elseif spell == "Sonicboom" then

local function doBoom(cid)
if not isCreature(cid) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 33)
doAreaCombatHealthAtDistance(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 3)
end

   addEvent(doBoom, 0, cid)
   addEvent(doBoom, 250, cid)
   
elseif spell == "Stickmerang" then   

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 34)
doAreaCombatHealthAtDistance(cid, FLYINGDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 212)

elseif spell == "Stickslash" then

    local function sendStickEff(cid, dir)
    if not isCreature(cid) then return true end
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
       doAreaCombatHealth(cid, FLYINGDAMAGE, getPosByDir(getThingPositionWithDebug(cid), dir), 0, -min, -max, 212)
	end

	local function doStick(cid)
	if not isCreature(cid) then return true end
	local t = {
	      [1] = SOUTHWEST,
	      [2] = SOUTH,
	      [3] = SOUTHEAST,
	      [4] = EAST,
	      [5] = NORTHEAST,
	      [6] = NORTH,
	      [7] = NORTHWEST,
	      [8] = WEST,
	      [9] = SOUTHWEST,
		}
		for a = 1, 9 do
            addEvent(sendStickEff, a * 140, cid, t[a])
		end
	end

	doStick(cid, false, cid)
    
elseif spell == "Stick Throw" then

       local a = getCreatureSpeed(cid)
	   doChangeSpeed(cid, -a)

       
       doMoveInArea(cid, 0, 212, reto4, min, max, FLYINGDAMAGE, spell)
       
       local function nois(cid, s)
       if not isCreature(cid) then return true end
       if isSleeping(cid) then return false end
       if getPlayerStorageValue(cid, 3894) >= 1 then return true end
          doChangeSpeed(cid, s)
	   end

	   addEvent(nois, 2000, cid, a)
       
elseif spell == "Pluck" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
doAreaCombatHealthAtDistance(cid, FLYINGDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 111)

elseif spell == "Tri-Attack" then --alterado v2.3

	local function doTriAtk(cid, target)
    if not isCreature(cid) or not isCreature(target) then return true end   --alterado v2.3
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end             --alterado!!
       doTargetCombatHealth(cid, target, NORMALDAMAGE, -min, -max, 238)
   end
   
   doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
   for i = 1, 3 do
       addEvent(doTriAtk, i*300, cid, target)  --alterado v2.3
   end
    
elseif spell == "Fury Attack" then

    local function doFuryAtk(cid, target)
    if not isCreature(cid) or not isCreature(target) then return true end   --alterado v2.3
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end             --alterado!!
       doTargetCombatHealth(cid, target, NORMALDAMAGE, -min, -max, 110)
    end
   
    for i = 0, 2 do
       addEvent(doFuryAtk, i*300, cid, target)  --alterado v2.3
    end  
    
elseif spell == "Ice Shards" then

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 28)
	doAreaCombatHealthAtDistance(cid, ICEDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 43)
    
elseif spell == "Icy Wind" then                   
	
  doMoveInAreaWithMiss(cid, tw1, 43, 9, spell, 1, ICEDAMAGE, min, max)
  
elseif spell == "Aurora Beam" then

local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)
local p = getThingPos(cid)
local t = {
[0] = {186, {x=p.x+1, y=p.y-1, z=p.z}},
[1] = {187, {x=p.x+6, y=p.y+1, z=p.z}}, 
[2] = {186, {x=p.x+1, y=p.y+6, z=p.z}},
[3] = {187, {x=p.x-1, y=p.y+1, z=p.z}},
}                                             --alterado v2.4

doMoveInAreaWithMiss(cid, triplo6, 0, 9, spell, 1, ICEDAMAGE, min, max)
doSendMagicEffect(t[a][2], t[a][1])

elseif spell == "Rest" then

	doBuffSyst(cid, 6, 0, getPlayerStorageValue(cid, 36847), spell, true)
	
elseif spell == "Sludge" then 

        local function doSludgeHit(cid, target)
        if not isCreature(target) or not isCreature(cid) then return true end
        if isSleeping(cid) then return false end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		   doAreaCombatHealth(cid, POISONDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 116)
		end

		local function doSludgeFall(cid, frompos, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local ry = math.abs(frompos.y - pos.y)
		doSendDistanceShoot(frompos, getThingPositionWithDebug(target), 6)
		addEvent(doSludgeHit, ry * 11, cid, target)
		end

		local function doSludgeUp(cid, target)
			if not isCreature(target) or not isCreature(cid) then return true end
		local pos = getThingPositionWithDebug(target)
		local mps = getThingPositionWithDebug(cid)
		local xrg = math.floor((pos.x - mps.x) / 2)
		local topos = mps
		topos.x = topos.x + xrg
		local rd =  7
		topos.y = topos.y - rd
		doSendDistanceShoot(getThingPositionWithDebug(cid), topos, 6)
		addEvent(doSludgeFall, rd * 49, cid, topos, target)
		end		

	local alvo = target

	for thnds = 1, 2 do
		addEvent(doSludgeUp, thnds * 155, cid, alvo)
	end 
	if canDoMiss(target, spell) then
	   doMissSyst(target, 9, 34, getPlayerStorageValue(target, 32659), 0)  --alterado v2.3
    end

elseif spell == "Mud Bomb" then

   doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 6)
   addEvent(doAreaCombatHealth, 200, cid, GROUNDDAMAGE, getThingPos(target), bombWee2, -min, -max, 116)
--------miss syst--------------
local uid = checkAreaUid(getThingPos(target), bombWee1, 1, 1)
for _,pid in pairs(uid) do
if isCreature(pid) then
    if isSummon(cid) and (isMonster(pid) or isSummon(pid) or isPlayer(pid)) and pid ~= cid then
       if (isSummon(pid) or (isPlayer(pid) and #getCreatureSummons(pid) <= 0)) and canAttackOther(cid, pid) == "Can" and canDoMiss(pid, spell) then
          doMissSyst(pid, 9, 34, getPlayerStorageValue(pid, 32659), 0)
       elseif isMonster(pid) and canDoMiss(pid, spell) then
          doMissSyst(pid, 9, 34, getPlayerStorageValue(pid, 32659), 0)
       end
    elseif isMonster(cid) and (isSummon(pid) or isPlayer(pid)) and pid ~= cid then
       if isPlayer(pid) and #getCreatureSummons(pid) <= 0 then
          doMissSyst(pid, 9, 34, getPlayerStorageValue(pid, 32659), 0)
       elseif isSummon(pid) and canDoMiss(pid, spell) then
          doMissSyst(pid, 9, 34, getPlayerStorageValue(pid, 32659), 0)
       end
    end
end
end 

elseif spell == "Mortal Gas" then

    local pos = getThingPositionWithDebug(cid)

	local function doSendAcid(cid, pos)
		if not isCreature(cid) then return true end
		if isSleeping(cid) then return false end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		doSendDistanceShoot(getThingPositionWithDebug(cid), pos, 14)
		doSendMagicEffect(pos, 114)
	end

	for b = 1, 3 do
		for a = 1, 20 do
			local lugar = {x = pos.x + math.random(-4, 4), y = pos.y + math.random(-3, 3), z = pos.z}
			addEvent(doSendAcid, a * 75, cid, lugar)
		end
	end
	doAreaCombatHealth(cid, POISONDAMAGE, pos, waterarea, -min, -max, 255) 
    
elseif spell == "Rock Drill" or spell == "Megahorn" or spell == "Rock Blast" then

damage = spell == "Megahorn" and BUGDAMAGE or ROCKDAMAGE
eff = spell == "Megahorn" and 8 or 44 
effD = spell == "Rock Blast" and 11 or 25                     --alterado v2.4

                --cid, effDist, effDano, areaEff, areaDano, element, min, max
doMoveInAreaMulti(cid, effD, eff, bullet, bulletDano, damage, min, max)

elseif spell == "Egg Bomb" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 12)
	doAreaCombatHealthAtDistance(cid, NORMALDAMAGE, getThingPositionWithDebug(target), crusher, -min, -max, 5)
    
elseif spell == "Super Vines" then

    doCreatureSetLookDir(cid, 2)
	local a = getCreatureSpeed(cid)
	doChangeSpeed(cid, -a)

	local effect = 0
	local pos = getThingPositionWithDebug(cid)
	pos.x = pos.x + 1
	pos.y = pos.y + 1

	if getCreatureOutfit(cid).lookType == 369 then
		effect = 213
	else
		effect = 229
	end

	doSendMagicEffect(pos, effect)
	doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(cid), splash, -min, -max, 255)

	local function nois(cid, s)
		if not isCreature(cid) then return true end
		if isSleeping(cid) then return false end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
	doChangeSpeed(cid, s)
	end

	addEvent(nois, 200, cid, a)  
    
elseif spell == "Epicenter" then

        doMoveInArea(cid, 0, 127, epicenter, min, max, GROUNDDAMAGE, spell)
        
elseif spell == "Bubblebeam" then

local function sendBubbles(cid)
if not isCreature(cid) or not isCreature(target) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 2)
doAreaCombatHealthAtDistance(cid, WATERDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 25)
end

sendBubbles(cid)
addEvent(sendBubbles, 100, cid) 

elseif  spell == "Swift" then

local function sendSwift(cid)
if not isCreature(cid) or not isCreature(target) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 32)
doAreaCombatHealthAtDistance(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 3)
end

sendSwift(cid)
addEvent(sendSwift, 200, cid) 

elseif spell == "Spark" then
       
doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 32)
doAreaCombatHealthAtDistance(cid, ELECTRICDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 48)--alterado v2.4
   

elseif  spell == "Mimic Wall" then

local p = getThingPos(cid)
local dirr = getCreatureLookDir(cid)

if dirr == 0 or dirr == 2 then
   item = 11439
else
   item = 11440
end

local wall = {
[0] = {{x = p.x, y = p.y-1, z = p.z}, {x = p.x+1, y = p.y-1, z = p.z}, {x = p.x-1, y = p.y-1, z = p.z}},
[2] = {{x = p.x, y = p.y+1, z = p.z}, {x = p.x+1, y = p.y+1, z = p.z}, {x = p.x-1, y = p.y+1, z = p.z}},
[1] = {{x = p.x+1, y = p.y, z = p.z}, {x = p.x+1, y = p.y+1, z = p.z}, {x = p.x+1, y = p.y-1, z = p.z}},
[3] = {{x = p.x-1, y = p.y, z = p.z}, {x = p.x-1, y = p.y+1, z = p.z}, {x = p.x-1, y = p.y-1, z = p.z}},
}

function removeAllActionIDs(pos, onlyOne)
if onlyOne then
    local thing1 = {x=pos.x,y=pos.y,z=pos.z,stackpos=0}
    local tile1 = getTileThingWithProtect(thing1).uid
    doSetItemActionId(tile1, 0)
end  
n = 0
for i = 1, #pos do
    n = n + 1
    thing = {x=pos[n].x,y=pos[n].y,z=pos[n].z,stackpos=0}
    local tile = getTileThingWithProtect(thing).uid
    doSetItemActionId(tile, 0)
end
end   


for i = 1, 3 do
    if wall[dirr] then
       local t = wall[dirr]
       if hasTile(t[i]) and canWalkOnPos(t[i], true, true, true, true, false) then
          doCreateItem(item, 1, t[i])
          --
          local Tile = getTileThingWithProtect({x=t[i].x,y=t[i].y,z=t[i].z,stackpos=0})
          doSetItemActionId(Tile.uid, 88072)
          addEvent(removeAllActionIDs, 15000, t[i], true)
          --
          addEvent(doRemoveItemFromPos, 15000, t[i], item, 1)
       end
    end
end 

local pos = getPosfromArea(cid, wall_1)
local pos2 = getPosfromArea(cid, wall_2)

if hasTile({x=p.x,y=p.y,z=p.z,stackpos=0}) then 
   tile0 = getTileThingWithProtect({x=p.x,y=p.y,z=p.z,stackpos=0}).uid
end
doSetItemActionId(tile0, 88070)
addEvent(removeAllActionIDs, 15000, p, true)

n = 0

while n < #pos do
   if not isCreature(cid) then return true end 
      n = n+1
      local tile1 = getTileThingWithProtect({x=pos[n].x,y=pos[n].y,z=pos[n].z,stackpos=0}).uid
      ---
      local tile2 = getTileThingWithProtect({x=pos2[n].x,y=pos2[n].y,z=pos2[n].z,stackpos=0}).uid
      
      doSetItemActionId(tile1, 88071)
      doSetItemActionId(tile2, 88070)
end
addEvent(removeAllActionIDs, 15000, pos)
addEvent(removeAllActionIDs, 15000, pos2)   
   
elseif spell == "Shredder Team" then

local team = {
["Scyther"] = "ScytherTeam",
["Shiny Scyther"] = "Shiny ScytherTeam",
["Scizor"] = "ScizorTeam",
}

local function setStorage(cid, storage)
if isCreature(cid) then
   if getPlayerStorageValue(cid, storage) >= 1 then
      setPlayerStorageValue(cid, storage, 0)
   end
end
end

local function RemoveTeam(cid)
if isCreature(cid) then
  doSendMagicEffect(getThingPos(cid), 211)
  doRemoveCreature(cid)
end
end

if getPlayerStorageValue(cid, 637500) >= 1 then
return true
end

local master = getCreatureMaster(cid)
local item = getPlayerSlotItem(master, 8)
local life, maxLife = getCreatureHealth(cid), getCreatureMaxHealth(cid)
local name = getItemAttribute(item.uid, "poke")
local pos = getThingPos(cid)
local time = 21
local pokelife = (getCreatureHealth(cid) / getCreatureMaxHealth(cid))

doItemSetAttribute(item.uid, "hp", pokelife)
local random = math.random(5, 10)

doDisapear(cid)
doTeleportThing(cid, {x=4, y=3, z=10}, false)
addEvent(doTeleportThing, random, cid, pos, false)
addEvent(doAppear, random, cid)
if team[name] then
local num = getCreatureName(cid) == "Scizor" and 4 or 3
   for b = 2, num do
       doSummonMonster(master, team[name])
   end
   pk1 = getCreatureSummons(master)[1]
   pk2 = getCreatureSummons(master)[2]
   pk3 = getCreatureSummons(master)[3]
   if getCreatureName(cid) == "Scizor" then
      pk4 = getCreatureSummons(master)[4]
   end
   for a = 1, num do
   local pk = {[1] = pk1, [2] = pk2, [3] = pk3, [4] = pk4}
      doTeleportThing(pk[a], getClosestFreeTile(pk[a], pos), false)
      adjustStatus(pk[a], item.uid, true, true, true)
      doSendMagicEffect(getThingPos(pk[a]), 211)
   end
      setPlayerStorageValue(pk2, 637500, 1)
      setPlayerStorageValue(pk3, 637500, 1)
      if getCreatureName(cid) == "Scizor" then
         setPlayerStorageValue(pk4, 637500, 1)
      end
      setPlayerStorageValue(master, 637501, 1)

      addEvent(setStorage, time * 1000, master, 637501)
      addEvent(RemoveTeam, time * 1000, pk2)
      addEvent(RemoveTeam, time * 1000, pk3)
      if getCreatureName(cid) == "Scizor" then
         addEvent(RemoveTeam, time * 1000, pk4)
      end
end


elseif spell == "Team Slice" or spell == "Team Claw" then
                                                    --alterado v2.4
local master = getCreatureMaster(cid)
if #getCreatureSummons(master) < 2 or not isCreature(target) then return true end

local summons = getCreatureSummons(master)
local posis = {[1] = pos1, [2] = pos2, [3] = pos3, [4] = pos4}
local a = getCreatureSpeed(cid)

if getCreatureName(cid) == "Scyther" then
 eff = 27
elseif getCreatureName(cid) == "Shiny Scyther" then
 eff = 29
else
 eff = 20
end

local function nois(cid, s)
if not isCreature(cid) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
    doChangeSpeed(cid, s)
end

   if #getCreatureSummons(master) >= 2 and isCreature(target) then
      if isCreature(cid) then
         addEvent(doTargetCombatHealth, 500, cid, target, BUGDAMAGE, -min, -max, 255)
         for i = 1, #summons do
             posis[i] = getThingPos(summons[i])
             doDisapear(summons[i])
             doChangeSpeed(summons[i], -a)
             addEvent(doSendMagicEffect, 300, posis[i], 211)
             addEvent(doSendDistanceShoot, 350, posis[i], getThingPos(target), eff)
             addEvent(doSendDistanceShoot, 450, getThingPos(target), posis[i], eff)
             addEvent(doSendDistanceShoot, 600, posis[i], getThingPos(target), eff)
             addEvent(doSendDistanceShoot, 650, getThingPos(target), posis[i], eff)
             addEvent(nois, 670, summons[i], a)
             addEvent(doAppear, 670, summons[i])
         end
      end
    end
    
elseif spell == "Blizzard" then

local master = isSummon(cid) and getCreatureMaster(cid) or cid

local function doFall(cid)
for rocks = 1, 42 do
    addEvent(fall, rocks*35, cid, master, ICEDAMAGE, 28, 52)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, 28)
end                                         --alterado v2.4
addEvent(doFall, 450, cid)
addEvent(doMoveInAreaWithMiss, 1400, cid, BigArea2, 52, 9, spell, 1, ICEDAMAGE, min, max)

elseif spell == "Great Love" then

local master = getCreatureMaster(cid) or 0
for rocks = 1, 62 do
    addEvent(fall, rocks*35, cid, master, NORMALDAMAGE, -1, 147)  --alterado v2.4
end
addEvent(doMoveInAreaWithMiss, 500, cid, BigArea2, 147, 9, spell, 1, NORMALDAMAGE, min, max) 

elseif spell == "Fire Punch" then

	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
    doSendMagicEffect(getThingPositionWithDebug(target), 112)

		local function doPunch(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, FIREDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 35)
		end

	addEvent(doPunch, 200, cid, target) 
    
elseif spell == "Guillotine" then

doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 146)

elseif spell ==  "Hyper Beam" then

local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if a == 0 then
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg1n, -min, -max, 152)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg2n, -min, -max, 158)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg3n, -min, -max, 156)
	elseif a == 2 then
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg1s, -min, -max, 151)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg2s, -min, -max, 158)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg3s, -min, -max, 155)
	elseif a == 1 then
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg1e, -min, -max, 149)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg2e, -min, -max, 157)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg3e, -min, -max, 153)
	elseif a == 3 then
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg1w, -min, -max, 150)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg2w, -min, -max, 157)
		doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(cid), wg3w, -min, -max, 154)
	end 
    
elseif spell == "Thrash" then

                --cid, effDist, effDano, areaEff, areaDano, element, min, max
doMoveInAreaMulti(cid, 10, 111, bullet, bulletDano, NORMALDAMAGE, min, max) 

elseif spell == "Splash" or tonumber(spell) == 7 then

	doAreaCombatHealth(cid, WATERDAMAGE, getThingPositionWithDebug(cid), splash, -min, -max, 255)
	doSendMagicEffect(getThingPositionWithDebug(cid), 53)
    
elseif spell == "Dragon Breath" then     

       doMoveInArea(cid, 0, 143, db1, min, max, DRAGONDAMAGE, spell) 
       
elseif spell == "Muddy Water" then

       doMoveInAreaWithMiss(cid, muddy, 116, 9, spell, 0, WATERDAMAGE, min, max)
       
       
elseif spell == "Venom Motion" then

       doMoveInAreaWithMiss(cid, muddy, 114, 9, spell, 0, POISONDAMAGE, min, max)
       
elseif spell == "Thunder Fang" then

	doSendMagicEffect(getThingPositionWithDebug(target), 146)

		local function doBite(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 48)
		end

	addEvent(doBite, 200, cid, target) 
    
elseif spell == "Zap Cannon" then

  local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)
	
    if a == 0 then
        doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1n, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2n, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3n, 0, 0, 177)
        --------                                                                                            --alterado v2.4
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1n, -min, -max, 94)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2n, -min, -max, 93)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3n, -min, -max, 95)
	elseif a == 2 then
	    doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1s, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2s, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3s, 0, 0, 177)
		--------
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1s, -min, -max, 91)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2s, -min, -max, 93)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3s, -min, -max, 92)
	elseif a == 1 then
        doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1e, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2e, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3e, 0, 0, 177)
		---------
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1e, -min, -max, 86)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2e, -min, -max, 88)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3e, -min, -max, 87)
	elseif a == 3 then
	    doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1w, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2w, 0, 0, 177)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3w, 0, 0, 177)
		--------
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1w, -min, -max, 89)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2w, -min, -max, 88)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3w, -min, -max, 90)
	end
	
elseif spell == "Charge Beam" then

    local a = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)
	
    if a == 0 then
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1n, -min, -max, 94)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2n, -min, -max, 93)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3n, -min, -max, 95)
	elseif a == 2 then                                                                                   --alterado v2.4
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1s, -min, -max, 91)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2s, -min, -max, 93)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3s, -min, -max, 92)
	elseif a == 1 then
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1e, -min, -max, 86)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2e, -min, -max, 88)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3e, -min, -max, 87)
	elseif a == 3 then
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg1w, -min, -max, 89)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg2w, -min, -max, 88)
		doAreaCombatHealth(cid, ELECTRICDAMAGE, getThingPositionWithDebug(cid), wg3w, -min, -max, 90)
	end  
    
elseif spell == "Sacred Fire" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 3)
doAreaCombatHealthAtDistance(cid, FIREDAMAGE, getThingPositionWithDebug(target), sacred, -min, -max, 143)          
            
elseif spell == "Blaze Kick" then

doMoveInArea(cid, 0, 6, blaze, min, max, FIREDAMAGE, spell) 
addEvent(doMoveInArea, 200, cid, 0, 6, kick, min, max, FIREDAMAGE, spell) 

elseif spell == "Cross Chop" then

doMoveInArea(cid, 0, 118, blaze, min, max, FIGHTINGDAMAGE, spell) 
addEvent(doMoveInArea, 200, cid, 0, 118, kick, min, max, FIGHTINGDAMAGE, spell) 

elseif spell == "Overheat" then

   doMoveInArea(cid, 0, 5, reto5, min, max, FIREDAMAGE, spell) 
   
elseif spell == "Ancient Power" then

local posicao = getThingPositionWithDebug(cid)

	local function fireBlast(cid, area1, area2, effect, area3)
		if not isCreature(cid) then return true end
		if not isSightClear(posicao, area1, false) then return true end
		if isSleeping(cid) then return false end
        if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		doAreaCombatHealth(cid, null, area1, 0, -min, -max, effect)
			if area2.x ~= getThingPositionWithDebug(cid).x or area2.y ~= getThingPositionWithDebug(cid).y then
				doAreaCombatHealth(cid, null, area2, area3, -min, -max, 137)
			end
		doAreaCombatHealth(cid, ROCKDAMAGE, area1, area3, -min, -max, 137)
	end

	local m = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

	if m == 0 then
		for a = 0, 5 do
			addEvent(fireBlast, 300 * a, cid, {x = posicao.x, y = posicao.y - (a + 1), z = posicao.z}, {x = posicao.x, y = posicao.y - a, z = posicao.z}, 18, whirl3)
		end
	elseif m == 2 then
		for a = 0, 5 do
			addEvent(fireBlast, 300 * a, cid, {x = posicao.x, y = posicao.y + (a + 1), z = posicao.z}, {x = posicao.x, y = posicao.y + a, z = posicao.z}, 18, whirl3)
		end
	elseif m == 1 then
		for a = 0, 5 do
			addEvent(fireBlast, 300 * a, cid, {x = posicao.x + a + 1, y = posicao.y, z = posicao.z}, {x = posicao.x + a, y = posicao.y, z = posicao.z}, 18, whirl3)
		end
	elseif m == 3 then
		for a = 0, 5 do
			addEvent(fireBlast, 300 * a, cid, {x = posicao.x - (a + 1), y = posicao.y, z = posicao.z}, {x = posicao.x - a, y = posicao.y, z = posicao.z}, 18, whirl3)
		end
	end
    
elseif spell == "Twister" then

doMoveInAreaMulti(cid, 28, 41, bullet, bulletDano, DRAGONDAMAGE, min, max)

elseif spell == "Multi-Kick" then

doMoveInAreaMulti(cid, 39, 113, multi, multiDano, FIGHTINGDAMAGE, min, max)

elseif spell == "Multi-Punch" then

doMoveInAreaMulti(cid, 39, 112, multi, multiDano, FIGHTINGDAMAGE, min, max) 

elseif spell == "Squisky Licking" then 

addEvent(doMoveInAreaWithMiss, 0, cid, SL1, 145, 9, spell, 1, NORMALDAMAGE, min, max)
addEvent(doMoveInAreaWithMiss, 200, cid, SL2, 145, 9, spell, 1, NORMALDAMAGE, min, max)
addEvent(doMoveInAreaWithMiss, 400, cid, SL3, 145, 9, spell, 1, NORMALDAMAGE, min, max)
addEvent(doMoveInAreaWithMiss, 600, cid, SL4, 145, 9, spell, 1, NORMALDAMAGE, min, max)

elseif spell == "Lick" then

if canAttackOther(cid, target) == "Can" then
   doSendMagicEffect(getThingPos(getCreatureTarget(cid)), 145)      --alterado!
   addEvent(doMissSyst, 100, target, 9, 0, getPlayerStorageValue(target, 32659), 1)
end

elseif spell == "Bonemerang" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 7)
doAreaCombatHealthAtDistance(cid, GROUNDDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 227)
addEvent(doSendDistanceShoot, 200, getThingPositionWithDebug(target), getThingPositionWithDebug(cid), 7)

elseif spell == "Bone Club" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 7)
doAreaCombatHealthAtDistance(cid, GROUNDDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 118)
	
elseif spell == "Bone Slash" then

local function sendStickEff(cid, dir)
    if not isCreature(cid) then return true end
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
       doAreaCombatHealth(cid, GROUNDDAMAGE, getPosByDir(getThingPositionWithDebug(cid), dir), 0, -min, -max, 227)
	end

	local function doStick(cid)
	if not isCreature(cid) then return true end
	local t = {
	      [1] = SOUTHWEST,
	      [2] = SOUTH,
	      [3] = SOUTHEAST,
	      [4] = EAST,
	      [5] = NORTHEAST,
	      [6] = NORTH,
	      [7] = NORTHWEST,
	      [8] = WEST,
	      [9] = SOUTHWEST,
		}
		for a = 1, 9 do
            addEvent(sendStickEff, a * 140, cid, t[a])
		end
	end

	doStick(cid, false, cid)
    
elseif spell == "Furious Legs" or spell == "Ultimate Champion" or spell == "Fighter Spirit" then
                                                                                --alterado v2.4
doBuffSyst(cid, 15, 13, getPlayerStorageValue(cid, 36847), spell, true)       
            
elseif spell == "Sludge Rain" then  --alterado v2.4

local master = isSummon(cid) and getCreatureMaster(cid) or cid

local function doFall(cid)
for rocks = 1, 42 do
    addEvent(fall, rocks*35, cid, master, POISONDAMAGE, 6, 116)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, 6)
end                                         --alterado v2.4
addEvent(doFall, 450, cid)
addEvent(doMoveInAreaWithMiss, 1400, cid, BigArea2, 34, 9, spell, 0, POISONDAMAGE, min, max) 

elseif spell == "Shadow Ball" then

    doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 18)

    local function doDamageWithDelay(cid, target)
    if not isCreature(cid) or not isCreature(target) then return true end
    if isSleeping(cid) then return false end
    if getPlayerStorageValue(cid, 3894) >= 1 then return true end
	   doAreaCombatHealth(cid, ghostDmg, getThingPositionWithDebug(target), 0, -min, -max, 255)
	   local pos = getThingPositionWithDebug(target)
	   pos.x = pos.x + 1
	   doSendMagicEffect(pos, 140)
	end

	addEvent(doDamageWithDelay, getDistDelay, cid, target)
	
elseif spell == "Shadow Punch" then

	local pos = getThingPositionWithDebug(target)
	doSendMagicEffect(pos, 112)

		local function doPunch(cid, target)
			if not isCreature(cid) or not isCreature(target) then return true end
			if isSleeping(cid) then return false end
            if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		doAreaCombatHealth(cid, ghostDmg, getThingPositionWithDebug(target), 0, -min, -max, 255)
		local pos = getThingPositionWithDebug(target)
		pos.x = pos.x + 1
		doSendMagicEffect(pos, 140)
		end

	addEvent(doPunch, 300, cid, target)


elseif spell == "Shadow Storm" then

local master = isSummon(cid) and getCreatureMaster(cid) or cid

local function doFall(cid)
for rocks = 1, 42 do   --62
    addEvent(fall, rocks*35, cid, master, ghostDmg, 18, 140)
end
end
                                                           --alterado v2.4
for up = 1, 10 do
    addEvent(upEffect, up*75, cid, 18)
end
addEvent(doFall, 450, cid)
addEvent(doMoveInArea, 1400, cid, 0, 2, BigArea2, min, max, ghostDmg, spell)

elseif spell == "Invisible" then

		doDisapear(cid)
		addEvent(doAppear, 3000, cid)
		
		doSendMagicEffect(getThingPositionWithDebug(cid), 134)
        
elseif spell == "Nightmare" then

    if not isSleeping(target) then
		doSendMagicEffect(getThingPositionWithDebug(target), 3)
		doSendAnimatedText(getThingPositionWithDebug(target), "FAIL", 155)
	return true
	end
	
doAreaCombatHealth(cid, ghostDmg, getThingPositionWithDebug(target), 0, -min, -max, 138)  

elseif spell == "Dream Eater" then

	if not isSleeping(target) then
		doSendMagicEffect(getThingPositionWithDebug(target), 3)
		doSendAnimatedText(getThingPositionWithDebug(target), "FAIL", 155)
	return true
	end

	local a = getCreatureHealth(target)

	doAreaCombatHealth(cid, psyDmg, getThingPositionWithDebug(target), 0, -min, -max, 138)   --alterado v2.4
	local b = getCreatureHealth(target)
	local c = a - b
	
	local amount =  math.ceil(c / 2)
	
	local function doHealArea(cid, min, max)
    local amount = math.random(min, max)
    if (getCreatureHealth(cid) + amount) >= getCreatureMaxHealth(cid) then
        amount = -(getCreatureHealth(cid)-getCreatureMaxHealth(cid))
    end
    if getCreatureHealth(cid) ~= getCreatureMaxHealth(cid) then
       doCreatureAddHealth(cid, amount)
       doSendAnimatedText(getThingPos(cid), "+"..amount.."", 155)
    end
    end
    
	doSendMagicEffect(getThingPositionWithDebug(cid), 132)
	doHealArea(cid, amount, amount)
    
elseif spell == "Dark Eye" or spell == "Miracle Eye" then

doSendMagicEffect(getThingPos(cid), 47)       --alterado v2.4
setPlayerStorageValue(cid, 999457, 1)   

elseif spell == "Elemental Hands" then

if getCreatureOutfit(cid).lookType == 1301 then
print("Error occurred with move 'Elemental Hands', outfit of hitmonchan is wrong")
doPlayerSendTextMessage(getCreatureMaster(cid), MESSAGE_STATUS_CONSOLE_BLUE, "A error are ocurred... A msg is sent to gamemasters!") 
return true
end        --proteçao pra n usar o move com o shiny hitmonchan com outfit diferente da do elite monchan do PO...

local e = getCreatureMaster(cid)
local name = getItemAttribute(getPlayerSlotItem(e, 8).uid, "poke")
local hands = getItemAttribute(getPlayerSlotItem(e, 8).uid, "hands")

       if hands == 4 then
       doItemSetAttribute(getPlayerSlotItem(e, 8).uid, "hands", 0)
       doSendMagicEffect(getThingPositionWithDebug(cid), hitmonchans[name][0].eff)
       doSetCreatureOutfit(cid, {lookType = hitmonchans[name][0].out}, -1)
       else
       doItemSetAttribute(getPlayerSlotItem(e, 8).uid, "hands", hands+1)
       doSendMagicEffect(getThingPositionWithDebug(cid), hitmonchans[name][hands+1].eff)
       doSetCreatureOutfit(cid, {lookType = hitmonchans[name][hands+1].out}, -1)
       end
       
elseif spell == "Crabhammer" then

doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 225)

elseif spell == "Ancient Fury" then

doBuffSyst(cid, 15, 0, getPlayerStorageValue(cid, 36847), spell, true)

--alterado v2.4 retirado skill burn skin

elseif spell == "Divine Punishment" then

local roardirections = {              --skill n terminada ;p mas da uma base ae pra galera o/
[NORTH] = {SOUTH},
[SOUTH] = {NORTH},
[WEST] = {EAST},
[EAST] = {WEST}}

local function divineBack(cid)
if not isCreature(cid) then return true end
local uid = checkAreaUid(getCreaturePosition(cid), check, 1, 1)
      for _,pid in pairs(uid) do
          dirrr = getCreatureDirectionToTarget(pid, cid)
          delay = getNextStepDelay(pid, 0)
          if isSummon(cid) and (isMonster(pid) or (isSummon(pid) and canAttackOther(cid, pid) == "Can") or (isPlayer(pid) and canAttackOther(cid, pid) == "Can")) and pid ~= cid then
             setPlayerStorageValue(pid, 654878, 1)
             doChangeSpeed(pid, -getCreatureSpeed(pid))
             doChangeSpeed(pid, 100)
		     doPushCreature(pid, roardirections[dirrr][1], 1, 0)
		     doChangeSpeed(pid, -getCreatureSpeed(pid))
             addEvent(setPlayerStorageValue, 6450, pid, 654878, -1)
             addEvent(doRegainSpeed, 6450, pid)
           elseif isMonster(cid) and (isSummon(pid) or (isPlayer(pid) and #getCreatureSummons(pid) <= 0)) and pid ~= cid then
             setPlayerStorageValue(pid, 654878, 1)
             doChangeSpeed(pid, -getCreatureSpeed(pid))
		     doChangeSpeed(pid, 100)
		     doPushCreature(pid, roardirections[dirrr][1], 1, 0)
		     doChangeSpeed(pid, -getCreatureSpeed(pid))
             addEvent(doRegainSpeed, 6450, pid)
             addEvent(setPlayerStorageValue, 6450, pid, 654878, -1)
           end
       end    
end

local function doDivine(cid, min, max, spell, rounds, area)
if not isCreature(cid) then return true end
for i = 1, 9 do
    addEvent(doMoveInArea, i*500, cid, rounds, 137, area[i], min, max, psyDmg, spell)    --alterado v2.4
end
end
       
       local rounds = math.random(9, 12)
       local area = {punish1, punish2, punish3, punish1, punish2, punish3, punish1, punish2, punish3}
       
       local posi = getThingPos(cid) 
       posi.x = posi.x+1
       posi.y = posi.y+1

       setPlayerStorageValue(cid, 2365487, 1)     --alterado v2.4
       addEvent(setPlayerStorageValue, 6450, cid, 2365487, -1) --alterado v2.4
       doDisapear(cid)
       doChangeSpeed(cid, -getCreatureSpeed(cid))
       doSendMagicEffect(posi, 247)   
       addEvent(doAppear, 6450, cid)
       addEvent(doRegainSpeed, 6450, cid)
       
       local uid = checkAreaUid(getCreaturePosition(cid), check, 1, 1)
             for _,pid in pairs(uid) do
                 if isSummon(cid) and (isMonster(pid) or (isSummon(pid) and canAttackOther(cid, pid) == "Can") or (isPlayer(pid) and canAttackOther(cid, pid) == "Can")) and pid ~= cid then
                    doChangeSpeed(pid, -getCreatureSpeed(pid))
                 elseif isMonster(cid) and (isSummon(pid) or (isPlayer(pid) and #getCreatureSummons(pid) <= 0)) and pid ~= cid then
                    doChangeSpeed(pid, -getCreatureSpeed(pid))
                 end
             end
                        
       addEvent(divineBack, 2100, cid)
       addEvent(doDivine, 2200, cid, min, max, spell, rounds, area)
        

elseif isInArray({"Camouflage", "Acid Armor", "Iron Defense", "Minimize"}, spell) then    --alterado v2.4  daki pra baixo!

local function setOut(cid)
if not isCreature(cid) then return true end
doRemoveCondition(cid, CONDITION_OUTFIT)
setPlayerStorageValue(cid, 9658783, -1)  
end

out = {
["Camouflage"] = 1445,
["Acid Armor"] = 1453,
["Iron Defense"] = 1401,
["Minimize"] = 1455,
}

doSetCreatureOutfit(cid, {lookType = out[spell]}, -1)
setPlayerStorageValue(cid, 9658783, 1)  
addEvent(setOut, 5000, cid)   

elseif spell == "Future Sight" then

doBuffSyst(cid, 10, 0, getPlayerStorageValue(cid, 36847), spell, true)    	

elseif spell == "Shadowave" then

doMoveInArea(cid, 0, 222, db1, min, max, DARKDAMAGE, spell)

elseif spell == "Confuse Ray" then

if canAttackOther(cid, target) == "Can" then
	local rounds = math.random(4, 7)
	rounds = rounds + math.floor(getPokemonLevel(cid) / 35)

    posi = getThingPositionWithDebug(target)
         posi.y = posi.y+1
    ---
	doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
	doSendMagicEffect(posi, 222)
	doTargetCombatHealth(cid, target, GHOSTDAMAGE, -min, -max, 255)
    doAdvancedConfuse(target, rounds, getPlayerStorageValue(target, 3891), cid)
end  

elseif spell == "Leaf Blade" then

local a = getThingPos(target)
posi = {x = a.x+1, y = a.y+1, z = a.z}

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)
addEvent(doSendMagicEffect, 200, posi, 240)
addEvent(doAreaCombatHealth, 200, cid, GRASSDAMAGE, getThingPos(target), LeafBlade, -min, -max, 255)

elseif spell == "Eruption" or spell == "Elecball" then

pos = getThingPos(cid)
    pos.x = pos.x+1
    pos.y = pos.y+1
    
atk = {
["Eruption"] = {241, FIREDAMAGE},
["Elecball"] = {171, ELECTRICDAMAGE}
}

stopNow(cid, 1000)
doSendMagicEffect(pos, atk[spell][1])
doMoveInArea(cid, 0, 0, bombWee1, min, max, atk[spell][2], spell) 

elseif spell == "Meteor Smash" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 20)
addEvent(doAreaCombatHealth, 200, cid, NORMALDAMAGE, getThingPos(target), 0, -min, -max, 242)

elseif spell == "Draco Meteor" then

local effD = 5
local eff = 248
local master = isSummon(cid) and getCreatureMaster(cid) or cid

local function doFall(cid)
for rocks = 5, 42 do
    addEvent(fall, rocks*35, cid, master, DRAGONDAMAGE, effD, eff)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, effD)
end
addEvent(doFall, 450, cid)
addEvent(doAreaCombatHealth, 1400, cid, DRAGONDAMAGE, getThingPos(cid), waterarea, -min, -max, 255)


elseif spell == "Dragon Pulse" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, DRAGONDAMAGE, area, pulse2, -min, -max, 255)
end
end

for a = 0, 3 do

local t = {
[0] = {249, {x=p.x, y=p.y-(a+1), z=p.z}},
[1] = {249, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {249, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {249, {x=p.x-(a+1), y=p.y, z=p.z}}
}   
addEvent(sendAtk, 300*a, cid, t[d][2])
addEvent(doAreaCombatHealth, 400*a, cid, DRAGONDAMAGE, t[d][2], pulse1, 0, 0, t[d][1])
end

elseif spell == "Psy Ball" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 3)
addEvent(doAreaCombatHealth, 200, cid, psyDmg, getThingPos(target), 0, -min, -max, 250)   --alterado v2.4

elseif spell == "SmokeScreen" then

local function smoke(cid)
if not isCreature(cid) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
   doMoveInAreaWithMiss(cid, confusion, 34, 9, spell, 0, NORMALDAMAGE, 0, 0)
end

for i = 0, 2 do
    addEvent(smoke, i*500, cid)                                --alterado v2.4
end

elseif spell == "Faint Attack" then

doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 39)

local function doPunch(cid, target)
if not isCreature(cid) or not isCreature(target) then return true end
doAreaCombatHealth(cid, DARKDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 237)
end

addEvent(doPunch, 200, cid, target)


elseif spell == "Assurance" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area1, area2, eff)
if not isSightClear(p, area1, false) then return true end
if not isSightClear(p, area2, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, DARKDAMAGE, area1, 0, 0, 0, eff)
   doAreaCombatHealth(cid, DARKDAMAGE, area2, whirl3, -min, -max, 0)
end
end

for a = 0, 3 do

local t = {
[0] = {230, {x=p.x+1, y=p.y-(a+1), z=p.z}, {x=p.x, y=p.y-(a+1), z=p.z}},
[1] = {226, {x=p.x+(a+2), y=p.y+1, z=p.z}, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {235, {x=p.x+1, y=p.y+(a+1), z=p.z}, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {231, {x=p.x-(a+1), y=p.y+1, z=p.z}, {x=p.x-(a+1), y=p.y, z=p.z}}
}   
addEvent(sendAtk, 300*a, cid, t[d][2], t[d][3], t[d][1])
end

elseif spell == "Scary Face" then

local p = getThingPos(cid)
doSendMagicEffect({x=p.x+1, y=p.y+1, z=p.z}, 228)
doMoveInAreaWithMiss(cid, confusion, 0, 9, spell, 1, NORMALDAMAGE, 0, 0)

elseif spell == "Surf" then

local pos = getThingPos(cid)

doMoveInArea(cid, 0, 246, doSurf1, 0, 0, WATERDAMAGE, spell)
addEvent(doAreaCombatHealth, math.random(100, 400), cid, WATERDAMAGE, pos, doSurf2, -min, -max, 255)

elseif spell == "Sunny Day" then

local p = getThingPos(cid)
doSendMagicEffect({x=p.x+1, y=p.y, z=p.z}, 181)
---
if isSummon(cid) then 
   doCureBallStatus(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, "all")
end
doCureStatus(cid, "all")
setPlayerStorageValue(cid, 253, 1)  --focus
doSilenceInArea(cid, confusion, 9, 39) --silence

elseif spell == "Pursuit" or spell == "ExtremeSpeed" or spell == "U-Turn" then

local atk = {
["Pursuit"] = {17, DARKDAMAGE},
["ExtremeSpeed"] = {50, NORMALDAMAGE, 51},
["U-Turn"] = {19, BUGDAMAGE}
}

local pos = getThingPos(cid)
local p = getThingPos(target)
local newPos = getClosestFreeTile(target, p)
local eff = getCreatureName(cid) == "Shiny Arcanine" and atk[spell][3] or atk[spell][1]
local damage = atk[spell][2]
-----------
doDisapear(cid)
doChangeSpeed(cid, -getCreatureSpeed(cid))
-----------
addEvent(doSendMagicEffect, 300, pos, 211)
addEvent(doSendDistanceShoot, 400, pos, p, eff)
addEvent(doSendDistanceShoot, 400, newPos, p, eff)
addEvent(doTargetCombatHealth, 400, cid, target, damage, -min, -max, 255)
addEvent(doSendDistanceShoot, 800, p, pos, eff)
addEvent(doSendMagicEffect, 850, pos, 211)
addEvent(doRegainSpeed, 1000, cid)
addEvent(doAppear, 1000, cid)

elseif spell == "Egg Rain" then

local effD = 12
local eff = 5
local master = isSummon(cid) and getCreatureMaster(cid) or cid
------------

local function doFall(cid)
for rocks = 1, 62 do
    addEvent(fall, rocks*35, cid, master, ROCKDAMAGE, effD, eff)
end
end

for up = 1, 10 do
    addEvent(upEffect, up*75, cid, effD)
end
addEvent(doFall, 450, cid)
addEvent(doAreaCombatHealth, 1400, cid, NORMALDAMAGE, getThingPos(cid), waterarea, -min, -max, 255)


elseif spell == "Air Cutter" then
local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, FLYINGDAMAGE, area, whirl3, -min, -max, 255)
end
end

for a = 0, 5 do

local t = {
[0] = {128, {x=p.x, y=p.y-(a+1), z=p.z}, {x=p.x+1, y=p.y-(a+1), z=p.z}},
[1] = {129, {x=p.x+(a+1), y=p.y, z=p.z}, {x=p.x+(a+2), y=p.y+1, z=p.z}},
[2] = {131, {x=p.x, y=p.y+(a+1), z=p.z}, {x=p.x+1, y=p.y+(a+2), z=p.z}},
[3] = {130, {x=p.x-(a+1), y=p.y, z=p.z}, {x=p.x-(a+1), y=p.y+1, z=p.z}}
}   
addEvent(doSendMagicEffect, 300*a, t[d][3], t[d][1])
addEvent(sendAtk, 300*a, cid, t[d][2])
end

elseif spell == "Venom Gale" then

local area = {gale1, gale2, gale3, gale4, gale3, gale2, gale1}

for i = 0, 6 do
    addEvent(doMoveInArea, i*400, cid, 0, 138, area[i+1], min, max, POISONDAMAGE, spell)
end	

elseif spell == "Crunch" then

doMoveInArea(cid, 0, 146, Crunch1, min, max, DARKDAMAGE, spell)
addEvent(doMoveInArea, 300, cid, 0, 146, Crunch2, min, max, DARKDAMAGE, spell)

elseif spell == "Ice Fang" then

doTargetCombatHealth(cid, target, ICEDAMAGE, 0, 0, 146)
addEvent(doTargetCombatHealth, 250, cid, target, ICEDAMAGE, -min, -max, 17)

elseif spell == "Psyshock" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area, eff)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, psyDmg, area, 0, 0, 0, eff)    --alterado v2.4
   doAreaCombatHealth(cid, psyDmg, area, whirl3, -min, -max, 255)     --alterado v2.4
end
end

for a = 0, 4 do

local t = {
[0] = {250, {x=p.x, y=p.y-(a+1), z=p.z}},           --alterado v2.4
[1] = {250, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {250, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {250, {x=p.x-(a+1), y=p.y, z=p.z}}
}   
addEvent(sendAtk, 370*a, cid, t[d][2], t[d][1])
end


elseif spell == "Hurricane" then

local function hurricane(cid)
		if not isCreature(cid) then return true end
		if isSleeping(cid) then return true end
		if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		   doMoveInArea(cid, 0, 42, bombWee1, min, max, FLYINGDAMAGE, spell)
	end

doSetCreatureOutfit(cid, {lookType = 1398}, 10000)
   	
for i = 1, 17 do
    addEvent(hurricane, i*600, cid)                                --alterado v2.4
end

elseif spell == "Aromateraphy" or spell == "Emergency Call" then

eff = spell == "Aromateraphy" and 14 or 13

doAreaCombatHealth(cid, GRASSDAMAGE, getThingPos(cid), bombWee3, 0, 0, eff)
if isSummon(cid) then 
   doCureBallStatus(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, "all")
end
doCureStatus(cid, "all") 

local uid = checkAreaUid(getCreaturePosition(cid), confusion, 1, 1)
for _,pid in pairs(uid) do
    if isCreature(pid) then
       if isMonster(cid) and isMonster(pid) and pid ~= cid then
          doCureStatus(pid, "all")
       elseif isSummon(cid) and ((isSummon(pid) and canAttackOther(cid, pid) == "Cant") or (isPlayer(pid) and canAttackOther(cid, pid) == "Cant")) and pid ~= cid then
          if isSummon(pid) then 
             doCureBallStatus(getPlayerSlotItem(getCreatureMaster(pid), 8).uid, "all")
          end
          doCureStatus(pid, "all")
       end
    end
end

elseif spell == "Synthesis" or spell == "Roost" then

    local min = (getCreatureMaxHealth(cid) * 45) / 100
	local max = (getCreatureMaxHealth(cid) * 60) / 100
	
	local function doHealArea(cid, min, max)
    local amount = math.random(min, max)
    if (getCreatureHealth(cid) + amount) >= getCreatureMaxHealth(cid) then
        amount = -(getCreatureHealth(cid)-getCreatureMaxHealth(cid))
    end
    if getCreatureHealth(cid) ~= getCreatureMaxHealth(cid) then
       doCreatureAddHealth(cid, amount)
       doSendAnimatedText(getThingPos(cid), "+"..amount.."", 65)
    end
    end
    
	doSendMagicEffect(getThingPositionWithDebug(cid), 39)
    doHealArea(cid, min, max) 
    
elseif spell == "Cotton Spore" then

doMoveInAreaWithMiss(cid, confusion, 85, 9, spell, 1, GRASSDAMAGE, 0, 0)

elseif spell == "Peck" then

sendDistanceShootWithProtect(cid, getThingPos(cid), getThingPos(target), 39)
addEvent(doTargetCombatHealth, 200, cid, target, FLYINGDAMAGE, -min, -max, 3)

elseif spell == "Rolling Kick" or spell == "Night Daze" then

local pos = getThingPos(cid)
local eff = spell == "Night Daze" and 222 or 113
local dmg = spell == "Night Daze" and DARKDAMAGE or FIGHTINGDAMAGE
local out = getCreatureName(cid) == "Hitmontop" and 1193 or 1451

	local function doSendBubble(cid, pos)
		if not isCreature(cid) then return true end
		if getPlayerStorageValue(cid, 3894) >= 1 then return true end
		if isSleeping(cid) then return true end
		doSendDistanceShoot(getThingPos(cid), pos, 39)
		doSendMagicEffect(pos, eff)
	end
	                                                          --alterado!!
	for a = 1, 20 do
	    local r1 = math.random(-4, 4)
	    local r2 = r1 == 0 and choose(-3, -2, -1, 2, 3) or math.random(-3, 3)
	    --
	    local lugar = {x = pos.x + r1, y = pos.y + r2, z = pos.z}
	    addEvent(doSendBubble, a * 25, cid, lugar)
	end
	if isInArray({"Hitmontop", "Shiny Hitmontop"}, getCreatureName(cid)) then
	   doSetCreatureOutfit(cid, {lookType = out}, 400)
    end 
	addEvent(doAreaCombatHealth, 150, cid, dmg, pos, waterarea, -min, -max, 255)
	
elseif spell == "Safeguard" then

doSendMagicEffect(getThingPos(cid), 133)
if isSummon(cid) then 
   doCureBallStatus(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, "all")
end
doCureStatus(cid, "all") 

elseif spell == "Air Slash" then

local p = getThingPos(cid)

local t = {
{{128, {x = p.x+1, y = p.y-1, z = p.z}}, {16, {x = p.x+1, y = p.y-1, z = p.z}}},
{{129, {x = p.x+2, y = p.y+1, z = p.z}}, {221, {x = p.x+3, y = p.y+1, z = p.z}}},
{{131, {x = p.x+1, y = p.y+2, z = p.z}}, {223, {x = p.x+1, y = p.y+3, z = p.z}}},
{{130, {x = p.x-1, y = p.y+1, z = p.z}}, {243, {x = p.x-1, y = p.y+1, z = p.z}}},
}

for a = 1, 10 do
    for i = 1, 4 do
        doSendMagicEffect(t[i][1][2], t[i][1][1])
        addEvent(doSendMagicEffect, 200, t[i][2][2], t[i][2][1])
    end
end
addEvent(doAreaCombatHealth, 50, cid, FLYINGDAMAGE, getThingPos(cid), airSlash, -min, -max, 255)

elseif spell == "Feather Dance" then

local function doPulse(cid, eff)
if not isCreature(cid) then return true end
if isSleeping(cid) then return false end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
   doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 36)
   doTargetCombatHealth(cid, target, FLYINGDAMAGE, -min, -max, eff)
end

   addEvent(doPulse, 0, cid, 137)                
   addEvent(doPulse, 350, cid, 137)


elseif spell == "Tailwind" then

function sendEff(cid, eff)
if not isCreature(cid) then return true end
doSendMagicEffect(getThingPos(cid), eff)
end

doRaiseStatus(cid, false, false, true, 200, 10)

for i = 1, 10 do
    addEvent(sendEff, i*1000, cid, 137)
end

elseif spell == "Double Team" then

  local function RemoveTeam(cid, master)
   if isCreature(cid) then
      local p = getThingPos(cid)
      doSendMagicEffect(p, 211)                --rever double team!!
      doRemoveCreature(cid)
   end
   end
         
   if getPlayerStorageValue(cid, 637500) >= 1 then
   return true
   end
   
   local s = {
   ["Xatu"] = "XatuTeam",
   ["Yanma"] = "YanmaTeam",
   }
   
    local master = getCreatureMaster(cid)
    local item = getPlayerSlotItem(master, 8)
    local pos = getThingPos(cid)
    local time = 20
    local pokelife = (getCreatureHealth(cid) / getCreatureMaxHealth(cid))
    local random = math.random(5, 10)
    local dir = getCreatureLookDir(cid)
    ---------
    doItemSetAttribute(item.uid, "hp", pokelife)
    ---------
    doDisapear(cid)
    doTeleportThing(cid, {x=4, y=3, z=10}, false) 
    doAppear(cid)
    ---------
    doSummonMonster(master, s[getCreatureName(cid)])
    local pk = getCreatureSummons(master)[2]
    adjustStatus(pk, item.uid, true, true, true)
    ---------
    doTeleportThing(pk, getClosestFreeTile(pk, pos), false)
    doTeleportThing(cid, getClosestFreeTile(cid, pos), false)
    doCreatureSetLookDir(pk, dir)
    doCreatureSetLookDir(cid, dir)
    doSendMagicEffect(getThingPos(pk), 211)
    doSendMagicEffect(getThingPos(cid), 211)
    if getPlayerStorageValue(cid, 9658783) >= 1 then          --gambiarra
       doSetCreatureOutfit(cid, {lookType = 1446}, getItemAttribute(item.uid, "buffSyst")*1000)
    end
    --------
    setPlayerStorageValue(pk, 637500, 1)
    setPlayerStorageValue(master, 637501, 1)
    addEvent(RemoveTeam, time*1000, pk, master)
    addEvent(setPlayerStorageValue, time*1000, master, 637501, -1)

elseif spell == "Tackle" then

   doAreaCombatHealth(cid, NORMALDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 111)

elseif spell == "Giga Drain" then

local life = getCreatureHealth(target)

	doAreaCombatHealth(cid, GRASSDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 14)
    
	local newlife = life - getCreatureHealth(target)

	doSendMagicEffect(getThingPositionWithDebug(cid), 14)
	if newlife >= 1 then
	doCreatureAddHealth(cid, newlife)
	doSendAnimatedText(getThingPositionWithDebug(cid), "+"..newlife.."", 32)
	end  
	
elseif spell == "Bug Fighter" then
	
doBuffSyst(cid, 8, 0, getPlayerStorageValue(cid, 36847), spell, true)	
	
elseif spell == "Metal Claw" then

doAreaCombatHealth(cid, STEELDAMAGE, getThingPositionWithDebug(target), 0, -min, -max, 160)	
	
elseif spell == "Power Gem" then

local p = getThingPos(cid)
local d = isCreature(target) and getCreatureDirectionToTarget(cid, target) or getCreatureLookDir(cid)

function sendAtk(cid, area)
if not isSightClear(p, area, false) then return true end
if isSleeping(cid) then return true end
if getPlayerStorageValue(cid, 3894) >= 1 then return true end
if isCreature(cid) then 
   doAreaCombatHealth(cid, ROCKDAMAGE, area, pulse2, -min, -max, 255)
end
end

for a = 0, 3 do

local t = {
[0] = {29, {x=p.x, y=p.y-(a+1), z=p.z}},     
[1] = {29, {x=p.x+(a+1), y=p.y, z=p.z}},
[2] = {29, {x=p.x, y=p.y+(a+1), z=p.z}},
[3] = {29, {x=p.x-(a+1), y=p.y, z=p.z}}                            
}   
addEvent(sendAtk, 300*a, cid, t[d][2])
addEvent(doAreaCombatHealth, 400*a, cid, ROCKDAMAGE, t[d][2], pulse1, 0, 0, t[d][1])
--addEvent(doAreaCombatHealth, 400*a, cid, ROCKDAMAGE, t[d][2], pulse1, 0, 0, 44)     --44
end	
	
elseif spell == "Octazooka" then

doMoveInAreaMulti(cid, 6, 116, multi, multiDano, WATERDAMAGE, min, max)
doSilenceInArea(cid, multiDano, 9, 34) --silence
	
	
elseif spell == "Take Down" then

doMoveInArea(cid, 0, 111, reto5, min, max, NORMALDAMAGE, spell)

elseif spell == "Yawn" then
doSendDistanceShoot(getThingPositionWithDebug(cid), getThingPositionWithDebug(target), 11)
addEvent(doSleep, 1500, target, math.random(6, 9), true)

elseif spell == "Tongue Hook" then

sendDistanceShootWithProtect(cid, getThingPos(cid), getThingPos(target), 38)
addEvent(doTeleportThing, 200, target, getClosestFreeTile(cid, getThingPos(cid)), true)
addEvent(sendDistanceShootWithProtect, 200, cid, getThingPos(target), getThingPos(cid), 38)


elseif spell == "Tongue Grap" then

function sendEff(cid, target, eff)                                             --skills de lingua n tao 100% ainda... ;p
if not isCreature(cid) or not isCreature(target) then return true end
sendDistanceShootWithProtect(cid, getThingPos(target), getThingPos(cid), 38)
end

sendDistanceShootWithProtect(cid, getThingPos(cid), getThingPos(target), 38)
addEvent(doSilence, 200, target, 10, 185, getPlayerStorageValue(target, 32698)) 
for i = 1, 10 do
    addEvent(sendEff, i*1000, cid, target, 38)
end 

end
return true 
end