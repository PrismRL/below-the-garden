--- @class SnipController : Controller
--- @overload fun(): SnipController
local SnipController = prism.components.Controller:extend "SnipController"

function SnipController:getRequirements()
   return prism.components.Mover
end

function SnipController:act(level, actor)
   self.blackboard = {}
   return prism.nodes.SnipTree:run(level, actor, self)
end

return SnipController
