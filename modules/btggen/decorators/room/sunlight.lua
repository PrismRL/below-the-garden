local util = prism.levelgen.util
local SunlightDecorator = prism.levelgen.Decorator:extend "SunlightDecorator"

function SunlightDecorator.tryDecorate(rng, builder, room)
   local radiusMin = 2
   local radiusMax = 4
   local minWallDist = 1

   local cx, cy = room.center:decompose()
   if not util.isFloor(builder, cx, cy) then return end

   local wallDistanceField = util.buildWallDistanceField(builder)
   local centerD = wallDistanceField:get(cx, cy)

   if not centerD or centerD <= radiusMin + minWallDist then return end

   local maxRadius = math.min(radiusMax, centerD - minWallDist)
   if maxRadius < radiusMin then return end

   local r = rng:random(radiusMin, maxRadius)

   -- Build grass blob
   local blob = prism.LevelBuilder()
   blob:ellipse("fill", cx, cy, r, r, prism.cells.Grass)

   for x, y in blob:each() do
      if util.isFloor(builder, x, y) then builder:set(x, y, prism.cells.Grass()) end
   end

   -- Remove nearby light-emitting actors
   local killRadius = r + radiusMax
   local killR2 = killRadius * killRadius
   local toRemove = {}

   for _, a in ipairs(builder:query(prism.components.Light):gather()) do
      local ax, ay = a:expectPosition():decompose()
      local dx = ax - cx
      local dy = ay - cy

      if dx * dx + dy * dy <= killR2 then toRemove[a] = true end
   end

   for a in pairs(toRemove) do
      builder:removeActor(a)
   end

   builder:addActor(prism.actors.Sunlight(), cx, cy)
   return true
end

return SunlightDecorator
