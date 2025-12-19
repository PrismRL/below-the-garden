--- @class FrogController : Controller
--- @overload fun(): FrogController
local FrogController = prism.components.Controller:extend "FrogController"

function FrogController:getRequirements()
   return prism.components.Senses, prism.components.Mover
end

function FrogController:act(level, actor)
   self.blackboard = {}
   return prism.nodes.FrogTree:run(level, actor, self)
end

return FrogController
