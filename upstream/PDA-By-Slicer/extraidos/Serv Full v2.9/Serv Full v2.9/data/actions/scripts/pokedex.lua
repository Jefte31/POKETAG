local rate = 20

function onUse(cid, item, fromPos, item2, toPos)
 
if not isCreature(item2.uid) then
return true
end

local poke = getCreatureName(item2.uid)

	if isMonster(item2.uid) then
       local this = newpokedex[getCreatureName(item2.uid)]
	   local leveltable = getPokemonExperienceTable(getCreatureName(item2.uid)) 
	   local myball = 0
	   if isSummon(item2.uid) then
	      myball = getPlayerSlotItem(getCreatureMaster(item2.uid), 8)
       end

       if not getPlayerInfoAboutPokemon(cid, poke).dex then
          local exp = this.level * rate
          doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have unlocked "..getCreatureName(item2.uid).." in your pokedex!")
          doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have gained "..exp.." experience points.")
          doSendMagicEffect(getThingPos(cid), 210)
          doPlayerAddExperience(cid, exp)
          doAddPokemonInDexList(cid, poke)
       else
          doShowPokedexRegistration(cid, item2, myball, leveltable)
       end
    return true
    end

if not isPlayer(item2.uid) then return true end
                                                  --alterado v2.7 \/\/
	local kanto = 0
	local johto = 0

	for i = 1, #oldpokedex do
		if getPlayerInfoAboutPokemon(item2.uid, oldpokedex[i][1]).dex then
		   if i <= 151 then
              kanto = kanto+1
           elseif i >= 209 then
              johto = johto+1
           end
		end
	end                                                      

	local player = getRecorderPlayer(toPos, cid)

	if cid == player then
	    doPlayerSendTextMessage(cid, 27, "You has unlocked "..kanto.." kanto's and "..johto.." johto's pokémons until now.") 
        doPlayerSetVocation(cid, 9)
        openChannelDialog(cid)
	end

return true
end