--- @class Throw : Action
--- @overload fun(owner: Actor, ...): Throw
local Throw = prism.Action:extend "Throw"
Throw.targets = {}

--- @param level Level
function Throw:canPerform(level) end

--- @param level Level
function Throw:perform(level) end

return Throw
