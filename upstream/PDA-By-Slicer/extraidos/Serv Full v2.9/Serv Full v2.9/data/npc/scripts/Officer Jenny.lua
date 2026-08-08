local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function doBuyPokemonWithCasinoCoins(cid, poke) npcHandler:onSellpokemon(cid) end
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)

if(not npcHandler:isFocused(cid)) then
return false
end


if msgcontains(msg, 'join') or msgcontains(msg, 'Join') then
    if not isRocket(cid) and not isOfficer(cid) then
       selfSay("Then you want to join to the police?", cid)
       talkState[cid] = 1
    elseif isRocket(cid) then
       selfSay("You are a member of the team rocket? You will be arrested!", cid)
       talkState[cid] = 0
       return true
    elseif isOfficer(cid) then
       selfSay("You are already a member of the police! Go do your job!", cid)
       talkState[cid] = 0
       return true
    end
elseif msgcontains(msg, 'yes') or msgcontains(msg, 'Yes') and talkState[cid] == 1 then
    selfSay("Then this is it! Go do your job now!", cid)
    setPlayerStorageValue(cid, 665460, 1) --storage de officer!
    setPlayerStorageValue(cid, 181652, 1) --storage da outfit de policial
    talkState[cid] = 0
    return true
end

return true
end
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())