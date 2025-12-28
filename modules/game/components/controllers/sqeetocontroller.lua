--- @class SqeetoController : Controller
local SqeetoController = prism.components.Controller:extend("SqeetoController")

function SqeetoController:act(level, owner)
   self.blackboard = {}
   return prism.nodes.SqeetoTree:run(level, owner, self)
end

return SqeetoController
