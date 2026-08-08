function onUse(cid, item, frompos, item2, topos)

print("ERRORRRRRRRRRRRRRRRR")

local summon = getCreatureSummons(cid)[1]

	if not isCreature(summon) then
		doPlayerSendCancel(cid, "You need release your pokemon to do that.")
	return true
	end

	if getCreatureHealth(summon) == 0 then return true end

	local pb = getPlayerSlotItem(cid, 8)

	if getLevel(summon) >= 100 then
		doPlayerSendCancel(cid, "Your pokemon is already at maximum level.")
	return true
	end

	if getLevel(summon) == getItemAttribute(pb.uid, "rarecandy") then
		doPlayerSendCancel(cid, "A pokemon can't level up two times in a row by a rare candy.")
	return true
	end

	doPlayerSendTextMessage(cid, 27, "You gave a rare candy to "..getPokeName(summon)..".")

	doCreatureSay(cid, getPokeName(summon)..", take this candy!", TALKTYPE_SAY)
	doRemoveItem(item.uid, 1)


	local level = getItemAttribute(pb.uid, "level")
	local exp = getItemAttribute(pb.uid, "exp")
	local neededexp = getItemAttribute(pb.uid, "nextlevelexp")

	if getHappiness(summon) < 50 then
		doSendMagicEffect(getThingPos(summon), 168)
	return true
	end

	doCreatureSay(summon, "Yum.", TALKTYPE_ORANGE_1)
	doItemSetAttribute(pb.uid, "rarecandy", level + 1)
	doItemSetAttribute(pb.uid, "exp", exp + neededexp)
	doPlayerSendTextMessage(cid, 27, "Your "..getPokeName(summon).." has eaten a rare candy!")
	doSendFlareEffect(getThingPos(summon))
	doSendAnimatedText(getThingPos(summon), "Level up!", 215)
	adjustPokemonLevel(pb.uid, cid, pb.itemid, true)

return true
end
	