--- @class Snuff : Action
--- @overload fun(owner: Actor, ...): Snuff
local Snuff = prism.Action:extend "Snuff"
Snuff.targets = { prism.targets.EquippedTarget("held", prism.components.Snuffable) }
Snuff.name = "snff"

--- @param level Level
--- @param held Actor
function Snuff:perform(level, held)
   level:perform(prism.actions.Unequip(self.owner, held))
   level:perform(prism.actions.Equip(self.owner, prism.actors[held:expect(prism.components.Snuffable).light]()))
end

return Snuff
