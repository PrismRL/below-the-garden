--- @class AttackEnemyBehavior : BehaviorTree.Node
local AttackEnemyBehavior = prism.BehaviorTree.Node:extend("AttackEnemyBehavior")

function AttackEnemyBehavior:run(level, actor, controller)
   local attack = prism.actions.Attack(actor, controller.blackboard["target"])
   if level:canPerform(attack) then return attack end
   return true
end

return AttackEnemyBehavior
