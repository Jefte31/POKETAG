local special = specialevo

local types = {
[leaf] = {"Bulbasaur", "Ivysaur", "Oddish", "Gloom", "Bellsprout", "Weepinbell", "Exeggcute", "Chikorita", "Bayleef", "Hoppip", "Skiploom", "Sunkern"},
[water] = {"Squirtle", "Wartortle", "Horsea", "Goldeen", "Magikarp", "Psyduck", "Poliwag", "Poliwhirl", "Tentacool", "Krabby", "Staryu", "Omanyte", "Eevee", "Totodile", "Croconow", "Chinchou", "Marill", "Wooper", "Slowpoke", "Remoraid", "Seadra"},
[venom] = {"Zubat", "Ekans", "Nidoran male", "Nidoran female", "Nidorino", "Nidorina", "Gloom", "Venonat", "Tentacool", "Grimer", "Koffing", "Spinarak", "Golbat"},
[thunder] = {"Magnemite", "Pikachu", "Voltorb", "Eevee", "Chinchou", "Pichu", "Mareep", "Flaaffy", "Elekid"},
[rock] = {"Geodude", "Graveler", "Rhyhorn", "Kabuto", "Slugma", "Pupitar"},
[punch] = {"Machop", "Machoke", "Mankey", "Poliwhirl", "Tyrogue"},
[fire] = {"Charmander", "Charmeleon", "Vulpix", "Growlithe", "Ponyta", "Eevee", "Cyndaquil", "Quilava", "Slugma", "Houndour", "Magby"},
[coccon] = {"Caterpie", "Metapod", "Weedle", "Kakuna", "Paras", "Venonat", "Scyther", "Ledyba", "Spinarak", "Pineco"},
[crystal] = {"Dratini", "Dragonair", "Magikarp", "Omanyte", "Kabuto", "Seadra"},
[dark] = {"Gastly", "Haunter", "Eevee", "Houndour", "Pupitar"},
[earth] = {"Cubone", "Sandshrew", "Nidorino", "Nidorina", "Diglett", "Onix", "Rhyhorn", "Wooper", "Swinub", "Phanpy", "Larvitar"},
[enigma] = {"Abra", "Kadabra", "Psyduck", "Slowpoke", "Drowzee", "Eevee", "Natu", "Smoochum"},
[heart] = {"Rattata", "Pidgey", "Pidgeotto", "Spearow", "Clefairy", "Jigglypuff", "Meowth", "Doduo", "Porygon", "Chansey", "Sentret", "Hoothoot", "Cleffa", "Igglybuff", "Togepi", "Snubull", "Teddiursa"},
[ice] = {"Seel", "Shellder", "Smoochum", "Swinub"},
[king] = {"Slowpoke", "Poliwhirl"},
[metal] = {"Onix", "Scyther"},
[dragon] = {"Seadra"},
[upgrade] = {"Porygon"},
[sun] = {"Sunkern", "Gloom"},
--[sfire] = {"Shiny Charmander", "Shiny Charmeleon", "Shiny Vulpix", "Shiny Growlithe", "Shiny Ponyta", "Shiny Eevee"},
[swater] = {"Shiny Squirtle", "Shiny Wartortle", "Shiny Horsea", "Shiny Goldeen", "Shiny Magikarp", "Shiny Psyduck", "Shiny Poliwag", "Shiny Poliwhirl", "Shiny Tentacool", "Shiny Krabby", "Shiny Staryu", "Shiny Omanyte", "Shiny Eevee"},
[sleaf] = {"Shiny Bulbasaur", "Shiny Ivysaur", "Shiny Oddish", "Shiny Gloom", "Shiny Bellsprout", "Shiny Weepinbell", "Shiny Exeggcute"},
[sheart] = {"Shiny Rattata", "Shiny Pidgey", "Shiny Pidgeotto", "Shiny Spearow", "Shiny Clefairy", "Shiny Jigglypuff", "Shiny Meowth", "Shiny Doduo", "Shiny Porygon", "Shiny Chansey"},
[senigma] = {"Shiny Abra", "Shiny Kadabra", "Shiny Psyduck", "Shiny Slowpoke", "Shiny Drowzee", "Shiny Eevee"},
[srock] = {"Shiny Geodude", "Shiny Graveler", "Shiny Rhyhorn", "Shiny Kabuto"},
[svenom] = {"Shiny Zubat", "Shiny Ekans", "Shiny Nidoran male", "Shiny Nidoran female", "Shiny Nidorino", "Shiny Nidorina", "Shiny Gloom", "Shiny Venonat", "Shiny Tentacool", "Shiny Grimer", "Shiny Koffing"},
[sice] = {"Shiny Seel", "Shiny Shellder"},
[sthunder] = {"Shiny Magnemite", "Shiny Pikachu", "Shiny Voltorb", "Shiny Eevee"},
[scrystal] = {"Shiny Dratini", "Shiny Dragonair", "Shiny Magikarp", "Shiny Omanyte", "Shiny Kabuto"},
[scoccon] = {"Shiny Caterpie", "Shiny Metapod", "Shiny Weedle", "Shiny Kakuna", "Shiny Paras", "Shiny Venonat", "Shiny Scyther"},
[sdarkness] = {"Shiny Gastly", "Shiny Haunter", "Shiny Eevee"},
[spunch] = {"Shiny Machop", "Shiny Machoke", "Shiny Mankey", "Shiny Poliwhirl"},
[searth] = {"Shiny Cubone", "Shiny Sandshrew", "Shiny Nidorino", "Shiny Nidorina", "Shiny Diglett", "Shiny Onix", "Shiny Rhyhorn"}

}

