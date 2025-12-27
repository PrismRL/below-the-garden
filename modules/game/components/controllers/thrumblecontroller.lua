--- @class ThrumbleController : Controller
local ThrumbleController = prism.components.Controller:extend("ThrumbleController")

function ThrumbleController:__new()
   self.blackboard = {}
end

function ThrumbleController:getRequirements()
   return prism.components.Mover, prism.components.Senses
end

function ThrumbleController:act(level, owner)
   self.blackboard["previous"] = self.blackboard["target"]
   self.blackboard["target"] = nil
   return prism.nodes.ThrumbleTree:run(level, owner, self)
end

return ThrumbleController
