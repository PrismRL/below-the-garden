--- @class Gaze : Action
--- @overload fun(owner: Actor, ...): Gaze
local Gaze = prism.Action:extend "Gaze"
Gaze.requiredComponents = { prism.components.Equipper, prism.components.Health, prism.components.ConditionHolder }
Gaze.targets = { prism.targets.EquippedTarget("held", prism.components.Prism) }

--- @param level Level
function Gaze:canPerform(level, prism)
   return true
end

--- @param level Level
function Gaze:perform(level, prism) end

return Gaze
