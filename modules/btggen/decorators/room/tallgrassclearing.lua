local util = prism.levelgen.util
local TallGrassClearingDecorator = prism.levelgen.Decorator:extend "TallGrassClearingDecorator"

function TallGrassClearingDecorator.tryDecorate(rng, builder, room)
   local minRoomSize = 25
   local minWallDist = 2

   -- Noise params
   local noiseScale  = 0.08
   local noiseCutoff = 0.55
   local centerBias  = 0.6

   if not room.size or room.size <= minRoomSize then return end

   -- Compute geometric centroid from tiles
   local sumx, sumy, count = 0, 0, 0
   for x, y in room.tiles:each() do
      sumx = sumx + x
      sumy = sumy + y
      count = count + 1
   end

   if count == 0 then return end

   local cx = math.floor(sumx / count)
   local cy = math.floor(sumy / count)

   local wallDistanceField = util.buildWallDistanceField(builder)
   local centerD = wallDistanceField:get(cx, cy)

   if not centerD or centerD <= minWallDist then return end

   -- Per-room noise offset
   local ox = rng:random(0, 10000)
   local oy = rng:random(0, 10000)

   -- Fill room with tall grass
   for x, y in room.tiles:each() do
      builder:set(x, y, prism.cells.TallGrass())
   end

   -- Noise-based clearing
   for x, y in room.tiles:each() do
      local d = wallDistanceField:get(x, y)
      if d and d > minWallDist then
         local dx, dy = x - cx, y - cy
         local dist = math.sqrt(dx * dx + dy * dy)
         local norm = math.max(0, 1 - dist / (centerD + 1))

         local n = love.math.noise(
            (x + ox) * noiseScale,
            (y + oy) * noiseScale
         )

         local value = n + norm * centerBias

         if value > noiseCutoff then
            builder:set(x, y, prism.cells.Floor())
         end
      end
   end

   -- Ensure connectivity to neighbors
   for neighbor in pairs(room.neighbors) do
      local path = prism.astar(
         neighbor.center,
         prism.Vector2(cx, cy),
         function(x, y)
            return util.isFloor(builder, x, y)
         end,
         function(x, y)
            return builder:get(x, y):has(prism.components.Opaque) and 1.5 or 1
         end,
         nil,
         nil,
         prism.Vector2.neighborhood4
      )

      if path then
         for _, vec in ipairs(path:getPath()) do
            if room.tiles:get(vec.x, vec.y) then
               builder:set(vec.x, vec.y, prism.cells.Floor())
            end
         end
      end
   end

   return true
end

return TallGrassClearingDecorator
