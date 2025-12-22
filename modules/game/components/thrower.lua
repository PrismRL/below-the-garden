--- @class ThrowRangeModifier : ConditionModifier
--- @field range integer
local ThrowRangeModifier = prism.condition.ConditionModifier:extend "ThrowRangeModifier"

function ThrowRangeModifier:__new(delta)
   self.range = delta
end

prism.register(ThrowRangeModifier)

--- @class Thrower : Component
--- @field private range integer
--- @overload fun(range): Thrower
local Thrower = prism.Component:extend "Thrower"

function Thrower:__new(range)
   self.range = range
end

function Thrower:getRequirements()
   return prism.components.ConditionHolder
end

function Thrower:getRange()
   local modifiers = prism.components.ConditionHolder.getActorModifiers(self.owner, ThrowRangeModifier)

   local modifiedMaxRange = self.range
   for _, modifier in ipairs(modifiers) do
      modifiedMaxRange = modifiedMaxRange + modifier.range
   end

   return modifiedMaxRange
end

function Thrower:getDamage()
   local modifiers = prism.components.ConditionHolder.getActorModifiers(self.owner, prism.modifiers.ThrowDamageModifier)

   local damage = 1
   for _, modifier in ipairs(modifiers) do
      damage = damage + modifier.damage
   end

   return damage
end

return Thrower
