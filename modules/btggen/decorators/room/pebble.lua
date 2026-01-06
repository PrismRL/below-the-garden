local util = prism.levelgen.util

local PebbleDecorator = prism.levelgen.Decorator:extend "PebbleDecorator"

function PebbleDecorator.tryDecorate(rng, builder, room)
   if not room.size or room.size < 16 then return end

   local candidates = {}

   for x, y in room.tiles:each() do
      if util.isWalkable(builder, x, y) then candidates[#candidates + 1] = { x = x, y = y } end
   end

   if #candidates == 0 then return end

   for i = #candidates, 2, -1 do
      local j = rng:random(1, i)
      candidates[i], candidates[j] = candidates[j], candidates[i]
   end

   local count = rng:random(1, 2)

   if count > 2 then
      local p = candidates[1]
      builder:addActor(prism.actors.Pebble(), p.x, p.y)
      return true
   end
end

return PebbleDecorator
