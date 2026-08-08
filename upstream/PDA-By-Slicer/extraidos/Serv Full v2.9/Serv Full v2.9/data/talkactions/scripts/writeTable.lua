function onSay(cid, words, param, channel)

local str = "pokes = {"
local file = io.open('data/writeTable.txt', 'w')
if (not file) then
   sendMsgToPlayer(cid, 20, "File: data/writeTable.txt, not found...")
   return true
end
for i, table in ipairs(oldpokedex) do
    local t = pokes[table[1]]
    local lowLvl = (t.level - 5) <= 0 and 1 or (t.level - 5)
    str = str.. '\n\n["'..table[1]..'"] = {offense = '..t.offense..', defense = '..t.defense..', specialattack = '..t.specialattack..', vitality = '..t.vitality..', agility = '..t.agility..', exp = '..t.exp..', level = '..t.level..', wildLvlMin = '..lowLvl..', wildLvlMax = '..t.level..', type = "'..t.type..'", type2 = "'..t.type2..'"},'
end
str = str.."\n}"
file:write(str)
file:close()
sendMsgToPlayer(cid, 20, "Table add in file 'data/writeTable.txt'...")
return true
end