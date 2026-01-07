--- @class PoofTree : BehaviorTree.Root
local PoofTree = prism.BehaviorTree.Root:extend "PoofTree"

local BT = prism.BehaviorTree

PoofTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior(true),
      prism.nodes.FleeFromTargetBehavior,
   },
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

return PoofTree
