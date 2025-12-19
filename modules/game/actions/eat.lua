--- @class Eat : Action
--- @overload fun(owner: Actor, ...): Eat
local Eat = prism.Action:extend "Eat"
Eat.requiredComponents = { prism.components.Health }
Eat.targets = { prism.targets.InventoryTarget(prism.components.Eatable) }

--- @param level Level
function Eat:canPerform(level, eatable)
   return true
end

--- @param level Level
--- @param eatable Actor
function Eat:perform(level, eatable)
   local healing = eatable:expect(prism.components.Eatable).healing
   self.owner:expect(prism.components.Health):heal(healing)
   self.owner:expect(prism.components.Inventory):removeItem(eatable)
   level:yield(prism.messages.AnimationMessage {
      actor = self.owner,
      y = -1,
      animation = spectrum.animations.Heal(),
   })
end

return Eat
