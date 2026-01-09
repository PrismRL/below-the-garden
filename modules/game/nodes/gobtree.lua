--- @class GobTree : BehaviorTree.Root
local GobTree = prism.BehaviorTree.Root:extend "GobTree"

local BT = prism.BehaviorTree

GobTree.children = {
   BT.Sequence {
      prism.BehaviorTree.Node(function (self, level, actor, controller)
         local equipper = actor:expect(prism.components.Equipper)
         return not equipper:get("held") and not equipper:get("weapon")
      end),
      BT.Selector {
         BT.Sequence {
            prism.nodes.FindLootBehavior,
            prism.nodes.PerformOnBehavior(prism.actions.Pickup),
            prism.nodes.MoveTowardTargetBehavior,
         },
         BT.Sequence {
            prism.nodes.FindEnemyBehavior,
            prism.nodes.PerformOnBehavior(prism.actions.Steal),
            prism.nodes.MoveTowardTargetBehavior(1),
         },
         prism.nodes.WanderBehavior,
      },
   },
   BT.Sequence {
      prism.nodes.DropWeaponBehavior("held"),
      prism.nodes.DropWeaponBehavior("weapon"),
      prism.nodes.ReturnHomeBehavior(0),
      prism.nodes.MoveTowardTargetBehavior,
   },
   prism.nodes.WaitBehavior,
}

return GobTree
