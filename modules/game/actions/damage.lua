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

   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Damage(self.owner),
      actor = self.owner,
      blocking = not skip,
   })

   if health.hp <= 0 then
      health.hp = 0
      if prism.components.ConditionHolder.entityHas(self.owner, prism.conditions.Undying) then
         local light = prism.actors.HelmLight()
         level:addActor(light, self.owner:expectPosition():decompose())
         level:yield(prism.messages.AnimationMessage {
            animation = spectrum.animations.Wait(0.5),
            blocking = true,
         })
         level:removeActor(light)
         health.hp = 5
         level:tryPerform(prism.actions.Unequip(self.owner, self.owner:expect(prism.components.Equipper):get("amulet")))
      else
         level:perform(prism.actions.Die(self.owner))
      end
   end
end

return Damage
