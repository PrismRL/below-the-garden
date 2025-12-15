local Log = prism.components.Log
local Name = prism.components.Name

local AttackTarget = prism.Target(prism.components.Health):range(1)

---@class Attack : Action
---@overload fun(owner: Actor, attacked: Actor): Attack
local Attack = prism.Action:extend("Attack")
Attack.targets = { AttackTarget }
Attack.requiredComponents = { prism.components.Attacker }

--- @param level Level
--- @param attacked Actor
function Attack:perform(level, attacked)
   local attacker = self.owner:expect(prism.components.Attacker)

   local damage = prism.actions.Damage(attacked, attacker.damage)
   level:tryPerform(damage)

   local attackName = Name.lower(attacked)
   local ownerName = Name.lower(self.owner)
   local dealt = damage.dealt or 0

   Log.addMessage(self.owner, "You attack the %s for %i damage.", attackName, dealt)
   Log.addMessage(attacked, "The %s attacks you for %i damage!", ownerName, dealt)
   -- stylua: ignore
   Log.addMessageSensed(level, self, "The %s attacks the %s for %i damage.", ownerName, attackName, dealt)
end

return Attack
