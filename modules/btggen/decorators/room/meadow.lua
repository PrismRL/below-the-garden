local util = prism.levelgen.util
local MeadowDecorator = prism.levelgen.Decorator:extend "MeadowDecorator"

function MeadowDecorator.tryDecorate(rng, builder, room)
   local radiusMin = 2
   local outerPad = 3

   local cx, cy = room.center:decompose()
   if not util.isFloor(builder, cx, cy) then return end

   local wallDistanceField = util.buildWallDistanceField(builder)

   -- roll uphill from center to avoid edge bias
   local mx, my = util.rollUphill(wallDistanceField, cx, cy)
   local centerD = wallDistanceField:get(mx, my)
   if not centerD or centerD <= radiusMin + 1 then return end

   local maxRadius = centerD - 3
   if maxRadius < radiusMin then return end

   local r = rng:random(radiusMin, maxRadius)

   local blob = prism.LevelBuilder()
   blob:ellipse("fill", mx, my, r, r, prism.cells.Water)

   for x, y in blob:each() do
      if util.isFloor(builder, x, y) then builder:set(x, y, prism.cells.Water()) end
   end

   local fireflyCount = rng:random(4, 7)
   for i = 1, fireflyCount do
      local x = mx + rng:random(-centerD, centerD)
      local y = my + rng:random(-centerD, centerD)

      local cell = builder:get(x, y)
      if cell == prism.cells.Water or util.isFloor(builder, x, y) then
         builder:addActor(prism.actors.Firefly(), x, y)
      end
   end

   local innerCount = rng:random(6, 10)
   local r2 = r * r

   for i = 1, innerCount do
      local gx = mx + rng:random(-r, r)
      local gy = my + rng:random(-r, r)

      local dx = gx - mx
      local dy = gy - my
      if (dx * dx + dy * dy) <= r2 then
         if builder:get(gx, gy) == prism.cells.Water then builder:set(gx, gy, prism.cells.TallGrass()) end
      end
   end

   local outerCount = rng:random(4, 7)
   local outerMin = r + 1
   local outerMax = r + outerPad

   for i = 1, outerCount do
      local angle = rng:random() * math.pi * 2
      local dist = rng:random(outerMin, outerMax)

      local gx = math.floor(mx + math.cos(angle) * dist + 0.5)
      local gy = math.floor(my + math.sin(angle) * dist + 0.5)

      if util.isFloor(builder, gx, gy) then builder:set(gx, gy, prism.cells.TallGrass()) end
   end

   return true
end

return MeadowDecorator
