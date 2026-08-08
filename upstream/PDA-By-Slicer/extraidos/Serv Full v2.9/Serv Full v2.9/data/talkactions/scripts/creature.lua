function onSay(cid, words, param, channel)
	local func = doCreateMonster
	if(words:sub(2, 2) == "n") then
		func = doCreateNpc
	end

	local pid = cid
	local level = -1
	local t = string.explode(param, ",")
	if(t[2] and tonumber(t[2])) then
            level = tonumber(t[2])
	end

	local position = getCreaturePosition(pid)
	local effect = CONST_ME_MAGIC_RED
	local ret = func(t[1], position, false)
	if(tonumber(ret) == nil) then
		effect = CONST_ME_POFF
		doPlayerSendDefaultCancel(cid, (ret == false and RETURNVALUE_NOTPOSSIBLE or RETURNVALUE_NOTENOUGHROOM))
	elseif level >= 1 and level <= 100 then
        setWildPokemonLevel(ret, level)	
	end

	doSendMagicEffect(position, effect)
	return true
end