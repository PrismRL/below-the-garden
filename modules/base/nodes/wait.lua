--- @class WaitBehavior : BehaviorTree.Node
local WaitBehavior = prism.BehaviorTree.Node:extend("WaitBehavior")

function WaitBehavior:run(level, actor, controller)
   return prism.actions.Wait(actor)
end

return WaitBehavior