function onUse(cid, item, frompos, item2, topos)

local pokeball = getPlayerSlotItem(cid, 8)

if not isMonster(item2.uid) or not isSummon(item2.uid) or #getCreatureSummons(cid) > 1 then   --alterado v2.9
	return true
end
if getCreatureCondition(item2.uid, CONDITION_INVISIBLE) then return true end

local pevo = poevo[getCreatureName(item2.uid)]

if not isInArray(specialevo, getCreatureName(item2.uid)) then
   if not pevo then
      doPlayerSendCancel(cid, "This pokemon can't evolve.")
		return true
   end

   if pevo.level ~= 1 and not allEvolutionsCanBeInduzedByStone then
      doPlayerSendCancel(cid, "This pokemon doesn't evolve using stones.")
		return true
   end

   if not isPlayer(getCreatureMaster(item2.uid)) or getCreatureMaster(item2.uid) ~= cid then
      doPlayerSendCancel(cid, "You can only use stones on pokemons you own.")
		return true
   end

   if pevo.stoneid ~= item.itemid and pevo.stoneid2 ~= item.itemid then 
      doPlayerSendCancel(cid, "This isn't the needed stone to evolve this pokemon.")
		return true
   end
end

local minlevel = 0

if getPokemonName(item2.uid) == "Eevee" then
   local eevee = ""
   if item.itemid == thunder then
      eevee = "Jolteon"
   elseif item.itemid == water then
      eevee = "Vaporeon"
   elseif item.itemid == fire then
      eevee = "Flareon"
   elseif item.itemid == enigma and allEvolutionsCanBeInduzedByStone then
      eevee = "Espeon"
   elseif item.itemid == dark and allEvolutionsCanBeInduzedByStone then
      eevee = "Umbreon"
   else
      doPlayerSendCancel(cid, "This isn't the required stone to evolve this pokemon.")
      return true
   end
   minlevel = pokes[eevee].level
   if getPlayerLevel(cid) < minlevel then
      doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
		return true
   end
   
   if getPokemonLevel(item2.uid) < 20 then
      return doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (20).")
   end
   doRemoveItem(item.uid, 1)
   doEvolvePokemon(cid, item2, eevee, 0, 0)
   return true
end

if getPokemonName(item2.uid) == "Shiny Eevee" then
   local eevee = ""
   if item.itemid == sthunder then
      eevee = "Shiny Jolteon"
   elseif item.itemid == swater then
      eevee = "Shiny Vaporeon"
   elseif item.itemid == sfire then
      eevee = "Shiny Flareon"
   else
      doPlayerSendCancel(cid, "This isn't the required stone to evolve this pokemon.")
      return true
   end
   minlevel = pokes[eevee].level
   if getPlayerLevel(cid) < minlevel then
		doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
		return true
   end
   if getPokemonLevel(item2.uid) < 20 then
      return doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (20).")
   end
   doRemoveItem(item.uid, 1)
   doEvolvePokemon(cid, item2, eevee, 0, 0)
   return true
