local DamageTarget = prism.Target():isType("number")
local Skip = prism.Target():isType("boolean"):optional()

--- @class Damage : Action
--- @overload fun(owner: Actor, damage: number, skip?: boolean): Damage
local Damage = prism.Action:extend("Damage")
Damage.targets = { DamageTarget, Block }
Damage.requiredComponents = { prism.components.Health }

function Damage:perform(level, damage, skip)
   local health = self.owner:expect(prism.components.Health)
   health.hp = health.hp - damage
   self.dealt = damage

   if health.hp <= 0 then level:perform(prism.actions.Die(self.owner)) end
   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Damage(self.owner),
      actor = self.owner,
      blocking = not skip,
   })
end

return Damage
