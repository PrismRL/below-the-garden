--- @class DescendMessage : Message
--- @field actor Actor
--- @overload fun(actor: Actor): DescendMessage
local DescendMessage = prism.Message:extend "DescendMessage"

function DescendMessage:__new(actor)
   self.actor = actor
end

return DescendMessage