end

if isInArray(specialevo, getPokemonName(item2.uid)) then
   if getPokemonName(item2.uid) == "Poliwhirl" then
      local evolution = 0
		local theevo = ""
		local nlevel = 45
      
      if item.itemid == water then
         if getPokemonLevel(item2.uid) >= 36 and getPlayerItemCount(cid, king) >= 1 then
		      evolution = king
				theevo = "Politoed"
			elseif getPokemonLevel(item2.uid) >= 36 and getPlayerItemCount(cid, punch) >= 1 and allEvolutionsCanBeInduzedByStone then
				evolution = punch
				theevo = "Poliwrath"
			else
				if getPokemonLevel(item2.uid) < 36 then
				   doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (36).")
				   return true
				end
				if allEvolutionsCanBeInduzedByStone then
					if getPlayerItemCount(cid, king) <= 0 and getPlayerItemCount(cid, punch) <= 0 then
						doPlayerSendCancel(cid, "You need a water stone and a punch stone (Poliwrath) or a King's Rock (Politoed) to evolve this pokemon.")
					   return true
					end
				else
					if getPlayerItemCount(cid, king) <= 0 then
						doPlayerSendCancel(cid, "You need a Water Stone and a King's Rock to evolve this pokemon to a Politoed.")
					   return true
					end
				end
			end
         minlevel = pokes[theevo].level
         if getPlayerLevel(cid) < minlevel then
			   doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			   return true
			end

			if theevo == "Poliwrath" and getPokemonLevel(item2.uid) < 36 then
			   doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (36).")
			   return true
			end

			if getPlayerItemCount(cid, punch) >= 1 and getPlayerItemCount(cid, king) >= 1 and allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "Please, use your Punch Stone to evolve this pokemon to a Poliwrath, or a King's Rock to a Politoed.")
			   return true
			end

			if evolution == 0 then
				if allEvolutionsCanBeInduzedByStone then
					doPlayerSendCancel(cid, "You need at least one Water Stone, and a Punch Stone (Poliwrath) or a King's Rock (Politoed) to evolve this pokemon.")
				else
					doPlayerSendCancel(cid, "You need at least one Water Stone and a King's Rock to evolve this pokemon.")
				end
			   return true
			end

			if evolution ~= 0 then
			   doEvolvePokemon(cid, item2, theevo, evolution, water)
			   return true
			end

		elseif item.itemid == punch then

			minlevel = pokes["Poliwrath"].level

			if not allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "This is not the required stone to evolve this pokemon.")
			return true
			end

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPokemonLevel(item2.uid) < 36 then
			doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (45).")
			return true
			end

			if getPlayerItemCount(cid, water) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Punch Stone and one Water Stone to evolve this pokemon.")
			return true
			end

			local theevo = "Poliwrath"
			doEvolvePokemon(cid, item2, theevo, water, punch)
	
		elseif item.itemid == king then

			minlevel = pokes["Politoed"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPlayerItemCount(cid, water) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Punch Stone and one King's Rock to evolve this pokemon.")
			return true
			end

			local theevo = "Politoed"
			doEvolvePokemon(cid, item2, theevo, water, king)
		end

     elseif getPokemonName(item2.uid) == "Shiny Poliwhirl" then

		local evolution = 0
		local theevo = ""
		local nlevel = 45

		if item.itemid == swater then

			if getPokemonLevel(item2.uid) >= 36 and getPlayerItemCount(cid, punch) >= 1 and allEvolutionsCanBeInduzedByStone then
				evolution = spunch
				theevo = "Shiny Poliwrath"
			else
				if getPokemonLevel(item2.uid) < 36 then
				doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (36).")
				return true
				end
				if allEvolutionsCanBeInduzedByStone then
					if getPlayerItemCount(cid, punch) <= 0 then
						doPlayerSendCancel(cid, "You need a shining water stone and a shining punch stone Shiny Poliwrath to evolve this pokemon.")
					return true
					end
				else
					
				end
			end

			minlevel = pokes[theevo].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if theevo == "Shiny Poliwrath" and getPokemonLevel(item2.uid) < 36 then
				doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (36).")
			return true
			end

			if getPlayerItemCount(cid, spunch) >= 1 and allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "Please, use your shining Punch Stone to evolve this pokemon to a Poliwrath.")
			return true
			end

			if evolution == 0 then
				if allEvolutionsCanBeInduzedByStone then
					doPlayerSendCancel(cid, "You need at least one shining Water Stone and a shining Punch Stone ,Shiny Poliwrath to evolve this pokemon.")
				else
					doPlayerSendCancel(cid, "You need at least one shining Water Stone evolve this pokemon.")
				end
			return true
			end

			if evolution ~= 0 then
			doEvolvePokemon(cid, item2, theevo, evolution, swater)
			return true
			end

		elseif item.itemid == spunch then

			minlevel = pokes["Shiny Poliwrath"].level

			if not allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "This is not the required shining stone to evolve this pokemon.")
			return true
			end

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPokemonLevel(item2.uid) < 36 then
			doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (45).")
			return true
			end

			if getPlayerItemCount(cid, swater) <= 0 then
			doPlayerSendCancel(cid, "You need at least one shining Punch Stone and one shining Water Stone to evolve this pokemon.")
			return true
			end

			local theevo = "Shiny Poliwrath"
			doEvolvePokemon(cid, item2, theevo, swater, spunch)
		
		end

	elseif getPokemonName(item2.uid) == "Gloom" then

		if getPokemonLevel(item2.uid) < 31 then
		doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (31).")
		return true
		end

	if item.itemid == leaf then

		local theevo = ""
		local evolution = 0

			if getPlayerItemCount(cid, venom) >= 1 and getPlayerItemCount(cid, sun) >= 1 then
			doPlayerSendCancel(cid, "Please, use your Venom Stone to evolve this pokemon to a Vileplume, or a Sun Stone to a Bellossom.")
			return true
			end

			if getPlayerItemCount(cid, venom) <= 0 and getPlayerItemCount(cid, sun) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Leaf Stone, and a Sun Stone (Bellossom) or a Venom Stone (Vileplume) to evolve this pokemon.")
			return true
			end

			if getPlayerItemCount(cid, venom) >= 1 then
			theevo = "Vileplume"
			evolution = venom
			elseif getPlayerItemCount(cid, sun) >= 1 then
			theevo = "Bellossom"
			evolution = sun
			end

			minlevel = pokes[theevo].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			doEvolvePokemon(cid, item2, theevo, evolution, leaf)

		elseif item.itemid == venom then

			minlevel = pokes["Vileplume"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPlayerItemCount(cid, leaf) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Leaf Stone and one Venom Stone to evolve this pokemon.")
			return true
			end

			doEvolvePokemon(cid, item2, "Vileplume", venom, leaf)

		elseif item.itemid == sun then

			minlevel = pokes["Bellossom"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPlayerItemCount(cid, leaf) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Leaf Stone and one Sun Stone to evolve this pokemon.")
			return true
			end

			doEvolvePokemon(cid, item2, "Bellossom", sun, leaf)
		end

      elseif getPokemonName(item2.uid) == "Shiny Gloom" then

		if getPokemonLevel(item2.uid) < 31 then
		doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (31).")
		return true
		end

	if item.itemid == sleaf then

		local theevo = ""
		local evolution = 0

			if getPlayerItemCount(cid, svenom) >= 1 then
			doPlayerSendCancel(cid, "Please, use your shining Venom Stone to evolve this pokemon to a Shiny Vileplume.")
			return true
			end

			if getPlayerItemCount(cid, svenom) <= 0 then
			doPlayerSendCancel(cid, "You need at least one shining Leaf Stone or a shining Venom Stone (Shiny Vileplume) to evolve this pokemon.")
			return true
			end

			if getPlayerItemCount(cid, svenom) >= 1 then
			theevo = "Shiny Vileplume"
			evolution = svenom
			end

			minlevel = pokes[theevo].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			doEvolvePokemon(cid, item2, theevo, evolution, sleaf)

		elseif item.itemid == svenom then

			minlevel = pokes["Shiny Vileplume"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			if getPlayerItemCount(cid, sleaf) <= 0 then
			doPlayerSendCancel(cid, "You need at least one Leaf Stone and one shining Venom Stone to evolve this pokemon.")
			return true
			end

			doEvolvePokemon(cid, item2, "Shiny Vileplume", svenom, sleaf)

		end

	elseif getPokemonName(item2.uid) == "Slowpoke" then

		if getPokemonLevel(item2.uid) < 28 then
		doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (28).")
		return true
		end

		if item.itemid == enigma then

			if not allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "This is not the required stone to evolve this pokemon.")
			return true
			end

			minlevel = pokes["Slowbro"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			doEvolvePokemon(cid, item2, "Slowbro", enigma, 0)

		elseif item.itemid == king then

			minlevel = pokes["Slowking"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			doEvolvePokemon(cid, item2, "Slowking", king, 0)
		end


elseif getPokemonName(item2.uid) == "Shiny Slowpoke" then

		if getPokemonLevel(item2.uid) < 28 then
		doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (28).")
		return true
		end

		if item.itemid == senigma then

			if not allEvolutionsCanBeInduzedByStone then
				doPlayerSendCancel(cid, "This is not the required stone to evolve this pokemon.")
			return true
			end

			minlevel = pokes["Shiny Slowbro"].level

			if getPlayerLevel(cid) < minlevel then
			doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
			return true
			end

			doEvolvePokemon(cid, item2, "Shiny Slowbro", senigma, 0)

		end


	elseif getPokemonName(item2.uid) == "Tyrogue" then

		if getPokemonLevel(item2.uid) < 20 then
		doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve (20).")
		return true
		end

		if not allEvolutionsCanBeInduzedByStone then
			doPlayerSendCancel(cid, "This pokemon doesn't evolve using stones.")
		return true
		end

		local evolution = ""

		if getOffense(item2.uid) == getDefense(item2.uid) then
			evolution = "Hitmontop"
		elseif getOffense(item2.uid) > getDefense(item2.uid) then
			evolution = "Hitmonlee"
		else
			evolution = "Hitmonchan"
		end

		minlevel = pokes[evolution].level

		if getPlayerLevel(cid) < minlevel then
		doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
		return true
		end

		doEvolvePokemon(cid, item2, evolution, punch, 0)
	end

return true
end

local count = poevo[getPokemonName(item2.uid)].count
local stnid = poevo[getPokemonName(item2.uid)].stoneid
local stnid2 = poevo[getPokemonName(item2.uid)].stoneid2
local evo = poevo[getPokemonName(item2.uid)].evolution
local nlevel = poevo[getPokemonName(item2.uid)].level

local count = poevo[getPokemonName(item2.uid)].count
local stnid = poevo[getPokemonName(item2.uid)].stoneid
local stnid2 = poevo[getPokemonName(item2.uid)].stoneid2
local evo = poevo[getPokemonName(item2.uid)].evolution
local nlevel = poevo[getPokemonName(item2.uid)].level


if stnid2 > 1 and (getPlayerItemCount(cid, stnid2) < count or getPlayerItemCount(cid, stnid) < count) then
doPlayerSendCancel(cid, "You need at least one "..getItemNameById(stnid).." and one "..getItemNameById(stnid2).." to evolve this pokemon!")
return true
end

if getPlayerItemCount(cid, stnid) < count then
local str = ""
	if count >= 2 then
	str = "s"
	end
return doPlayerSendCancel(cid, "You need at least "..count.." "..getItemNameById(stnid)..""..str.." to evolve this pokemon!")
end

minlevel = pokes[evo].level

if getPlayerLevel(cid) < minlevel and evolutionByStoneRequireLevel then
doPlayerSendCancel(cid, "You don't have enough level to evolve this pokemon ("..minlevel..").")
return true
end

if getPokemonLevel(item2.uid) < nlevel and evolutionByStoneRequireLevel then
doPlayerSendCancel(cid, "Sorry, your pokemon doesn't have the required level to evolve ("..nlevel..").")
return true
end

if count >= 2 then
stnid2 = stnid
end

doEvolvePokemon(cid, item2, evo, stnid, stnid2)

return TRUE
end
