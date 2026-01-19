--- @class Ignite : Action
--- @overload fun(owner: Actor, ...): Ignite
local Ignite = prism.Action:extend "Ignite"
Ignite.requiredComponents = { prism.components.Senses }
Ignite.targets = { prism.targets.EquippedTarget("held", prism.components.Ignitable) }
Ignite.name = "lght"

function Ignite:canPerform(level, held)
   for other, _, position in
      self.owner:expect(prism.components.Senses):query(level, prism.components.Fire, prism.components.Position):iter()
   do
      if self.owner:getRange(other) <= 1 then return true end
   end
   return false
end

--- @param level Level
--- @param held Actor
function Ignite:perform(level, held)
   level:perform(prism.actions.Unequip(self.owner, held))
   local light = prism.actors[held:expect(prism.components.Ignitable).light]()
   level:addActor(light)
   level:perform(prism.actions.Equip(self.owner, light))
   level:getSystem(prism.systems.LightSystem):setDirty(light)
end

return Ignite
