--- @class SqeetoController : Controller
local SqeetoController = prism.components.Controller:extend("SqeetoController")

local BT = prism.BehaviorTree
local tree = prism.BehaviorTree.Root {
   BT.Sequence {
      prism.nodes.FindLightBehavior,
      BT.Selector {
         BT.Sequence {
            prism.nodes.RandomCheckBehavior(0.3),
            prism.nodes.AttackEnemyBehavior,
         },
         prism.nodes.MoveTowardTargetBehavior(1),
      },
   },
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

function SqeetoController:act(level, owner)
   self.blackboard = {}
   return tree:run(level, owner, self)
end

return SqeetoController
