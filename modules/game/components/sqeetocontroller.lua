--- @class SqeetoController : Controller
local SqeetoController = prism.components.Controller:extend("SqeetoController")

local tree = prism.BehaviorTree.Root {
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

function SqeetoController:act(level, owner)
   return tree:run(level, owner, self)
end

return SqeetoController
