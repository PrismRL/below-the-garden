--- @class SnipTree : BehaviorTree.Root
local SnipTree = prism.BehaviorTree.Root:extend "SnipTree"

local BT = prism.BehaviorTree

SnipTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior,
      prism.nodes.PerformOnBehavior(prism.actions.Sing),
      prism.nodes.MoveTowardTargetBehavior(0),
   },
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

return SnipTree
