function onSay(cid, words, param, channel)

local n = string.explode(param, ",")

if param and param == "back" then
   doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
elseif param and param == "golden" then
   doTeleportThing(cid, posBackGolden, false)
elseif param and ((n[1] and n[1] == "reset") or param == "reset") then
   if removePlayerClan(cid) then
      sendMsgToPlayer(cid, 20, "Now you are a Pokemon Trainer!")
   else
      sendMsgToPlayer(cid, 20, "You can't leave the clan untill you don't finish the tasks!")
   end
elseif param and param == "rocket" or param == "officer" then
if param == "rocket" and getPlayerStorageValue(cid, 665450) <= 0 then    
   doPlayerSendTextMessage(cid, 20, "You are a Rocket now!")
   setPlayerStorageValue(cid, 665450, 1)
elseif param == "rocket" and getPlayerStorageValue(cid, 665450) >= 1 then
   doPlayerSendTextMessage(cid, 20, "You aren't a Rocket anymore")
   setPlayerStorageValue(cid, 665450, -1)

elseif param == "officer" and getPlayerStorageValue(cid, 665460) <= 0 then    
   doPlayerSendTextMessage(cid, 20, "You are a Officer now!")
   setPlayerStorageValue(cid, 665460, 1)
elseif param == "officer" and getPlayerStorageValue(cid, 665460) >= 1 then
   doPlayerSendTextMessage(cid, 20, "You aren't a Officer anymore!")
   setPlayerStorageValue(cid, 665460, -1)
end
elseif param and param == "reload" then
doCreatureExecuteTalkAction(cid, "/reload actions")
doCreatureExecuteTalkAction(cid, "/reload talkactions")
doCreatureExecuteTalkAction(cid, "/reload spells")
doCreatureExecuteTalkAction(cid, "/reload monster")
------
else
min = 400
max = 500
target = getCreatureTarget(cid)
summon = getCreatureSummons(cid)[1]
spell = "Solar Beam"                                    
--- 

---
end
 
return true
end