--- @class SqeetoTree : BehaviorTree.Root
local SqeetoTree = prism.BehaviorTree.Root:extend "SqeetoTree"

local BT = prism.BehaviorTree
SqeetoTree.children = {
   BT.Sequence {
      prism.nodes.FindLightBehavior,
      BT.Sequence {
         prism.nodes.PerformOnBehavior(prism.actions.Attack),
         prism.nodes.MoveTowardTargetBehavior(1),
      },
   },
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

return SqeetoTree
