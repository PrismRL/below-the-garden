--- @class Teleport : Action
--- @overload fun(owner: Actor, ...): Teleport
local Teleport = prism.Action:extend "Teleport"
Teleport.targets = { prism.Target():isActor() }

--- @param level Level
function Teleport:perform(level, actor) end

return Teleport
