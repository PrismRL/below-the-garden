--- @class TongueBehavior : BehaviorTree.Node
local TongueBehavior = prism.BehaviorTree.Node:extend("TongueBehavior")

function TongueBehavior:run(level, actor, controller)
   local instance = prism.actions.Tongue(actor, nil, controller.blackboard["target"])
   if level:canPerform(instance) then return instance end
end

return TongueBehavior
