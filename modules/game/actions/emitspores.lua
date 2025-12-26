--- @class EmitSpores : Action
local EmitSpores = prism.Action:extend "EmitSpores"

--- @param level Level
function EmitSpores:canPerform(level, actor)
   local emitter = actor:expect(prism.components.SporeEmitter)
end

--- @param level Level
function EmitSpores:perform(level, actor) end

return EmitSpores
