--- @class Light : Action
--- @overload fun(owner: Actor, ...): Light
local Light = prism.Action:extend "Ignite"
Light.targets = {}

--- @param level Level
function Light:canPerform(level) end

--- @param level Level
function Light:perform(level) end

return Light
