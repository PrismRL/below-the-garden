local AttackTarget = prism.Target(prism.components.Health):range(1)

---@class Attack : Action
---@overload fun(owner: Actor, attacked: Actor): Attack
local Attack = prism.Action:extend("Attack")
Attack.targets = { AttackTarget }
Attack.requiredComponents = { prism.components.Attacker }
local mask = prism.Collision.createBitmaskFromMovetypes { "fly" }

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
         blocking = true,
         override = true,
      })
      return
   end
   local attacker = self.owner:expect(prism.components.Attacker)
   local damage, knockback = attacker:getDamageAndKnockback()

   local direction = (attacked:getPosition() - self.owner:getPosition())
   local final = attacked:expectPosition()
   for _ = 1, knockback do
      local nextpos = final + direction
      if not level:getCellPassable(nextpos.x, nextpos.y, mask) then break end
      final = nextpos
   end
   level:moveActor(attacked, final)

   level:tryPerform(prism.actions.Damage(attacked, damage))
end

return Attack
