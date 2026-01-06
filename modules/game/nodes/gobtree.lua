--- @class GobTree : BehaviorTree.Root
local GobTree = prism.BehaviorTree.Root:extend "GobTree"

local BT = prism.BehaviorTree

GobTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior,
      prism.nodes.PerformOnBehavior(prism.actions.Steal),
      prism.nodes.PerformOnBehavior(prism.actions.Attack),
      prism.nodes.MoveTowardTargetBehavior(1),
   },
   prism.nodes.ReturnHomeBehavior(1),
   prism.nodes.WaitBehavior,
}

return GobTree
