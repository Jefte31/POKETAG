function onCastSpell(cid, var)

if isSummon(cid) then return true end
local team = {
["Scyther"] = "ScytherTeam",
["Shiny Scyther"] = "Shiny ScytherTeam",
["Scizor"] = "ScizorTeam",
}

function setStorage(cid, storage)
if isCreature(cid) then
   if getPlayerStorageValue(cid, storage) >= 1 then
      setPlayerStorageValue(cid, storage, 0)
   end
end
end

function RemoveTeam(cid)
if isCreature(cid) then
  doSendMagicEffect(getThingPos(cid), 211)
  doRemoveCreature(cid)
end
end

if getPlayerStorageValue(cid, 637500) >= 1 or getPlayerStorageValue(cid, 637501) >= 1 then
return true
end

local name = getCreatureName(cid)
local pos = getThingPos(cid)
local time = 15
local life = getCreatureHealth(cid)
local maxLife = getCreatureMaxHealth(cid)
local lvl = getWildPokemonLevel(cid)
local gender = getPokemonGender(cid)
local num = (name == "Scizor") and 4 or 3

doCreatureSay(cid, "Shredder Team!", TALKTYPE_MONSTER)
doDisapear(cid)
addEvent(doAppear, math.random(0, 5), cid)
pk = {[1] = pk1, [2] = pk2, [3] = pk3, [4] = pk4}
if team[name] then
   for i = 2, num do
       pk[i] = doSummonCreature(team[name], pos)
   end
   
   pk[1] = cid
   
   for c = 2, num do
       doConvinceCreature(pk[1], pk[c])
   end
   
   doSendMagicEffect(getThingPos(pk[1]), 211)      
   for a = 2, num do
       doTeleportThing(pk[a], getClosestFreeTile(pk[a], pos), false)
       addEvent(doCreatureSetSkullType, 150, pk[a], gender)
       setWildPokemonLevel(pk[a], lvl)
       doCreatureAddHealth(pk[a], life-maxLife)
       doSendMagicEffect(getThingPos(pk[a]), 211)
   end
      setPlayerStorageValue(pk[2], 637500, 1)
      setPlayerStorageValue(pk[3], 637500, 1)
      setPlayerStorageValue(pk[1], 637501, 1)
      if name == "Scizor" then
         setPlayerStorageValue(pk[4], 637500, 1)
      end
      
      for b = 1, num do
          registerCreatureEvent(pk[b], "shredder team")
      end
   
      addEvent(setStorage, time * 1000, pk[1], 637501)
      addEvent(RemoveTeam, time * 1000, pk[2])
      addEvent(RemoveTeam, time * 1000, pk[3])
      if name == "Scizor" then
         addEvent(RemoveTeam, time * 1000, pk[4])
      end
end

return true
end