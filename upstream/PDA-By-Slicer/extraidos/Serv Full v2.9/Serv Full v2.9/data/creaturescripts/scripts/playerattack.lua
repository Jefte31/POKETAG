local fightcondition = createConditionObject(CONDITION_INFIGHT)
setConditionParam(fightcondition, CONDITION_PARAM_TICKS, 12 * 1000)

function fightCondic(cid)
	if not isCreature(cid) then return true end
	if not isCreature(getCreatureTarget(cid)) then return true end
	doAddCondition(cid, fightcondition)
addEvent(fightCondic, 1000, cid)
end

function onTarget(cid, target)

if isPlayer(target) then
   if canAttackOther(cid, target) == "Cant" then            --edited PVP system
      return false 
   elseif isPlayer(target) and #getCreatureSummons(target) >= 1 and canAttackOther(cid, target) == "Can" then
      return false
   end
end

if getPlayerStorageValue(target, 201) ~= -1 then
for a, b in pairs(ginasios) do
if getPlayerStorageValue(target, ginasios[getPlayerStorageValue(target, 201)].storage) == 1 then
	if getPlayerStorageValue(cid, ginasios[getPlayerStorageValue(target, 201)].storage) ~= 1 then
	doPlayerSendCancel(cid, "You can't attack this pokemon.")
	return false
	end
end
end
end

if isSummon(target) then                             --edited PVP system
	if canAttackOther(cid, target) == "Cant" then
	return false
	end
end

if false then -- desativado

        if not isPlayerInAgressiveList(target, cid) then
        addPlayerToAgressiveList(target, cid)
        end

	if isPassive(target) then
       		setAgressive(target)
			if #getCreatureSummons(cid) >= 1 then
				doMonsterSetTarget(target, getCreatureSummons(cid)[1])

			else
        			doMonsterSetTarget(target, cid)
			end

	else
		local histarget = getCreatureTarget(target)
		if isCreature(histarget) and isPlayer(getCreatureMaster(histarget)) and #getCreatureSummons(cid) >= 1 and #getCreatureSummons(getCreatureMaster(histarget)) <= 0 then
			doMonsterSetTarget(target, getCreatureSummons(cid)[1])
		end
	end
end

return TRUE
end