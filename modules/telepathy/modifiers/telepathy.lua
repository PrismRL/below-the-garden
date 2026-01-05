--- @class TelepathyModifier : ConditionModifier
--- @overload fun(): TelepathyModifier
local TelepathyModifier = prism.condition.ConditionModifier:extend "TelepathyModifier"

function TelepathyModifier:__new(range)
   self.range = range
end

return TelepathyModifier
