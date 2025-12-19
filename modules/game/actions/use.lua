--- @class Use : Action
--- @overload fun(owner: Actor, ...): Use
local Use = prism.Action:extend "Use"
Use.targets = {}

--- @param level Level
function Use:canPerform(level) end

--- @param level Level
function Use:perform(level) end

return Use
