local ConditionHolder = prism.components.ConditionHolder

--- @class AttackModifier : ConditionModifier
--- @field damage integer
--- @field knockback integer
local AttackModifier = prism.condition.ConditionModifier:extend "AttackModifier"

function AttackModifier:__new(damage, knockback)
   self.damage = damage or 0
   self.knockback = knockback or 0
end

prism.register(AttackModifier)

--- @class Attacker : Component
--- @overload fun(damage: integer)
local Attacker = prism.Component:extend("Attacker")

--- @param damage integer
function Attacker:__new(damage, knockback)
   self.damage = damage or 0
   self.knockback = knockback or 0
end

function Attacker:getDamageAndKnockback()
   local modifiers = ConditionHolder.getActorModifiers(self.owner, AttackModifier)

   local damage = self.damage
   local knockback = self.knockback
   for _, modifier in ipairs(modifiers) do
      damage = damage + modifier.damage
      knockback = knockback + modifier.knockback
   end

   return damage, knockback
end

return Attacker
