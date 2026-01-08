--- @class EquipmentSystem : System
--- @overload fun(): EquipmentSystem
local EquipmentSystem = prism.System:extend "EquipmentSystem"

function EquipmentSystem:postInitialize(level)
   -- for actor, equipper in level:query(prism.components.Equipper):iter() do
   --    --- @cast equipper Equipper
   --    for _, equipment in pairs(equipper.equipped) do
   --       if not level:hasActor(equipment) then level:addActor(equipment) end
   --    end
   -- end
end

function EquipmentSystem:onActorAdded(level, actor)
   local equipment = actor:getRelations(prism.relations.EquippedRelation)

   for actor, _ in pairs(equipment) do
      --- @cast actor Actor
      level:addActor(actor)
   end
end

function EquipmentSystem:onActorRemoved(level, actor)
   local equipment = actor:getRelations(prism.relations.EquippedRelation)

   for actor, _ in pairs(equipment) do
      --- @cast actor Actor
      level:removeActor(actor)
   end
end

return EquipmentSystem
