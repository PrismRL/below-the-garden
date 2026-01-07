--- @class PoofController : Controller
--- @overload fun(): PoofController
local PoofController = prism.components.Controller:extend "PoofController"

function PoofController:getRequirements()
   return prism.components.Mover
end

function PoofController:act(level, actor)
   self.blackboard = {}
   return prism.nodes.PoofTree:run(level, actor, self)
end

return PoofController
