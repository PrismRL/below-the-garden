--- @class Eat : Action
--- @overload fun(owner: Actor, ...): Eat
local Eat = prism.Action:extend "Eat"
Eat.requiredComponents = { prism.components.Health }
Eat.targets = { prism.targets.EquippedTarget("held", prism.components.Eatable) }

--- @param level Level
function Eat:canPerform(level, eatable)
   return true
end

--- @param level Level
--- @param eatable Actor
function Eat:perform(level, eatable)
   local healing = eatable:expect(prism.components.Eatable).healing
   self.owner:expect(prism.components.Health):heal(healing)
   level:perform(prism.actions.Unequip(self.owner, eatable))
   level:yield(prism.messages.AnimationMessage {
      actor = self.owner,
      y = -1,
      animation = spectrum.animations.Heal(),
   })
end

return Eat
