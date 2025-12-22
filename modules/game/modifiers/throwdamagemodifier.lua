--- @class ThrowDamageModifier : ConditionModifier
--- @field damage integer
local ThrowDamageModifier = prism.condition.ConditionModifier:extend "ThrowDamageModifier"

function ThrowDamageModifier:__new(delta)
   self.damage = delta
end

return ThrowDamageModifier
