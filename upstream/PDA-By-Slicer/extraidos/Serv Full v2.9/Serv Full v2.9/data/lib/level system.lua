function getPokemonStatus(name, multiplier)
	local a = pokes[name]
	local m = 1
	if not a then return false end
	if not a.offense then return false end
	if multiplier then m = multiplier end
local ret = {}
	ret.off = a.offense * m
	ret.offense = ret.off

	ret.def = a.defense * m
	ret.defense = ret.def

	ret.agi = a.agility * m
	ret.agility = ret.agi

	ret.spatk = a.specialattack * m
	ret.specialattack = ret.spatk

	ret.vit = a.vitality * m
	ret.vitality = ret.vit
return ret
end

function getPokemonXMLOutfit(name)                --alterado v2.9 \/
local path = "data/monster/pokes/Shiny/"..name..".xml"
local tpw = io.type(io.open(path))

if not tpw then
   path = "data/monster/pokes/geracao 2/"..name..".xml"
   tpw = io.type(io.open(path))
end
if not tpw then
   path = "data/monster/pokes/geracao 1/"..name..".xml"
   tpw = io.type(io.open(path))
end
if not tpw then
   path = "data/monster/pokes/"..name..".xml"
   tpw = io.type(io.open(path))
end   
if not tpw then
   return print("[getPokemonXMLOutfit] Poke with name: "..name.." ins't in any paste on monster/pokes/") and 2
end
   local arq = io.open(path, "a+")
   local txt = arq:read("*all")
   arq:close()
   local a, b = txt:find('look type="(.-)"')
   txt = string.sub(txt, a + 11, b - 1)
return tonumber(txt)
end 

function doEvolutionOutfit(cid, oldout, outfit)
	if not isCreature(cid) then return true end
		if getCreatureOutfit(cid).lookType == oldout then
			doSetCreatureOutfit(cid, {lookType = outfit}, -1)
		else
			doSetCreatureOutfit(cid, {lookType = oldout}, -1)
		end
end

function doStartEvolution(cid, evolution, seconds)
	if not isCreature(cid) then return true end
	local a = getPlayerStorageValue(cid, 1007)
	local b = getCreatureHealth(cid) / getCreatureMaxHealth(cid)
	local d = getThingPos(cid)
	local e = getCreatureMaster(cid)
	if getHappinessRate(cid) < 1 then return true end
	local f = getCreatureOutfit(cid).lookType
	local g = getItemAttribute(getPlayerSlotItem(e, 8).uid, "nick") or getCreatureName(cid)
	local h = getPokemonXMLOutfit(evolution)
	doItemSetAttribute(getPlayerSlotItem(e, 8).uid, "hp", b)
	doCreatureSay(e, "What? My "..g.." is evolving!", TALKTYPE_SAY)
	doSummonMonster(e, "Evolution")
	doReturnPokemon(e, cid, getPlayerSlotItem(e, 8), 0, true)
	local evo = getCreatureSummons(e)[1]
	doEvolutionOutfit(evo, h, f)
	doCreatureSetHideHealth(evo, true)
	doCreatureSetLookDir(evo, 2)
	setPlayerStorageValue(evo, 1007, g)
	doTeleportThing(evo, d, false)
	addEvent(sendSSJEffect, 250, evo)
	doSendAnimatedText(getThingPos(evo), "EVOLUTION", COLOR_GRASS)
	doSendEvolutionEffect(evo, getThingPos(evo), evolution, 20, false, false, f, h)
end

function doSendEvolutionEffect(cid, pos, evolution, turn, ssj, evolve, f, h)
	if not isCreature(cid) then
		doSendAnimatedText(pos, "CANCEL", 215)
	return true end
	if evolve then
		doEvolvePokemon(getCreatureMaster(cid), {uid = cid}, evolution, 0, 0)
	return true
	end
	doSendMagicEffect(pos, 18)
		if ssj then
			sendSSJEffect(evo)
		end
	doEvolutionOutfit(cid, f, h)
	addEvent(doSendEvolutionEffect, math.pow(1900, turn/20), cid, getThingPos(cid), evolution, turn - 1, turn == 19, turn == 2, f, h)
end

