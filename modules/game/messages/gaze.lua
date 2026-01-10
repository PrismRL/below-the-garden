--- @class GazeMessage : Message
--- @field actor Actor
--- @overload fun(actor: Actor, final?: boolean): GazeMessage
local GazeMessage = prism.Message:extend "GazeMessage"

function GazeMessage:__new(actor, final)
   self.actor = actor
   self.final = final
end

return GazeMessage
