--- @class EyeController : Controller
--- @overload fun(): EyeController
local EyeController = prism.components.Controller:extend "EyeController"

function EyeController:act(level, actor)
   self.blackboard = {}
   return prism.nodes.EyeTree:run(level, actor, self)
end

return EyeController
