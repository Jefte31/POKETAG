function onStepIn(cid, item, position, fromPosition)

local ghosts = {"Gastly", "Haunter", "Gengar", "Shiny Gengar", "Misdreavus", "Shiny Abra"}--alterado v2.6

if isSummon(cid) and  isInArray(ghosts, getCreatureName(cid)) then
  return true
else                                                                  --alterado v2.6
  doTeleportThing(cid, fromPosition, false)
end
end