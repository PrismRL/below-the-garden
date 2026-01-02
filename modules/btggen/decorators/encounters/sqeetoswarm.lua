local util = prism.levelgen.util

local SqeetoSwarmDecorator = prism.levelgen.Decorator:extend "SqeetoSwarmDecorator"

function SqeetoSwarmDecorator.tryDecorate(rng, builder, room)
   local candidates = {}

   for x, y in room.tiles:each() do
      if util.isWalkable(builder, x, y) then
         candidates[#candidates + 1] = { x = x, y = y }
      end
   end

   local area = #candidates
   if area == 0 then return false end

   ----------------------------------------------------------------
   -- Spawn scaling
   ----------------------------------------------------------------
   local tilesPerSqeeto = 30            -- density control
   local minCount = 1
   local maxCount = 6

   local expected = math.floor(area / tilesPerSqeeto)
   local jitter = rng:random(-1, 1)

   local count = math.max(
      minCount,
      math.min(maxCount, expected + jitter)
   )

   ----------------------------------------------------------------
   -- Shuffle candidates
   ----------------------------------------------------------------
   for i = #candidates, 2, -1 do
      local j = rng:random(1, i)
      candidates[i], candidates[j] = candidates[j], candidates[i]
   end

   for i = 1, math.min(count, #candidates) do
      local p = candidates[i]
      builder:addActor(prism.actors.Sqeeto(), p.x, p.y)
   end

   return true
end

return SqeetoSwarmDecorator
