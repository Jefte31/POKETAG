local ballcatch = {                    --id normal, id da ball shiy
[2394] = {cr = 3, on = 24, off = 23, ball = {11826, 11737}, send = 47, typeee = "normal"},  --alterado v2.9  \/
[2391] = {cr = 6, on = 198, off = 197, ball = {11832, 11740}, send = 48, typeee = "great"},
[2393] = {cr = 10, on = 202, off = 201, ball = {11835, 11743}, send = 46, typeee = "super"},
[2392] = {cr = 15, on = 200, off = 199, ball = {11829, 11746}, send = 49, typeee = "ultra"},
[12617] = {cr = 3, on = 204, off = 203, ball = {10975, 12621}, send = 35, typeee = "saffari"}, 
}

function onUse(cid, item, frompos, item3, topos)

local item2 = getTopCorpse(topos)
if item2 == null then
	return true
end

if getItemAttribute(item2.uid, "catching") == 1 then
   return true
end

if getItemAttribute(item2.uid, "golden") and getItemAttribute(item2.uid, "golden") == 1 then
   return doPlayerSendCancel(cid, "You can't try to catch a pokemon in the Golden Arena!")   --alterado v2.6
end

local name = string.lower(getItemNameById(item2.itemid))  --alterado v2.9 \/
      name = string.gsub(name, "fainted ", "")
      name = string.gsub(name, "defeated ", "")
      name = doCorrectPokemonName(name)
local x = pokecatches[name]
	

local storage = newpokedex[doCorrectPokemonName(name)].stoCatch            --alterado v2.9 \/
if getPlayerStorageValue(cid, storage) == -1 or not string.find(getPlayerStorageValue(cid, storage), ";") then  
   setPlayerStorageValue(cid, storage, "normal = 0, great = 0, super = 0, ultra = 0, saffari = 0;")              
end    
    
if not x then return true end

local owner = getItemAttribute(item2.uid, "corpseowner")
	
if owner and isCreature(owner) and isPlayer(owner) and cid ~= owner then  --alterado v2.5
   doPlayerSendCancel(cid, "You are not allowed to catch this pokemon.")
   return true
end

local newidd = isShinyName(name) and ballcatch[item.itemid].ball[2] or ballcatch[item.itemid].ball[1] --alterado v2.9       
local typeee = ballcatch[item.itemid].typeee
       
local catchinfo = {}
		catchinfo.rate = ballcatch[item.itemid].cr
		catchinfo.catch = ballcatch[item.itemid].on
		catchinfo.fail = ballcatch[item.itemid].off
		catchinfo.newid = newidd                      
		catchinfo.name = doCorrectPokemonName(name)
		catchinfo.topos = topos
		catchinfo.chance = x.chance

doSendDistanceShoot(getThingPos(cid), topos, ballcatch[item.itemid].send)
doRemoveItem(item.uid, 1)

local d = getDistanceBetween(getThingPos(cid), topos)
                                              
if getPlayerStorageValue(cid, 98796) >= 1 and getPlayerItemCount(cid, 12617) <= 0 then --alterado v2.9 
   setPlayerStorageValue(cid, 98796, -1) 
   setPlayerStorageValue(cid, 98797, -1)                                              
   doTeleportThing(cid, SafariOut, false)
   doSendMagicEffect(getThingPos(cid), 21)
   doPlayerSendTextMessage(cid, 27, "You spend all your 'saffari balls', good luck in the next time...")
end
        
addEvent(doSendPokeBall, d * 70 + 100 - (d * 14) , cid, catchinfo, false, false, typeee)
addEvent(doSendMagicEffect, (d * 70 + 100 - (d * 14)) - 100, topos, 3)
return true
end