function sendSSJEffect(cid)
	if not isCreature(cid) then return true end
	local pos1 = getThingPos(cid)
	local pos2 = getThingPos(cid)
	pos2.x = pos2.x + math.random(-1, 1)
	pos2.y = pos2.y - math.random(1, 2)
	doSendDistanceShoot(pos1, pos2, 37)
	addEvent(sendSSJEffect, 45, cid)
end

function sendFinishEvolutionEffect(cid, alternate)
	if not isCreature(cid) then return true end
	local pos1 = getThingPos(cid)

	if alternate then
		local pos = {
		[1] = {-2, 0},
		[2] = {-1, -1},
		[3] = {0, -2},
		[4] = {1, -1},
		[5] = {2, 0},
		[6] = {1, 1},
		[7] = {0, 2},
		[8] = {-1, 1}}
		for a = 1, 8 do
			local pos2 = getThingPos(cid)
			pos2.x = pos2.x + pos[a][1]
			pos2.y = pos2.y + pos[a][2]
			local pos = getThingPos(cid)
			doSendDistanceShoot(pos2, pos, 37)
			addEvent(doSendDistanceShoot, 300, pos, pos2, 37)
		end
	else
		for a = 0, 3 do
			doSendDistanceShoot(pos1, getPosByDir(pos1, a), 37)
		end
		for a = 4, 7 do
			addEvent(doSendDistanceShoot, 600, pos1, getPosByDir(pos1, a), 37)
		end
	end
end

function doEvolvePokemon(cid, item2, theevo, stone1, stone2)

	if not isCreature(cid) then return true end

	if not pokes[theevo] or not pokes[theevo].offense then
	doReturnPokemon(cid, item2.uid, getPlayerSlotItem(cid, 8), pokeballs[getPokeballType(getPlayerSlotItem(cid, 8).itemid)].effect, false, true)
	return true
	end

	local owner = getCreatureMaster(item2.uid)
	local pokeball = getPlayerSlotItem(cid, 8)
	local description = "Contains a "..theevo.."."
	local pct = getCreatureHealth(item2.uid) / getCreatureMaxHealth(item2.uid)

		doItemSetAttribute(pokeball.uid, "hp", pct)

		doItemSetAttribute(pokeball.uid, "poke", theevo)
		doItemSetAttribute(pokeball.uid, "description", "Contains a "..theevo..".")

		doPlayerSendTextMessage(cid, 27, "Congratulations! Your "..getPokeName(item2.uid).." evolved into a "..theevo.."!")		

		doSendMagicEffect(getThingPos(item2.uid), 18)
		doTransformItem(getPlayerSlotItem(cid, 7).uid, fotos[theevo])
		doSendMagicEffect(getThingPos(cid), 173)

		local oldpos = getThingPos(item2.uid)
		local oldlod = getCreatureLookDir(item2.uid)
		local oldlvl = getPokemonLevel(item2.uid)
		doRemoveCreature(item2.uid)

		doSummonMonster(cid, theevo)
		local pk = getCreatureSummons(cid)[1]

		doTeleportThing(pk, oldpos, false)
		doCreatureSetLookDir(pk, oldlod)

		sendFinishEvolutionEffect(pk, true)
		addEvent(sendFinishEvolutionEffect, 550, pk, true)
		addEvent(sendFinishEvolutionEffect, 1050, pk)
		
		doPlayerRemoveItem(cid, stone1, 1)
		doPlayerRemoveItem(cid, stone2, 1)

		doAddPokemonInOwnList(cid, theevo)

		local status = getPokemonStatus(getCreatureName(pk))

		local off = status.off * 7.5
		local def = status.def * 7.5
		local agi = status.agi * 7.5
		local spatk = status.spatk * 7.5
		local vit = status.vit * 7

		doItemSetAttribute(pokeball.uid, "offense", getItemAttribute(pokeball.uid, "offense") + off)
		doItemSetAttribute(pokeball.uid, "defense", getItemAttribute(pokeball.uid, "defense") + def)
		doItemSetAttribute(pokeball.uid, "speed", getItemAttribute(pokeball.uid, "speed") + agi)
		doItemSetAttribute(pokeball.uid, "specialattack", getItemAttribute(pokeball.uid, "specialattack") + spatk)
		doItemSetAttribute(pokeball.uid, "vitality", getItemAttribute(pokeball.uid, "vitality") + vit)

		doPlayerSendTextMessage(cid, 27, "Evolution bonus: • Offense: +"..doMathDecimal(off).."  • Defense: +"..doMathDecimal(def).."  • Spc. Atk: +"..doMathDecimal(spatk).."  • Agility: +"..doMathDecimal(agi).."  • Vitality: +"..doMathDecimal(vit).."")

		local happy = getItemAttribute(pokeball.uid, "happy")

		doItemSetAttribute(pokeball.uid, "happy", happy + happyGainedOnEvolution)

		if happy + happyGainedOnEvolution > 255 then
			doItemSetAttribute(pokeball.uid, "happy", 255)
		end

		adjustStatus(pk, pokeball.uid, true, false)

		if useKpdoDlls then
			doUpdateMoves(cid)
		end
