--- @class FireflyController : Controller
local FireflyController = prism.components.Controller:extend("FireflyController")

local BT = prism.BehaviorTree
local tree = prism.BehaviorTree.Root {
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

function FireflyController:act(level, owner)
   self.blackboard = {}
   return tree:run(level, owner, self)
end

return FireflyController
