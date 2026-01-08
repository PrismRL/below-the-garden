--- @class EquipmentSystem : System
--- @overload fun(): EquipmentSystem
local EquipmentSystem = prism.System:extend "EquipmentSystem"

function EquipmentSystem:onActorAdded(level, actor)
   local equipment = actor:getRelations(prism.relations.Equipment)

   for actor, _ in pairs(equipment) do
      --- @cast actor Actor
      level:addActor(actor)
   end
end

function EquipmentSystem:onActorRemoved(level, actor)
   local equipment = actor:getRelations(prism.relations.Equipment)

   for actor, _ in pairs(equipment) do
      --- @cast actor Actor
      level:removeActor(actor)
   end
end

return EquipmentSystem
