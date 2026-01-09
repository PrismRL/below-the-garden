--- @class GobTree : BehaviorTree.Root
local GobTree = prism.BehaviorTree.Root:extend "GobTree"

local BT = prism.BehaviorTree

GobTree.children = {
   BT.Sequence {
      prism.BehaviorTree.Node(function (self, level, actor, controller)
         return not actor:expect(prism.components.Equipper):get("held")
      end),
      prism.nodes.FindWeaponBehavior,
      prism.nodes.PerformOnBehavior(prism.actions.Pickup),
      prism.nodes.MoveTowardTargetBehavior,
   },
   BT.Sequence {
      prism.BehaviorTree.Node(function (self, level, actor, controller)
         return not actor:expect(prism.components.Equipper):get("held")
      end),
      prism.nodes.FindEnemyBehavior,
      prism.nodes.PerformOnBehavior(prism.actions.Steal),
      prism.nodes.MoveTowardTargetBehavior(1),
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