end

function givePokemonExp(cid, item, expe, pct, rarecandy)

	if expe <= 0 or not isCreature(cid) then return true end

	local leveltable = getPokemonExperienceTable(getPokeballName(item.uid, true))

		if getItemAttribute(item.uid, "exp") + expe > leveltable[100] then
			givePokemonExp(cid, item, leveltable[100] - getItemAttribute(item.uid, "exp"))
		return true
		end

	doItemSetAttribute(item.uid, "exp", getItemAttribute(item.uid, "exp") + expe)
	doItemSetAttribute(item.uid, "happy", getItemAttribute(item.uid, "happy") + 1)
	doItemSetAttribute(item.uid, "nextlevelexp", getItemAttribute(item.uid, "nextlevelexp") - expe)


	if pct then
		doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item.uid).." has received "..expe.." experience points ("..pct.."%).")
	else
		if getItemAttribute(item.uid, "nextlevelexp") > 0 then
			doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item.uid).." ["..getItemAttribute(item.uid, "level").."] has received "..expe.." experience points ("..getItemAttribute(item.uid, "nextlevelexp").." to next level).")
		else
			doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item.uid).." ["..getItemAttribute(item.uid, "level").."] has received "..expe.." experience points and has leveled up!")
		end
	end

	if isBeingUsed(item.itemid) then
	doSendAnimatedText(getThingPos(getCreatureSummons(cid)[1]), expe, 215)
	end

	if getItemAttribute(item.uid, "nextlevelexp") <= 0 then
		local summon = getCreatureSummons(cid)[1]
	
		if not isCreature(summon) then return true end

		doSendFlareEffect(getThingPos(summon))
		doSendAnimatedText(getThingPos(summon), "Level up!", 215)

		adjustPokemonLevel(item.uid, cid, item.itemid)
	    doCreatureAddHealth(summon, getCreatureMaxHealth(summon))
	end
end


function givePokemonExpInBp(cid, item, expe, ballid, pct, hidemessage)

	if expe <= 0 or not isCreature(cid) then return true end

	local leveltable = getPokemonExperienceTable(getPokeballName(item, true))

	if getItemAttribute(item, "exp") + expe > leveltable[100] then
		givePokemonExpInBp(cid, item, leveltable[100] - getItemAttribute(item, "exp"), ballid)
	return true
	end

	doItemSetAttribute(item, "exp", getItemAttribute(item, "exp") + expe)
	doItemSetAttribute(item, "happy", getItemAttribute(item, "happy") + 1)
	doItemSetAttribute(item, "nextlevelexp", getItemAttribute(item, "nextlevelexp") - expe)

	if not hidemessage then
		if pct then
			doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item).." has received "..expe.." experience points ("..pct.."%).")
		else
			if getItemAttribute(item, "nextlevelexp") > 0 then
				doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item).." ["..getItemAttribute(item, "level").."] has received "..expe.." experience points inside his pokeball ("..getItemAttribute(item, "nextlevelexp").." to next level).")
			else
				doPlayerSendTextMessage(cid, 27, "Your "..getPokeballName(item).." ["..getItemAttribute(item, "level").."] has received "..expe.." experience points and has leveled up inside his pokeball.")
				adjustPokemonLevel(item, cid, ballid)
			end
		end
	end
