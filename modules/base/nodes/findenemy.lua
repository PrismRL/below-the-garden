--- @class FindEnemyBehavior : BehaviorTree.Node
local FindEnemyBehavior = prism.BehaviorTree.Conditional:extend("FindEnemyBehavior")

function FindEnemyBehavior:run(level, actor, controller)
   local player = actor:expect(prism.components.Senses):query(level, prism.components.PlayerController):first()
   controller.blackboard["target"] = player
   return not not player
end

return FindEnemyBehavior
