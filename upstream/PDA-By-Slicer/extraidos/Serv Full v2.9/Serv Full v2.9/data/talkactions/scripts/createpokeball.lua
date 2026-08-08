local typess = {       --alterado v2.9 \/  TUDO!!
[1] = "normal",
[2] = "great",
[3] = "super",
[4] = "ultra",
[5] = "saffari",
}

function onSay(cid, words, param)

if param == "" then
   doPlayerSendCancel(cid, 'Command needs parameters, function structure: "/cb [Pokemon Name], [Pokemon Level], [Strength], [Gender], [boost], [ball type]".')
   return true
end

local t = string.explode(param, ",")
---
local name = ""
local level = tonumber(t[2]) and tonumber(t[2]) or nil
local stre = tonumber(t[3]) and tonumber(t[3]) or 1 
local gender = (t[4] and tonumber(t[4])) and tonumber(t[4]) or t[4] and t[4] or nil 
local boost = tonumber(t[5]) and tonumber(t[5]) or 0
local btype = (tostring(t[6]) and pokeballs[t[6]]) and t[6] or typess[math.random(1, #typess)]  

if tostring(t[1]) then
	name = doCorrectString(t[1])   
	if not pokes[name] then
	   doPlayerSendCancel(cid, "Sorry, a pokemon with the name "..name.." doesn't exists.")
	   return true
	end
print(""..name.." ball has been created by "..getPlayerName(cid)..".")
end

addPokeToPlayer(cid, name, level, stre, gender, boost, btype)

return true
end