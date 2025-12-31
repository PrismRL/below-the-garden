--- @class ThrumbleTree : BehaviorTree.Root
local ThrumbleTree = prism.BehaviorTree.Root:extend "ThrumbleTree"

local BT = prism.BehaviorTree

ThrumbleTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior(true),
      BT.Selector {
         BT.Sequence {
            prism.nodes.FindWeaponBehavior,
            prism.nodes.PerformOnBehavior(prism.actions.Pickup),
            prism.nodes.MoveTowardTargetBehavior,
         },
         BT.Sequence {
            prism.nodes.PerformOnBehavior(prism.actions.Attack),
            prism.nodes.MoveTowardTargetBehavior(1),
         },
      },
   },
   BT.Sequence {
      prism.nodes.DropWeaponBehavior,
      prism.nodes.ReturnHomeBehavior(1),
      prism.nodes.MoveTowardTargetBehavior,
   },
   prism.nodes.WaitBehavior,
}

return ThrumbleTree
