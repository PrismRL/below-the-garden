--- @class FrogTree : BehaviorTree.Root
local FrogTree = prism.BehaviorTree.Root:extend "FrogTree"

local BT = prism.BehaviorTree

FrogTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior,
      prism.nodes.PerformOnBehavior(prism.actions.Attack),
      prism.nodes.PerformOnBehavior(prism.actions.Tongue),
      prism.nodes.MoveTowardTargetBehavior(1),
   },
   BT.Sequence {
      prism.nodes.ReturnHomeBehavior(1),
      prism.nodes.MoveTowardTargetBehavior,
   },
   prism.nodes.WaitBehavior,
}

return FrogTree
