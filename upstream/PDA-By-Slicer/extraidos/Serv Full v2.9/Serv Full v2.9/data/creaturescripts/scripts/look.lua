local NPCBattle = {
["Brock"] = {artig = "He is", cidbat = "Pewter"},
["Misty"] = {artig = "She is", cidbat = "Cerulean"}, 
["Blaine"] = {artig = "He is", cidbat = "Cinnabar"},
["Sabrina"] = {artig = "She is", cidbat = "Saffron"},         --alterado v2.9 \/ peguem tudo!
["Kira"] = {artig = "She is", cidbat = "Viridian"},
["Koga"] = {artig = "He is", cidbat = "Fushcia"},
["Erika"] = {artig = "She is", cidbat = "Celadon"},
["Surge"] = {artig = "He is", cidbat = "Vermilion"},
}

function onLook(cid, thing, position, lookDistance)

local str = {}

if not isCreature(thing.uid) then
   local iname = getItemInfo(thing.itemid)
   if isPokeball(thing.itemid) and getItemAttribute(thing.uid, "poke") then
      
      unLock(thing.uid)
      local lock = getItemAttribute(thing.uid, "lock")        
      local pokename = getItemAttribute(thing.uid, "poke")

      table.insert(str, "You see "..iname.article.." "..iname.name..".")
      if getItemAttribute(thing.uid, "unique") then               
         table.insert(str, " It's an unique item.")   
      end
      table.insert(str, "\nIt contains "..getArticle(pokename).." "..pokename.." [level "..getItemAttribute(thing.uid, "level").."].\n")  
      if lock and lock > 0 then
         table.insert(str, "It will unlock in ".. os.date("%d/%m/%y %X", lock)..".\n")  
      end
      local boost = getItemAttribute(thing.uid, "boost") or 0
      if boost > 0 then
         table.insert(str, "Boost level: +"..boost..".\n")
      end
      if getItemAttribute(thing.uid, "nick") then
         table.insert(str, "It's nickname is: "..getItemAttribute(thing.uid, "nick")..".\n")
      end
      if getItemAttribute(thing.uid, "gender") == SEX_MALE then
         table.insert(str, "It is male.")
      elseif getItemAttribute(thing.uid, "gender") == SEX_FEMALE then
         table.insert(str, "It is female.")      
      else
         table.insert(str, "It is genderless.")
      end
	   table.insert(str, "\n--- Status ---")    
      table.insert(str, "\nOffense: "..math.floor(getItemAttribute(thing.uid, "offense")).." Defense: "..math.floor(getItemAttribute(thing.uid, "defense")).."\n")
      table.insert(str, "Agility: "..math.floor(getItemAttribute(thing.uid, "speed")).." Sp. Attack: "..math.floor(getItemAttribute(thing.uid, "specialattack")).."\n")
      table.insert(str, "Vitality: "..math.floor(getItemAttribute(thing.uid, "vitality")).."")	
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
      return false
      
   elseif string.find(iname.name, "fainted") or string.find(iname.name, "defeated") then
      
      table.insert(str, "You see a "..string.lower(iname.name).." ["..getItemAttribute(thing.uid, "level").."]. ")    
      if isContainer(thing.uid) then
         table.insert(str, "(Vol: "..getContainerCap(thing.uid)..")")
      end
      table.insert(str, "\n")

      if getItemAttribute(thing.uid, "gender") == SEX_MALE then
         table.insert(str, "It is male.")
      elseif getItemAttribute(thing.uid, "gender") == SEX_FEMALE then
         table.insert(str, "It is female.")
      else
         table.insert(str, "It is genderless.")
      end
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
      return false
      
   elseif isContainer(thing.uid) then     --containers
      
      if iname.name == "dead human" and getItemAttribute(thing.uid, "pName") then
         table.insert(str, "You see a dead human (Vol:"..getContainerCap(thing.uid).."). ")
         table.insert(str, "You recognize ".. getItemAttribute(thing.uid, "pName")..". ".. getItemAttribute(thing.uid, "article").." was killed by a ")
         table.insert(str, getItemAttribute(thing.uid, "attacker")..".")
      else   
         table.insert(str, "You see "..iname.article.." "..iname.name..". (Vol:"..getContainerCap(thing.uid)..").")
      end
      if getPlayerGroupId(cid) >= 4 and getPlayerGroupId(cid) <= 6 then
         table.insert(str, "\nItemID: ["..thing.itemid.."]")     
         local pos = getThingPos(thing.uid)
         table.insert(str, "\nPosition: [X: "..pos.x.."][Y: "..pos.y.."][Z: "..pos.z.."]")  
      end
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
      return false
      
   elseif getItemAttribute(thing.uid, "unique") then    --alterado v2.8 \/
      local p = getThingPos(thing.uid)
   
      table.insert(str, "You see ")
      if thing.type > 1 then
         table.insert(str, thing.type.." "..iname.plural..".")
      else
         table.insert(str, iname.article.." "..iname.name..".")
      end
      table.insert(str, " It's an unique item.\n"..iname.description)
      
      if getPlayerGroupId(cid) >= 4 and getPlayerGroupId(cid) <= 6 then
         table.insert(str, "\nItemID: ["..thing.itemid.."]")
         table.insert(str, "\nPosition: ["..p.x.."]["..p.y.."]["..p.z.."]")
      end
   
      sendMsgToPlayer(cid, MESSAGE_INFO_DESCR, table.concat(str))
      return false
      
   else
      return true
   end
