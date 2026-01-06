--- @class FallSystem : System
local FallSystem = prism.System:extend "FallSystem"

function FallSystem:onMove(level, actor)
   level:tryPerform(prism.actions.Fall(actor))
end

function FallSystem:onActorAdded(level, actor)
   level:tryPerform(prism.actions.Fall(actor))
end

function FallSystem:onComponentAdded(level, actor)
   level:tryPerform(prism.actions.Fall(actor))
end

function FallSystem:onComponentRemoved(level, actor)
   level:tryPerform(prism.actions.Fall(actor))
end

return FallSystem
