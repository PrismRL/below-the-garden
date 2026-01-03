--- @class EquipmentSystem : System
--- @overload fun(): EquipmentSystem
local EquipmentSystem = prism.System:extend "EquipmentSystem"

function EquipmentSystem:onActorAdded(level, actor)
   local equipper = actor:get(prism.components.Equipper)

   if equipper then
      for _, item in pairs(equipper.equipped) do
         if not item.level then level:addActor(item) end
      end
   end
end

return EquipmentSystem
