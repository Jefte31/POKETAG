local balls = {11826, 11828, 11829, 11831, 11832, 11834, 11835, 11837,
	       11737, 11739, 11740, 11742, 11743, 11745, 11746, 11748}
                                                                                  
local function playerAddExp(cid, exp)
	doPlayerAddExp(cid, exp)
	doSendAnimatedText(getThingPos(cid), exp, 215)
end

local function giveExpToPlayer(pk, expTotal, givenexp, expstring)      --alterado v2.7
playerAddExp(pk, expTotal)    

local firstball = getPlayerSlotItem(pk, 8)

if not isInParty(pk) and firstball and getItemAttribute(firstball.uid,  expstring) and getItemAttribute(firstball.uid,  expstring) > 0 then
   local percent = getItemAttribute(firstball.uid, expstring) <= 1 and getItemAttribute(firstball.uid, expstring) or 1
   local gainexp = math.ceil(percent * givenexp)
   doItemSetAttribute(firstball.uid, expstring, 0)
   givePokemonExp(pk, firstball, expTotal)  --alterado v2.7
elseif isInParty(pk) and firstball.uid ~= 0 then
   givePokemonExp(pk, firstball, expTotal*3)    --alterado v2.7
end

for b = 1, #balls do
    local pokes = getItemsInContainerById(getPlayerSlotItem(pk, 3).uid, balls[b])
    if #pokes >= 1 then
       for _, uid in pairs (pokes) do
           if not isInParty(pk) and getItemAttribute(uid,  expstring) and getItemAttribute(uid,  expstring) > 0 then
              local percent = getItemAttribute(uid, expstring) <= 1 and getItemAttribute(uid, expstring) or 1
              local gainexp = math.ceil(percent * givenexp)
              doItemSetAttribute(uid, expstring, 0)
              givePokemonExpInBp(pk, uid, gainexp, balls[b])                  --alterado v2.7
           elseif isInParty(pk) and getItemAttribute(uid,  expstring) and getItemAttribute(uid,  expstring) > 0 then
              givePokemonExpInBp(pk, uid, expTotal*3, balls[b])
           end
       end
    end
end
end



function onDeath(cid, corpse, deathList)
        
	if isSummon(cid) or not deathList or getCreatureName(cid) == "Evolution" then return true end --alterado v2.8

    -------------Edited Golden Arena-------------------------   --alterado v2.7 \/\/
    if getPlayerStorageValue(cid, 22546) == 1 then
       setGlobalStorageValue(22548, getGlobalStorageValue(22548)-1)
       if corpse.itemid ~= 0 then doItemSetAttribute(corpse.uid, "golden", 1) end  --alterado v2.8     
    end   
    if getPlayerStorageValue(cid, 22546) == 1 and getGlobalStorageValue(22548) <= 0 then
       local wave = getGlobalStorageValue(22547)
       for _, sid in ipairs(getPlayersOnline()) do
           if isPlayer(sid) and getPlayerStorageValue(sid, 22545) == 1 then
              if getGlobalStorageValue(22547) < #wavesGolden+1 then
                 doPlayerSendTextMessage(sid, 21, "Wave "..wave.." will begin in "..timeToWaves.."seconds!")   
                 doPlayerSendTextMessage(sid, 28, "Wave "..wave.." will begin in "..timeToWaves.."seconds!") 
                 addEvent(creaturesInGolden, 100, GoldenUpper, GoldenLower, false, true, true)
                 addEvent(doWave, timeToWaves*1000)
              elseif getGlobalStorageValue(22547) == #wavesGolden+1 then
                 doPlayerSendTextMessage(sid, 20, "You have win the golden arena! Take your reward!")
                 doPlayerAddItem(sid, 2152, getPlayerStorageValue(sid, 22551)*2)    --premio
                 setPlayerStorageValue(sid, 22545, -1)
                 doTeleportThing(sid, getClosestFreeTile(sid, posBackGolden), false) 
                 setPlayerRecordWaves(sid)
              end
           end
       end
       if getGlobalStorageValue(22547) == #wavesGolden+1 then
          endGoldenArena()
       end
    end   
    ---------------------------------------------------   /\/\
    
	local givenexp = getWildPokemonExp(cid)
	local expstring = ""..cid.."expEx"  

if givenexp > 0 then
   for a = 1, #deathList do             
       local pk = deathList[a]
	   if isCreature(pk) then
	      local list = getSpectators(getThingPosWithDebug(pk), 30, 30, false) 
	      local expTotal = math.floor(playerExperienceRate * givenexp * getDamageMapPercent(pk, cid))
	      local party = getPartyMembers(pk)
          
          if isInParty(pk) and getPlayerStorageValue(pk, 4875498) <= -1 then
             expTotal = math.floor(expTotal/#party)         --alterado v2.6.1
             for i = 1, #party do
                 if isInArray(list, party[i]) and getDamageMapPercent(party[i], cid) > 0 then  --alterado v2.8
                    giveExpToPlayer(party[i], expTotal, givenexp, expstring)--alterado v2.7
                 end
             end
          else
             giveExpToPlayer(pk, expTotal, givenexp, expstring)   --alterado v2.7
          end
          
	   end
   end
end

	if isNpcSummon(cid) then
		local master = getCreatureMaster(cid)
		doSendMagicEffect(getThingPos(cid), getPlayerStorageValue(cid, 10000))
		doCreatureSay(master, getPlayerStorageValue(cid, 10001), 1)
		doRemoveCreature(cid)
	return false
	end
	
if corpse.itemid ~= 0 then   --alterado v2.8
doItemSetAttribute(corpse.uid, "offense", getPlayerStorageValue(cid, 1011))
doItemSetAttribute(corpse.uid, "defense", getPlayerStorageValue(cid, 1012))
doItemSetAttribute(corpse.uid, "speed", getPlayerStorageValue(cid, 1013))
doItemSetAttribute(corpse.uid, "vitality", getPlayerStorageValue(cid, 1014))
doItemSetAttribute(corpse.uid, "spattack", getPlayerStorageValue(cid, 1015))
doItemSetAttribute(corpse.uid, "level", getLevel(cid))
doItemSetAttribute(corpse.uid, "gender", getPokemonGender(cid))
end
return true
end