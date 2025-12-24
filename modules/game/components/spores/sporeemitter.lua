--- @class SporeEmitter : Component
--- @overload fun(): SporeEmitter
local SporeEmitter = prism.Component:extend "SporeEmitter"

function SporeEmitter:__new(sporeTime, waitTime)
   self.sporeTime = sporeTime
   self.waitTime = waitTime
end

return SporeEmitter