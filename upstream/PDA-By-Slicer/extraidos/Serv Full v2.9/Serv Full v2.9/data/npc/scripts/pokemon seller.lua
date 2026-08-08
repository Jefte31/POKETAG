local focus = 0
local talk_start = 0
local conv = 0
local cost = 0
local pname = ""
local levels = ""
local soldlevel = 0
local baseprice = 0

local pokePrice = {        --preço dos pokes.. 3000 = 3k..
["Bulbasaur"] = 3000,                                                   --PS: teve mais coisas mudadas entao.. peguem o script todo!
["Ivysaur"] = 4500,        --alterado v2.6
["Venusaur"] = 12000,
}

function sellPokemon(cid, name, level, price)

	local bp = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	
	if #getCreatureSummons(cid) >= 1 then
       selfSay("Back your pokemon to do that!")
       focus = 0                                --alterado v2.8
       return true
    end
    local storages = {17000, 63215, 17001, 13008, 5700}   --alterado v2.8
    for s = 1, #storages do
        if getPlayerStorageValue(cid, storages[s]) >= 1 then
           selfSay("You can't do that while is Flying, Riding, Surfing, Diving or mount a bike!") 
           focus = 0 
           return true
        end
    end
	
	if getPlayerSlotItem(cid, 8).uid ~= 0 then
       local ball = getPlayerSlotItem(cid, 8).uid 
       if string.lower(getItemAttribute(ball, "poke")) == string.lower(name) and getItemAttribute(ball, "level") == level then
          if not getItemAttribute(ball, "unique") then  --alterado v2.6
             selfSay("Wow! Thanks for this wonderful "..getItemAttribute(ball, "poke").." level "..getItemAttribute(ball, "level").."! Take yours "..price.." dollars. Would you like to sell another pokemon?")
             doRemoveItem(getPlayerSlotItem(cid, 8).uid, 1)              --alterado v2.6
             doPlayerAddMoney(cid, price * 100)
             doTransformItem(getPlayerSlotItem(cid, CONST_SLOT_LEGS).uid, 2395)
             return true
          end
       end
    end

	for a, b in pairs(pokeballs) do
		local balls = getItemsInContainerById(bp.uid, b.on)
		for _, ball in pairs (balls) do
			if string.lower(getItemAttribute(ball, "poke")) == string.lower(name) and getItemAttribute(ball, "level") == level then
				if not getItemAttribute(ball, "unique") then --alterado v2.6
                   selfSay("Wow! Thanks for this wonderful "..getItemAttribute(ball, "poke").." level "..getItemAttribute(ball, "level").."! Take yours "..price.." dollars. Would you like to sell another pokemon?")
				   doRemoveItem(ball, 1)
				   doPlayerAddMoney(cid, price * 100)
	            end
			return true
			end
		end
	end

	selfSay("You don't have a "..name.." at level "..level..", make sure it is in your backpack and it is not fainted and it is not in a Unique Ball!")  
return false                                                                                                                  --alterado v2.6
end

function doSearchForPokemon(cid, name)

	local ret = {}
	local bp = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)

	for a, b in pairs(pokeballs) do
		local balls = getItemsInContainerById(bp.uid, b.on)
		for _, ball in pairs (balls) do
			if string.lower(getItemAttribute(ball, "poke")) == string.lower(name) then
				table.insert(ret, getItemAttribute(ball, "level"))
			end
		end
	end

return ret
end

