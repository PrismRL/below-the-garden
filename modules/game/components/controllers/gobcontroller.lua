--- @class GobController : Controller
--- @overload fun(): GobController
local GobController = prism.components.Controller:extend "GobController"

function GobController:getRequirements()
   return prism.components.Senses, prism.components.Mover
end

function GobController:act(level, actor)
   self.blackboard = {}
   return prism.nodes.GobTree:run(level, actor, self)
end

return GobController
