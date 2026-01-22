--- @class SnuffHeld : Action
--- @overload fun(owner: Actor, ...): SnuffHeld
local SnuffHeld = prism.Action:extend "SnuffHeld"
SnuffHeld.targets = { prism.targets.EquippedTarget("held", prism.components.Snuffable) }
SnuffHeld.name = "snff"

--- @param level Level
--- @param held Actor
function SnuffHeld:perform(level, held)
   level:perform(prism.actions.Unequip(self.owner, held))
   level:perform(prism.actions.Equip(self.owner, prism.actors[held:expect(prism.components.Snuffable).light]()))
end

return SnuffHeld
