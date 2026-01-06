--- @class Steal : Action
--- @overload fun(owner: Actor, ...): Steal
local Steal = prism.Action:extend "Steal"
Steal.requiredComponents = { prism.components.Equipper }
Steal.targets = { prism.Target(prism.components.Equipper):range(1):sensed() }

--- @param level Level
--- @param actor Actor
function Steal:canPerform(level, actor)
   return actor:expect(prism.components.Equipper):get("pocket")
end

--- @param level Level
--- @param actor Actor
function Steal:perform(level, actor)
   local equipper = actor:expect(prism.components.Equipper)
   local pocket = equipper:get("pocket")

   level:perform(prism.actions.Unequip(actor, pocket))
   level:perform(prism.actions.Equip(self.owner, pocket))
end

return Steal
