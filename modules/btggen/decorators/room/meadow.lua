local util = prism.levelgen.util
local MeadowDecorator = prism.levelgen.Decorator:extend "MeadowDecorator"

function MeadowDecorator.tryDecorate(rng, builder, room)
   local radiusMin = 2
   local outerPad = rng:random(2, 3)

   local cx, cy = room.center:decompose()
   if not util.isFloor(builder, cx, cy) then return end

   local wallDistanceField = util.buildWallDistanceField(builder)

   local centerD = wallDistanceField:get(cx, cy)
   local maxRadius = centerD - outerPad - 2
   if maxRadius < radiusMin then return end

   local r = rng:random(radiusMin, maxRadius)

   local blob = prism.LevelBuilder()
   blob:ellipse("fill", cx, cy, r, r, prism.cells.Water)

   for x, y in blob:each() do
      if util.isFloor(builder, x, y) then builder:set(x, y, prism.cells.Water()) end
   end

   local fireflyCount = rng:random(4, 7)
   for i = 1, fireflyCount do
      local x = cx + rng:random(-centerD, centerD)
      local y = cy + rng:random(-centerD, centerD)

      local cell = builder:get(x, y)
      if cell == prism.cells.Water or util.isFloor(builder, x, y) then
         builder:addActor(prism.actors.Firefly(), x, y)
      end
   end

   local innerCount = rng:random(6, 10)
   local r2 = r * r

   for i = 1, innerCount do
      local gx = cx + rng:random(-r, r)
      local gy = cy + rng:random(-r, r)

      local dx = gx - cx
      local dy = gy - cy
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

      local gx = math.floor(cx + math.cos(angle) * dist + 0.5)
      local gy = math.floor(cy + math.sin(angle) * dist + 0.5)

      if util.isFloor(builder, gx, gy) then builder:set(gx, gy, prism.cells.TallGrass()) end
   end

   return true
end

return MeadowDecorator
