--- @class ModulateLight : Action
--- @overload fun(owner: Actor, ...): ModulateLight
local ModulateLight = prism.Action:extend "ModulateLight"
ModulateLight.requiredComponents = { prism.components.LightModulate }

--- @param level Level
function ModulateLight:perform(level)
   local conditions = self.owner:expect(prism.components.ConditionHolder)
   local modulate = self.owner:expect(prism.components.LightModulate)
   modulate.timer = modulate.timer + 1
   if modulate.timer == modulate.max then modulate.timer = 0 end

   if modulate.lights[modulate.timer] then self.owner:give(modulate.lights[modulate.timer]) end
end

return ModulateLight
