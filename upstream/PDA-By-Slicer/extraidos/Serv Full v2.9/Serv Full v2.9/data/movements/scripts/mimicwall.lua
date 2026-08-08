function onStepOut(cid, item, position, l, f, toPosition, actor)

	if isPlayer(cid) then
	return true end

	if getPlayerStorageValue(cid, 878) >= 1 then
	doRemoveItem(item.uid, 1)
	end

return true
end

function onStepIn(cid, item, position, l, f, toPosition, actor)

	if isPlayer(cid) then return true end

	if getPlayerStorageValue(cid, 878) >= 1 and (getCreatureLookDir(cid) == SOUTH or getCreatureLookDir(cid) == NORTH) then
		doTransformItem(item.uid, 11439)
	end

return true
end