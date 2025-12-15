--- @class ThrumbleController : Controller
local ThrumbleController = prism.components.Controller:extend("ThrumbleController")

function ThrumbleController:__new()
   self.blackboard = {}
end

function ThrumbleController:getRequirements()
   return prism.components.Mover, prism.components.Senses
end

-- if see enemy
--   if has weapon
--     navigate to enemy
--     attack enemy
--   else
--     navigate to weapon
--     equip weapon
-- else
--   wait
local BT = prism.BehaviorTree
local tree = BT.Root {
   BT.Sequence {
      prism.nodes.FindEnemyBehavior,
      BT.Selector {
         BT.Sequence {
            prism.nodes.ReturnHomeBehavior,
            prism.nodes.MoveTowardTargetBehavior,
         },
         BT.Sequence {
            prism.nodes.HasWeaponBehavior,
            prism.nodes.AttackEnemyBehavior,
            prism.nodes.MoveTowardTargetBehavior(1),
         },
         BT.Sequence {
            prism.nodes.FindWeaponBehavior,
            prism.nodes.PickupWeaponBehavior,
            prism.nodes.MoveTowardTargetBehavior,
         },
      },
   },
   BT.Sequence {
      prism.nodes.ReturnHomeBehavior(1),
      prism.nodes.MoveTowardTargetBehavior,
   },
   prism.nodes.WaitBehavior,
}

function ThrumbleController:act(level, owner)
   self.blackboard = {}
   return tree:run(level, owner, self)
end

return ThrumbleController