end

function doMathDecimal(number, casas)

	if math.floor(number) == number then return number end

	local c = casas and casas + 1 or 3

	for a = 0, 10 do
		if math.floor(number) < math.pow(10, a) then
			local str = string.sub(""..number.."", 1, a + c)
			return tonumber(str)	
		end
	end

return number
end

function adjustPokemonLevel(item, cid, id, rarecandy)

	if not isCreature(cid) then return true end

	local exp = getItemAttribute(item, "exp")
	local level = getItemAttribute(item, "level")
	local leveltable = getPokemonExperienceTable(getPokeballName(item, true))
	local newlevel = 1

	for x = 1, 100 do
		if exp >= leveltable[x] and exp < leveltable[x+1] then
			newlevel = x
		end
	end

	if newlevel <= 1 then return true end

	local levelsup = (newlevel - level)
	local pokemon = getItemAttribute(item, "poke")
	local happy = getItemAttribute(item, "happy")
	local rate = happy / 100
	local newhappiness = happy

	if happy >= 250 then
		newhappiness = 255
	elseif happy >= 230 then
		newhappiness = happy + 4
	elseif happy >= 210 then
		newhappiness = happy + 6
	elseif happy >= 180 then
		newhappiness = happy + 8
	elseif happy >= 140 then
		newhappiness = happy + 10
	elseif happy >= 110 then
		newhappiness = happy + 12
	else
		newhappiness = happy + 15
	end

	local status = getPokemonStatus(pokemon)

	local off = status.off * rate * levelsup
	local def = status.def * rate * levelsup
	local agi = status.agi * rate * levelsup
	local spatk = status.spatk * rate * levelsup
	local vit = status.vit * rate * levelsup

	doItemSetAttribute(item, "level", newlevel)

	if not rarecandy then
		doItemSetAttribute(item, "happy", newhappiness)
	end

	local nextexp = leveltable[newlevel + 1] - exp
	doItemSetAttribute(item, "nextlevelexp", nextexp)

	doItemSetAttribute(item, "offense", getItemAttribute(item, "offense") + off)
	doItemSetAttribute(item, "defense", getItemAttribute(item, "defense") + def)
	doItemSetAttribute(item, "speed", getItemAttribute(item, "speed") + agi)
	doItemSetAttribute(item, "specialattack", getItemAttribute(item, "specialattack") + spatk)
	doItemSetAttribute(item, "vitality", getItemAttribute(item, "vitality") + vit)

	if newlevel > getPlayerLevel(cid) + pokemonMaxLevelAbovePlayer then
		addEvent(doPlayerSendTextMessage, 30, cid, 18, "Warning: Your "..getPokeballName(item).."'s ["..newlevel.."] level is much higher than yours, so you will not be able to call him to battles.")
	end

	if isCreature(cid) and id >= 1 and isBeingUsed(id) then
		adjustStatus(getCreatureSummons(cid)[1], item, false, true)
		doPlayerSendTextMessage(cid, 27, "• Level: "..newlevel.." (+"..levelsup..")  • Offense: +"..doMathDecimal(off).."  • Defense: +"..doMathDecimal(def).."  • Spc. Atk: +"..doMathDecimal(spatk).."  • Agility: +"..doMathDecimal(agi).."  • Vitality: +"..doMathDecimal(vit).."")

		if happy < minHappyToEvolve then return true end

		if pokemonsCanEvolveByLevel then

			local summon = getCreatureSummons(cid)[1]

			local reqlevel = poevo[getCreatureName(summon)] and poevo[getCreatureName(summon)].level or -1
			local level = getItemAttribute(item, "level")
			local evolution = "none"
			local name = getCreatureName(summon)

			if name == "Tyrogue" and level >= 20 then
				if getOffense(summon) == getDefense(summon) then
					evolution = "Hitmontop"
				elseif getOffense(summon) > getDefense(summon) then
					evolution = "Hitmonlee"
				else
					evolution = "Hitmonchan"
				end
			elseif name == "Eevee" then
				if happy >= maxHappyToEvolve then
					if isDay() then
						evolution = "Espeon"
					else
						evolution = "Umbreon"
					end
				end
			elseif name == "Slowpoke" and level >= 28 then
				evolution = "Slowbro"
			elseif name == "Poliwhirl" and level >= 36 then
				evolution = "Poliwrath"
			elseif reqlevel > 4 and level >= reqlevel then
				evolution = poevo[getCreatureName(summon)].evolution
			elseif reqlevel == 2 and happy >= maxHappyToEvolve then
				evolution = poevo[getCreatureName(summon)] and poevo[getCreatureName(summon)].evolution or "none"
			end

			if evolution ~= "none" then
				doStartEvolution(summon, evolution, 4)
			end
		end
	end