end

local npcname = getCreatureName(thing.uid)
if isNpc(thing.uid) and NPCBattle[npcname] then    --npcs duel
   table.insert(str, "You see "..npcname..". "..NPCBattle[npcname].artig.." leader of the gym from "..NPCBattle[npcname].cidbat..".")
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
   return false
end
if getPlayerStorageValue(thing.uid, 697548) ~= -1 then    --npcs de TV
   table.insert(str, getPlayerStorageValue(thing.uid, 697548))                                   
   local pos = getThingPos(thing.uid)
   if youAre[getPlayerGroupId(cid)] then
      table.insert(str, "\nPosition: [X: "..pos.x.."][Y: "..pos.y.."][Z: "..pos.z.."]")
   end
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str)) 
   return false
end

if not isPlayer(thing.uid) and not isMonster(thing.uid) then    
   table.insert(str, "You see "..getCreatureName(thing.uid)..".")
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
   return false
end

if isPlayer(thing.uid) then     --player
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, getPlayerDesc(cid, thing.uid, false))  
return false
end

if getCreatureName(thing.uid) == "Evolution" then return false end

if not isSummon(thing.uid) then
   table.insert(str, "You see a wild "..string.lower(getCreatureName(thing.uid)).." [level "..getPokemonLevel(thing.uid).."].\n")
   if getPokemonGender(thing.uid)  == SEX_MALE then
      table.insert(str, "It is male.")
   elseif getPokemonGender(thing.uid)  == SEX_FEMALE then
      table.insert(str, "It is female.")
   else
      table.insert(str, "It is genderless.")
   end
   doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
   return false
   
elseif isSummon(thing.uid) and not isPlayer(thing.uid) then
   local boostlevel = getItemAttribute(getPlayerSlotItem(getCreatureMaster(thing.uid), 8).uid, "boost") or 0
   local boostshow = " + "..boostlevel.."]"
   if showBoostSeparated then
      boostshow = "] [+"..boostlevel.."]"
   end
   local levelinfo = "["..getPokemonLevel(thing.uid)..""..boostshow..""
   if getCreatureMaster(thing.uid) == cid then
      local myball = getPlayerSlotItem(cid, 8).uid
      local nexp = getItemAttribute(myball, "nextlevelexp")
      table.insert(str, "You see your "..string.lower(getCreatureName(thing.uid)).." "..levelinfo..".")
      table.insert(str, "\nHit points: "..getCreatureHealth(thing.uid).."/"..getCreatureMaxHealth(thing.uid)..".")
      table.insert(str, "\n"..getPokemonHappinessDescription(thing.uid))
      if getItemAttribute(myball, "level") <= 99 then
         table.insert(str, "\nExperience needed to level up: "..nexp..".")
      end
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
   else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You see a "..string.lower(getCreatureName(thing.uid)).." "..levelinfo..".\nIt belongs to "..getCreatureName(getCreatureMaster(thing.uid))..".")
   end
   return false
end
return true
end