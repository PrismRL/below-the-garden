--- @class Win : Action
--- @overload fun(owner: Actor, ...): Win
local Win = prism.Action:extend "Win"
Win.name = "gaze"
Win.requiredComponents = { prism.components.PlayerController }
Win.targets = { prism.Target(prism.components.Crystal):range(1) }

--- @param level Level
function Win:canPerform(level, crystal)
   return true
end

--- @param level Level
function Win:perform(level, crystal)
   level:yield(prism.messages.GazeMessage(self.owner, true))
end

return Win
