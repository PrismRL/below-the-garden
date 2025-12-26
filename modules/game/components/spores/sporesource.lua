--- @class SporeSource : Component
--- @overload fun(): SporeSource
local SporeSource = prism.Component:extend "SporeSource"

function SporeSource:__new(size, fadeTime)
   self.size = size
   self.fadeTime = fadeTime
end

return SporeSource
