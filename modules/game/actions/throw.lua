--- @class Throw : Action
--- @overload fun(owner: Actor, ...): Throw
local Throw = prism.Action:extend "Throw"
Throw.requiredComponents = { prism.components.Equipper, prism.components.Thrower }
Throw.targets = {
   prism.Target():isVector2():filter(function(level, owner, targetObject, previousTargets)
      local range = owner:expect(prism.components.Thrower):getRange()
      return owner:expectPosition():getRange(targetObject) <= range
   end),
}

--- @param level Level
function Throw:canPerform(level)
   return not not self.owner:expect(prism.components.Equipper):get("held")
end

--- @param level Level
function Throw:perform(level, position)
   local held = self.owner:expect(prism.components.Equipper):get("held")
   level:perform(prism.actions.Unequip(self.owner, held))
   level:addActor(held, position:decompose())
end

return Throw