end

function doAdjustWithDelay(cid, pk, health, vit, status)
if isCreature(cid) then                                   --alterado v2.5
   if not isCreature(cid) then return true end
   adjustStatus(pk, getPlayerSlotItem(cid, 8).uid, health, vir, status)
end
end

function adjustStatus(pk, item, health, vite, conditions)

	if not isCreature(pk) then return true end

	local bonusoffense = getItemAttribute(item, boffense) or 0
	local bonusdefense = getItemAttribute(item, bdefense) or 0
	local bonusagility = getItemAttribute(item, bagility) or 0
	local bonussattack = getItemAttribute(item, bsattack) or 0

	setPlayerStorageValue(pk, 1000, getItemAttribute(item, "level"))
	setPlayerStorageValue(pk, 1001, getItemAttribute(item, "offense") + bonusoffense)
	setPlayerStorageValue(pk, 1002, getItemAttribute(item, "defense") + bonusdefense)
	setPlayerStorageValue(pk, 1003, getItemAttribute(item, "speed") + bonusagility)
	setPlayerStorageValue(pk, 1005, getItemAttribute(item, "specialattack") + bonussattack)

	local gender = getItemAttribute(item, "gender") and getItemAttribute(item, "gender") or 0
	doCreatureSetSkullType(pk, gender)

	if vite == true then
		local pct = getCreatureHealth(pk) / getCreatureMaxHealth(pk)
		local vit = getItemAttribute(item, "vitality") - getPlayerStorageValue(pk, 1004)
		setCreatureMaxHealth(pk, getCreatureMaxHealth(pk) + ( vit * HPperVIT ))
		doCreatureAddHealth(pk, pct * vit * HPperVIT)
	end

	setPlayerStorageValue(pk, 1004, getItemAttribute(item, "vitality"))

	doRegainSpeed(pk)

	local nick = getItemAttribute(item, "poke")
	
	if string.find(tostring(nick), "Shiny") then
	   nick = tostring(nick):match("Shiny (.*)")
    end

	if getItemAttribute(item, "nick") then
		nick = getItemAttribute(item, "nick")
	end

	setPlayerStorageValue(pk, 1007, nick)

	local boostlevel = getItemAttribute(item, "boost") or 0
	local boostshow = hideBoost and "]" or " + "..boostlevel.."]"
	local lvlstr = ""

	if showBoostSeparated then
		boostshow = hideBoost and "]" or "] [+"..boostlevel.."]"
	end

	if hideSummonsLevel then
		if not hideBoost then
			nick = nick.." [+"..boostlevel.."]"
		end
	else
		nick = nick.." ["..getItemAttribute(item, "level")..""..boostshow..""
	end

	doCreatureSetNick(pk, nick)

	if not getItemAttribute(item, "happy") then
		doItemSetAttribute(item, "happy", 120)
	end

	if not getItemAttribute(item, "hunger") then
		doItemSetAttribute(item, "hunger", 5)
	end

	local happy = getItemAttribute(item, "happy")
		if happy < 0 then
			happy = 1
		end
	setPlayerStorageValue(pk, 1008, happy)

	local hunger = getItemAttribute(item, "hunger")
	setPlayerStorageValue(pk, 1009, hunger)

	if health == true then
		local mh = getCreatureMaxHealth(pk) + HPperVIT * getVitality(pk)
		local rd = 1 - (tonumber(getItemAttribute(item, "hp")))
		setCreatureMaxHealth(pk, mh)
		doCreatureAddHealth(pk, getCreatureMaxHealth(pk))
		doCreatureAddHealth(pk, -(getCreatureMaxHealth(pk) * rd))
	end

	if isSummon(pk) and conditions then                        --alterado v2.5 daki pra baixo!!
		local burn = getItemAttribute(item, "burn")   
		if burn and burn >= 0 then
		   local ret = {id = pk, cd = burn, check = false, damage = getItemAttribute(item, "burndmg"), cond = "Burn"}
		   addEvent(doCondition2, 3500, ret)
		end

		local poison = getItemAttribute(item, "poison")
		if poison and poison >= 0 then
		   local ret = {id = pk, cd = poison, check = false, damage = getItemAttribute(item, "poisondmg"), cond = "Poison"}
		   addEvent(doCondition2, 1500, ret)
		end

        local confuse = getItemAttribute(item, "confuse")
		if confuse and confuse >= 0 then
		   local ret = {id = pk, cd = confuse, check = false, cond = "Confusion"}
		   addEvent(doCondition2, 1200, ret)                                                --alterado v2.5
		end

        local sleep = getItemAttribute(item, "sleep")
		if sleep and sleep >= 0 then
		   local ret = {id = pk, cd = sleep, check = false, first = true, cond = "Sleep"}
		   doCondition2(ret)
		end
		
		local miss = getItemAttribute(item, "miss")     
		if miss and miss >= 0 then      
          local ret = {id = pk, cd = miss, eff = getItemAttribute(item, "missEff"), check = false, spell = getItemAttribute(item, "missSpell"), cond = "Miss"}
          doCondition2(ret)
        end
        
        local fear = getItemAttribute(item, "fear")
        if fear and fear >= 0 then
           local ret = {id = pk, cd = fear, check = false, skill = getItemAttribute(item, "fearSkill"), cond = "Fear"}
           doCondition2(ret)
        end
        
        local silence = getItemAttribute(item, "silence")
        if silence and silence >= 0 then      
           local ret = {id = pk, cd = silence, eff = getItemAttribute(item, "silenceEff"), check = false, cond = "Silence"}
           doCondition2(ret)
        end                                     
        
        local stun = getItemAttribute(item, "stun")
        if stun and stun >= 0 then
           local ret = {id = pk, cd = stun, eff = getItemAttribute(item, "stunEff"), check = false, spell = getItemAttribute(item, "stunSpell"), cond = "Stun"}
           doCondition2(ret)
        end 
                                                       
        local paralyze = getItemAttribute(item, "paralyze")
        if paralyze and paralyze >= 0 then
           local ret = {id = pk, cd = paralyze, eff = getItemAttribute(item, "paralyzeEff"), check = false, first = true, cond = "Paralyze"}
           doCondition2(ret)
        end  
                                                     
        local slow = getItemAttribute(item, "slow")
        if slow and slow >= 0 then
           local ret = {id = pk, cd = slow, eff = getItemAttribute(item, "slowEff"), check = false, first = true, cond = "Slow"}
           doCondition2(ret)
        end                                              
        
        local leech = getItemAttribute(item, "leech")
        if leech and leech >= 0 then
           local ret = {id = pk, cd = leech, attacker = 0, check = false, damage = getItemAttribute(item, "leechdmg"), cond = "Leech"}
           doCondition2(ret)
        end                               
        
        for i = 1, 3 do
            local buff = getItemAttribute(item, "Buff"..i)
            if buff and buff >= 0 then
               local ret = {id = pk, cd = buff, eff = getItemAttribute(item, "Buff"..i.."eff"), check = false, 
               buff = getItemAttribute(item, "Buff"..i.."skill"), first = true, attr = "Buff"..i}
               doCondition2(ret)
            end
        end
               
	end
	                                                                   --alterado v2.9 
    if getItemAttribute(item, "boost") and getItemAttribute(item, "boost") >= 50 and getItemAttribute(item, "aura") then
       sendAuraEffect(pk, auraSyst[getItemAttribute(item, "aura")])        
    end
    
    if getPlayerStorageValue(getCreatureMaster(pk), 6598754) >= 1 then
        setPlayerStorageValue(pk, 6598754, 1)                               
    elseif getPlayerStorageValue(getCreatureMaster(pk), 6598755) >= 1 then
        setPlayerStorageValue(pk, 6598755, 1)
    end

