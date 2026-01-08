--- @class InventorySystem : System
local InventorySystem = prism.System:extend "InventorySystem"

function InventorySystem:onActorRemoved(level, actor)
   local query = level:query():relation(actor, prism.relations.HeldByRelation)
end

return InventorySystem