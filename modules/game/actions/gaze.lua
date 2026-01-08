--- @class Gaze : Action
--- @overload fun(owner: Actor, ...): Gaze
local Gaze = prism.Action:extend "Gaze"
Gaze.name = "gaze"
Gaze.requiredComponents = { prism.components.Equipper, prism.components.Health, prism.components.ConditionHolder }
Gaze.targets = { prism.targets.EquippedTarget("held", prism.components.Prism) }

--- @param level Level
function Gaze:canPerform(level, prismItem)
   return true
end

--- @param level Level
function Gaze:perform(level, prismItem)
   level:perform(prism.actions.Unequip(self.owner, prismItem))
   self.owner:expect(prism.components.ConditionHolder):add(prism.condition.Condition(prism.modifiers.HealthModifier(1)))
   self.owner:expect(prism.components.Health):heal(math.huge)
   level:yield(prism.messages.GazeMessage(self.owner))
end

return Gaze