return true
end

function setWildPokemonLevel(cid, optionalLevel, optionalStatus, optionalNick, optionalExtraExp)

	if not isCreature(cid) then return true end
	if not pokes[getCreatureName(cid)] then return true end  --alterado v2.6

	local levelRange = 0
	local off = 0
	local def = 0
	local agi = 0
	local spatk = 0
	local vit = 0
	local this = getCreatureName(cid)
	local ee = 1

	if optionalExtraExp then
		ee = optionalExtraExp
	end


	if optionalLevel and tonumber(optionalLevel) >= 1 then                --alterado v2.8\/
	    levelRange = optionalLevel
	else
	    levelRange = math.random(pokes[this].wildLvlMin, pokes[this].wildLvlMax) 
	end                                                                                          

	local status = getPokemonStatus(this)
		if status then
			off = status.off
			def = status.def
			agi = status.agi
			vit = status.vit
			spatk = status.spatk
		end

	setPlayerStorageValue(cid, 1000, (levelRange > 100 and 100 or levelRange)) --alterado v2.8

	if optionalStatus and optionalStatus.off then
		setPlayerStorageValue(cid, 1001, optionalStatus.offense)
		setPlayerStorageValue(cid, 1002, optionalStatus.defense)
		setPlayerStorageValue(cid, 1003, optionalStatus.agility)
		setPlayerStorageValue(cid, 1004, optionalStatus.vitality)
		setPlayerStorageValue(cid, 1005, optionalStatus.specialattack)
		setPlayerStorageValue(cid, 1011, optionalStatus.offense)
		setPlayerStorageValue(cid, 1012, optionalStatus.defense)
		setPlayerStorageValue(cid, 1013, optionalStatus.agility)
		setPlayerStorageValue(cid, 1014, optionalStatus.vitality)
		setPlayerStorageValue(cid, 1015, optionalStatus.specialattack)
	else
		setPlayerStorageValue(cid, 1001, 5 + math.random(off * levelRange * 0.9, off * levelRange * 1.8))
		setPlayerStorageValue(cid, 1002, 5 + math.random(def * levelRange * 0.9, def * levelRange * 1.8))
		setPlayerStorageValue(cid, 1003, math.random(agi * levelRange * 0.9, agi * levelRange * 1.8))
		setPlayerStorageValue(cid, 1004, math.random(vit * levelRange * 0.9, vit * levelRange * 1.8))
		setPlayerStorageValue(cid, 1005, 5 + math.random(spatk * levelRange * 0.9, spatk * levelRange * 1.8))
		setPlayerStorageValue(cid, 1011, getPlayerStorageValue(cid, 1001))
		setPlayerStorageValue(cid, 1012, getPlayerStorageValue(cid, 1002))
		setPlayerStorageValue(cid, 1013, getPlayerStorageValue(cid, 1003))
		setPlayerStorageValue(cid, 1014, getPlayerStorageValue(cid, 1004))
		setPlayerStorageValue(cid, 1015, getPlayerStorageValue(cid, 1005))
	end

	doRegainSpeed(cid)

	setCreatureMaxHealth(cid, getCreatureMaxHealth(cid) + getPlayerStorageValue(cid, 1004) * HPperVIT * vitReductionForWild)
	doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
    
	if pokes[getCreatureName(cid)].exp then
		--getMonsterInfo(getCreatureName(cid)).experience
		local exp = (50 + pokes[getCreatureName(cid)].exp) * baseExpRate + pokes[getCreatureName(cid)].vitality * levelRange * pokemonExpPerLevelRate
		setPlayerStorageValue(cid, 1006, exp * generalExpRate * ee)
		if getPlayerStorageValue(cid, 22546) == 1 then
          setPlayerStorageValue(cid, 1006, 750)
          doSetCreatureDropLoot(cid, false)         --edited golden arena
       end  
	end

	local wildshow = wildBeforeNames and "Wild " or ""
	if optionalNick then
		if hideWildsLevel then
			doCreatureSetNick(cid, optionalNick)
		else
			doCreatureSetNick(cid, optionalNick.." ["..getWildPokemonLevel(cid).."]")
		end
	else
		if hideWildsLevel then
			doCreatureSetNick(cid, ""..wildshow..""..getCreatureName(cid).."")
		else
			doCreatureSetNick(cid, ""..wildshow..""..getCreatureName(cid).." ["..getWildPokemonLevel(cid).."]")
		end
	end
