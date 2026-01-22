--- @class ThrumbleTree : BehaviorTree.Root
local ThrumbleTree = prism.BehaviorTree.Root:extend "ThrumbleTree"

local BT = prism.BehaviorTree

ThrumbleTree.children = {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior(true, nil, 4),
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
   BT.Sequence {
      BT.Node(function(self, level, actor)
         local log = actor:getRelation(prism.relations.Home)
         if not log then return false end
         return not log:has(prism.components.Lit)
      end),
      BT.Node(function(self, level, actor, controller)
         local home = actor:getRelation(prism.relations.Home)
         if not home then return false end
         local ignite = prism.actions.Ignite(actor, home)
         if level:canPerform(ignite) then return ignite end
         return false
      end),
      prism.nodes.ReturnHomeBehavior(1),
      prism.nodes.MoveTowardTargetBehavior,
   },
   prism.nodes.WaitBehavior,
}

return ThrumbleTree
