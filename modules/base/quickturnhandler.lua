--- @class QuickTurnHandler : TurnHandler
local QuickTurnHandler = prism.TurnHandler:extend "QuickTurnHandler"

function QuickTurnHandler:handleTurn(level, actor, controller)
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
end

return QuickTurnHandler