function onCreatureSay(cid, type, msg)

	local msg = string.lower(msg)

	if string.find(msg, "!") or string.find(msg, ",") then
	return true
	end

	if focus == cid then
		talk_start = os.clock()
	end

	if msgcontains(msg, 'hi') and focus == 0 and getDistanceToCreature(cid) <= 3 then
		selfSay('Welcome to my store! I buy pokemons of all species, just tell me the name of the pokemon you want to sell.')
		focus = cid
		conv = 1
		talk_start = os.clock()
		cost = 0
		pname = ""
		levels = ""
		soldlevel = 0
	return true
	end

	if msgcontains(msg, 'bye') and focus == cid then
		selfSay('See you around then!')
		focus = 0
	return true
	end

	if msgcontains(msg, 'yes') and focus == cid and conv == 4 then
		selfSay('Tell me the name of the pokemon you would like to sell.')
		conv = 1
	return true
	end

	if msgcontains(msg, 'no') and conv == 4 and focus == cid then
		selfSay('Ok, see you around then!')
		focus = 0
	return true
	end

	local common = {"rattata", "caterpie", "weedle", "magikarp"}

	if conv == 1 and focus == cid then
		for a = 1, #common do
			if msgcontains(msg, common[a]) then
				selfSay('I dont buy such a common pokemon!')
			return true
			end
		end
	end

	if msgcontains(msg, 'no') and conv == 3 and focus == cid then
		selfSay('Well, then what pokemon would you like to sell?')
		conv = 1
	return true
	end

	if (conv == 1 or conv == 4) and focus == cid then
		local name = doCorrectPokemonName(msg)
		local pokemon = pokes[name]
		if not pokemon then
			selfSay("Sorry, I don't know what pokemon you're talking about! Are you sure you spelled it correctly?")
		return true
		end
                           --alterado v2.6
		baseprice = pokePrice[name] or math.floor(pokemon.level * 1.5) -- preço baseado na tabela ou no level base
		local lvls = doSearchForPokemon(cid, name)

		if #lvls <= 0 then
			selfSay("Hey, you don't seem to have any "..name.." inside your backpack, make sure it is not fainted.")
		return true
		end

		if #lvls >= 2 then
			local answer = "You have more than one "..name..", they are at level "
				levels = ""
			for a = 1, #lvls do
				if a == #lvls then
					answer = answer.." and "..lvls[a]..". Tell me the level of which one you would like to sell."
				elseif a == 1 then
					answer = answer..""..lvls[a]..""
				else
					answer = answer..", "..lvls[a]..""
				end
				levels = levels.."."..lvls[a].."."
			end
			selfSay(answer)
			pname = name
			conv = 2
		return true
		else
			cost = pokePrice[name] or baseprice * lvls[1] --alterado v2.6
			pname = name
			selfSay("You have only one "..name..", and it is at level "..lvls[1]..", are you sure you want to sell it for "..cost.." dollars?")
			soldlevel = lvls[1]
			conv = 3
		return true
		end
	end

	if focus == cid and conv == 2 then
		if tonumber(msg) == nil then
			selfSay("Tell me the level of the "..pname.." you want to sell!")
		elseif string.find(levels, "."..msg..".") then
			cost = baseprice * tonumber(msg)
			selfSay("So, you want to sell a "..pname.." at level "..msg.." for "..cost.." dollars, is that right?")
			soldlevel = tonumber(msg)
			conv = 3
		else
			selfSay("You don't have a "..pname.." at that level sir.")
		end
	return true
	end

	if isConfirmMsg(msg) and focus == cid and conv == 3 then
		if sellPokemon(cid, pname, soldlevel, cost) then
			conv = 4
		else
			conv = 1
		end
	return true
	end

end

local intervalmin = 38
local intervalmax = 70
local delay = 25
local number = 1
local messages = {"Buying some beautiful pokemons! Come here to sell them!",
		  "Wanna sell a pokemon? Came to the right place!",
		  "Buy pokemon! Excellent offers!",
		  "Tired of a pokemon? Why don't you sell it to me then?",
		 }

function onThink()

	if focus == 0 then
		selfTurn(1)
			delay = delay - 0.5
			if delay <= 0 then
				selfSay(messages[number])
				number = number + 1
					if number > #messages then
						number = 1
					end
				delay = math.random(intervalmin, intervalmax)
			end
		return true
	else

	if not isCreature(focus) then
		focus = 0
	return true
	end

		local npcpos = getThingPos(getThis())
		local focpos = getThingPos(focus)

		if npcpos.z ~= focpos.z then
			focus = 0
		return true
		end

		if (os.clock() - talk_start) > 70 then
			focus = 0
			selfSay("I have other clients too, talk to me when you feel like selling a pokemon.")
		end

		if getDistanceToCreature(focus) > 3 then
			selfSay("Good bye then and thanks!")
			focus = 0
		return true
		end

		local dir = doDirectPos(npcpos, focpos)	
		selfTurn(dir)
	end


return true
end