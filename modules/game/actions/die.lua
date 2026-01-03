---@class Die : Action
---@overload fun(owner: Actor): Die
local Die = prism.Action:extend("Die")

function Die:perform(level)
   local equipment = self.owner:get(prism.components.Equipper)
   if equipment then
      level:tryPerform(prism.actions.Drop(self.owner, equipment:get("weapon")))
      print(level:tryPerform(prism.actions.Drop(self.owner, equipment:get("held"))))
   end
   level:removeActor(self.owner)
   if not level:query(prism.components.PlayerController):first() then level:yield(prism.messages.LoseMessage()) end
end

return Die
