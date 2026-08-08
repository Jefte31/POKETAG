function onDeath(cid)

	if getPlayerStorageValue(cid, 63215) >= 1 then
	setPlayerStorageValue(cid, 63215, 0)
	end

	doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
	doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
	doCreatureSetLookDir(cid, SOUTH)
	doPlayerPopupFYI(cid, "test")
	doRemoveCreature(cid)

return true
end
