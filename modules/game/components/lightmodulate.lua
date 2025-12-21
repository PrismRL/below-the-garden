--- @class LightModulate : Component
--- @overload fun(lights: table, max: integer): LightModulate
local LightModulate = prism.Component:extend "LightModulate"

function LightModulate:getRequirements()
   return prism.components.Light, prism.components.ConditionHolder
end

function LightModulate:__new(lights, max)
   self.lights = lights
   self.max = max
   self.timer = 0
end

return LightModulate
