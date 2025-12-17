--- @class ThrumbleController : Controller
local ThrumbleController = prism.components.Controller:extend("ThrumbleController")

function ThrumbleController:__new()
   self.blackboard = {}
end

function ThrumbleController:getRequirements()
   return prism.components.Mover, prism.components.Senses
end

function ThrumbleController:act(level, owner)
   self.blackboard = {}
   return prism.nodes.ThrumbleTree:run(level, owner, self)
end

return ThrumbleController
