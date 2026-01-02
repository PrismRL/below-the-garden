local util = prism.levelgen.util
local GraveyardDecorator = prism.levelgen.Decorator:extend "GraveyardDecorator"

function GraveyardDecorator.tryDecorate(rng, builder, room)
   local countMin = 4
   local countMax = 8
   local minWallDist = 3
   local radiusMin = 2
   local radiusMax = 4

   local cx, cy = room.center:decompose()
   if not util.isFloor(builder, cx, cy) then return end

   local wallDistanceField = util.buildWallDistanceField(builder)
   local centerD = wallDistanceField:get(cx, cy)
   if not centerD or centerD <= radiusMin + 1 then return end

   local maxRadius = math.min(radiusMax, centerD - minWallDist)
   if maxRadius < radiusMin then return end

   local radius = rng:random(radiusMin, maxRadius)

   local targetCount = rng:random(countMin, countMax)
   local placed = {}
   local attempts = targetCount * 20
   local minSpacingSq = 4

   for i = 1, attempts do
      if #placed >= targetCount then break end

      local angle = rng:random() * math.pi * 2
      local dist = rng:random(radiusMin, radius)

      local x = math.floor(cx + math.cos(angle) * dist + 0.5)
      local y = math.floor(cy + math.sin(angle) * dist + 0.5)

      if util.isFloor(builder, x, y) then
         local d = wallDistanceField:get(x, y)
         if d and d >= minWallDist then
            local ok = true
            for _, p in ipairs(placed) do
               local dx = x - p.x
               local dy = y - p.y
               if dx * dx + dy * dy < minSpacingSq then
                  ok = false
                  break
               end
            end

            if ok then
               builder:addActor(prism.actors.Tombstone(), x, y)
               placed[#placed + 1] = { x = x, y = y }
            end
         end
      end
   end

   local clearRadius = radius + 3
   local clearRadiusSq = clearRadius * clearRadius

   for _, sp in ipairs(builder:query(prism.components.Spawner):gather()) do
      local sx, sy = sp:expectPosition():decompose()
      local dx = sx - cx
      local dy = sy - cy

      if dx * dx + dy * dy <= clearRadiusSq then builder:removeActor(sp) end
   end

   local wispCount = rng:random(3, 4)
   local wispTries = 30

   for i = 1, wispTries do
      if wispCount <= 0 then break end

      local x = rng:random(cx - radius, cx + radius)
      local y = rng:random(cy - radius, cy + radius)

      if util.isFloor(builder, x, y) then
         builder:addActor(prism.actors.Wisp(), x, y)
         wispCount = wispCount - 1
      end
   end

   return true
end

return GraveyardDecorator