end

function getOffenseInRage(cid)  --alterado v2.8
	if not isCreature(cid) then return 0 end

	if getPlayerStorageValue(cid, 547888) >= 1 then
		return tonumber(getPlayerStorageValue(cid, 1001)) / 2
	end 

return tonumber(getPlayerStorageValue(cid, 1001))
end

function getOffense(cid)
	if not isCreature(cid) then return 0 end

	--[[if getPlayerStorageValue(cid, 3894) >= 1 then
		return tonumber(getPlayerStorageValue(cid, 1001)) / 2
	end ]]

return tonumber(getPlayerStorageValue(cid, 1001))
end

function getDefense(cid)
	if not isCreature(cid) then return 0 end

--[[	if getPlayerStorageValue(cid, 3894) >= 1 then
		return tonumber(getPlayerStorageValue(cid, 1002)) / 2
	end  ]]

return tonumber(getPlayerStorageValue(cid, 1002))
end

function getSpeed(cid)
	if not isCreature(cid) then return 0 end
return tonumber(getPlayerStorageValue(cid, 1003))
end

function getVitality(cid)
	if not isCreature(cid) then return 0 end
return tonumber(getPlayerStorageValue(cid, 1004))
end

function getSpecialAttack(cid)
	if not isCreature(cid) then return 0 end
