--- @class QuickTurnHandler : TurnHandler
local QuickTurnHandler = prism.TurnHandler:extend "QuickTurnHandler"

function QuickTurnHandler:handleTurn(level, actor, controller)
   local ch = actor:get(prism.components.ConditionHolder) 
   if ch then
      local removed = false
      ch:removeIf(function (condition)
         removed = removed or prism.conditions.Stunned:is(condition)
         return prism.conditions.Stunned:is(condition)
      end)

      if removed then return end
   end

   if not actor:getPosition() then return end
   local decision = controller:decide(level, actor, prism.decisions.ActionDecision(actor))
   local action = decision.action

   -- we make sure we got an action back from the controller for sanity's sake
   assert(action, "Actor " .. actor:getName() .. " returned nil from decide/act.")

   while prism.actions.QuickAction:is(action) do
      level:perform(action)
      decision = controller:decide(level, actor, prism.decisions.ActionDecision(actor))
      action = decision.action
   end

   level:perform(action)

      
   if ch and actor:has(prism.components.Slow) then
      print "STUNNING"
      local stun = prism.conditions.Stunned()
      ch:add(stun)
   end
end

return QuickTurnHandler
