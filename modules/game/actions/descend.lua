local DescendTarget = prism.Target(prism.components.Stair):range(1)

---@class Descend : Action
---@overload fun(owner: Actor, stairs: Actor): Descend
local Descend = prism.Action:extend("Descend")
Descend.targets = { DescendTarget }

function Descend:perform(level)
   level:removeActor(self.owner)
   level:yield(prism.messages.DescendMessage(self.owner))
end

return Descend
