--- @class ModulateLightSystem : System
--- @overload fun(): ModulateLightSystem
local ModulateLightSystem = prism.System:extend "ModulateLightSystem"

function ModulateLightSystem:getRequirements()
   return prism.systems.LightSystem
end

function ModulateLightSystem:onTurn(level, actor)
   if actor:has(prism.components.PlayerController) then
      local lightSystem = level:getSystem(prism.systems.LightSystem)
      for modulator, _ in level:query(prism.components.LightModulate):iter() do
         level:tryPerform(prism.actions.ModulateLight(modulator))
      end
   end
end

return ModulateLightSystem
