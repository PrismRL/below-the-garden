--- @class SqeetoTree : BehaviorTree.Root
local SqeetoTree = prism.BehaviorTree.Root:extend "SqeetoTree"

local BT = prism.BehaviorTree
SqeetoTree.children = {
   BT.Selector {
      BT.Sequence {
         prism.nodes.FindEnemyBehavior(false, 3),
         prism.nodes.PerformOnBehavior(prism.actions.Attack),
         prism.nodes.MoveTowardTargetBehavior(1),
      },
      BT.Sequence {
         prism.nodes.FindLightBehavior,
         prism.nodes.MoveTowardTargetBehavior(1),
      },
   },
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

return SqeetoTree
