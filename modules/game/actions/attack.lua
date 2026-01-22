local AttackTarget = prism.Target(prism.components.Health):range(1)

---@class Attack : Action
---@overload fun(owner: Actor, attacked: Actor): Attack
local Attack = prism.Action:extend("Attack")
Attack.targets = { AttackTarget }
Attack.requiredComponents = { prism.components.Attacker }

--- @param level Level
--- @param attacked Actor
function Attack:perform(level, attacked)
   local blockChance = 0
   for _, mod in
      ipairs(prism.components.ConditionHolder.getActorModifiers(attacked, prism.modifiers.BlockChanceModifier))
   do
      --- @cast mod BlockChanceModifier
      blockChance = blockChance + mod.blockChance
   end

   if blockChance > level.RNG:random() then
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Block(),
         actor = attacked,
         blocking = false,
         override = true,
      })
      return
   end
   local attacker = self.owner:expect(prism.components.Attacker)
   local damage, stunChance = attacker:getDamageAndStunChance()

   if stunChance > level.RNG:random() then
      attacked:expect(prism.components.ConditionHolder):add(prism.conditions.Stunned())
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Stun(),
         actor = attacked,
         y = -1,
      })
   end
   level:tryPerform(prism.actions.Damage(attacked, damage))
end

return Attack
