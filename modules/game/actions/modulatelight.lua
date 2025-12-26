--- @class ModulateLight : Action
--- @overload fun(owner: Actor, ...): ModulateLight
local ModulateLight = prism.Action:extend "ModulateLight"
ModulateLight.requiredComponents = { prism.components.LightModulate }

-- Tuneable spatial frequency for noise sampling
local NOISE_SCALE = 0.15

--- @param level Level
function ModulateLight:perform(level)
   local owner = self.owner
   local modulate = owner:expect(prism.components.LightModulate)

   -- Advance base timer
   modulate.timer = modulate.timer + 1
   if modulate.timer >= modulate.max then modulate.timer = 0 end

   -- Spatial noise offset
   local pos = owner:expectPosition()
   local nx, ny = pos:decompose()

   -- noise ∈ [0,1) → integer offset ∈ [0, max-1]
   local n = love.math.noise(nx * NOISE_SCALE, ny * NOISE_SCALE)
   local offset = math.floor(n * modulate.max)

   -- Final phase (Lua 1-based tables)
   local phase = (modulate.timer + offset) % modulate.max

   local light = modulate.lights[phase]
   if light then owner:give(light) end
end

return ModulateLight