return tonumber(getPlayerStorageValue(cid, 1005))
end

function getHappiness(cid)
	if not isCreature(cid) then return 0 end
return tonumber(getPlayerStorageValue(cid, 1008))
end

function getSpecialDefense(cid)
	if not isCreature(cid) then return 0 end
return getSpecialAttack(cid) * 0.85 + getDefense(cid) * 0.2
end

function getWildPokemonExp(cid)
return getPlayerStorageValue(cid, 1006)
end

function getWildPokemonLevel(cid)
return getPlayerStorageValue(cid, 1000)
end

function getLevel(cid)
	if isSummon(cid) then
	return getItemAttribute(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, "level")
	end
return getPlayerStorageValue(cid, 1000)
end

function getPokeName(cid)
	if not isSummon(cid) then return getCreatureName(cid) end
	if getCreatureName(cid) == "Evolution" then return getPlayerStorageValue(cid, 1007) end
	
local item = getPlayerSlotItem(getCreatureMaster(cid), 8)
	if getItemAttribute(item.uid, "nick") then                          --alterado v2.7
	   return getItemAttribute(item.uid, "nick")
	end
	if string.find(tostring(getCreatureName(cid)), "Shiny") then
      local newName = tostring(getCreatureName(cid)):match("Shiny (.*)")
      return newName
    end
return getCreatureName(cid)
end

function getPokeballName(item, truename)
if not truename and getItemAttribute(item, "nick") then
return getItemAttribute(item, "nick")
end
return getItemAttribute(item, "poke")
end

function getPokemonName(cid)
return getCreatureName(cid)
end

function getMasterLevel(poke)
    if not isSummon(poke) then return 0 end
return getPlayerLevel(getCreatureMaster(poke)) --alterado v2.5
end

function getPokeballBoost(ball)
    if not isPokeball(ball.itemid) then return 0 end  --alterado v2.8
return getItemAttribute(ball.uid, "boost") or 0
end

function getPokemonBoost(poke)
    if not isSummon(poke) then return 0 end       --alterado v2.5
return getItemAttribute(getPlayerSlotItem(getCreatureMaster(poke), 8).uid, "boost") or 0
end

function getPokemonLevelByName(name)
return pokes[name] and pokes[name].level or 0  --alterado v2.9
end

function getPokemonLevel(cid)
	if not isCreature(cid) then return 0 end
return getPlayerStorageValue(cid, 1000)
end

function getPokemonGender(cid)
return getCreatureSkullType(cid)
end

function setPokemonGender(cid, gender)
if isCreature(cid) and gender then        --alterado v2.8
   doCreatureSetSkullType(cid, gender)
   return true
end
return false
end