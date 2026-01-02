local util = prism.levelgen.util

local ThrumbleCampDecorator =
   prism.levelgen.Decorator:extend "ThrumbleCampDecorator"

local MIN_WALL_DIST = 3

function ThrumbleCampDecorator.tryDecorate(rng, builder, room)
   if not room then
      return false
   end

   local player = builder:query(prism.components.PlayerController):first()
   if not player then
      return false
   end

   local wallDistanceField = util.buildWallDistanceField(builder)

   local bestX, bestY
   local bestDist = -math.huge

   for x, y in room.tiles:each() do
      if util.isEmptyFloor(builder, x, y) then
         local d = wallDistanceField:get(x, y)
         if d and d > bestDist then
            bestDist = d
            bestX, bestY = x, y
         end
      end
   end

   if not bestX then
      return false
   end

   if bestDist < MIN_WALL_DIST then
      return false
   end

   local cx, cy = bestX, bestY

   local astar = prism.astar(
      player:expectPosition(),
      prism.Vector2(cx, cy),
      function(x, y)
         return util.isFloor(builder, x, y)
      end
   )

   if not astar then
      return false
   end

   for dx = -1, 1 do
      for dy = -1, 1 do
         local x = cx + dx
         local y = cy + dy
         if not util.isFloor(builder, x, y) then
            builder:set(x, y, prism.cells.Floor())
         end

         if util.isOpaque(builder, x, y) then
            builder:set(x, y, prism.cells.Grass())
         end
      end
   end

   builder:addActor(prism.actors.Fire(), cx, cy)
   builder:addActor(prism.actors.Log(), cx, cy + 1)

   local thrumbleSpots = {}

   for dx = -1, 1 do
      for dy = -1, 1 do
         if not (dx == 0 and dy == 0) then
            local x = cx + dx
            local y = cy + dy
            if util.isEmptyFloor(builder, x, y) then
               thrumbleSpots[#thrumbleSpots + 1] = { x = x, y = y }
            end
         end
      end
   end

   if #thrumbleSpots < 2 then
      return false
   end

   for i = #thrumbleSpots, 2, -1 do
      local j = rng:random(1, i)
      thrumbleSpots[i], thrumbleSpots[j] = thrumbleSpots[j], thrumbleSpots[i]
   end

   local numThrumbles = math.min(#thrumbleSpots, rng:random(2, 3))
   for i = 1, numThrumbles do
      local p = thrumbleSpots[i]
      builder:addActor(prism.actors.Thrumble(), p.x, p.y)
   end

   local lootSpots = {}

   for dx = -3, 3 do
      for dy = -3, 3 do
         if (dx * dx + dy * dy <= 4)
            and not (math.abs(dx) <= 1 and math.abs(dy) <= 1)
         then
            local x = cx + dx
            local y = cy + dy
            if util.isEmptyFloor(builder, x, y) then
               lootSpots[#lootSpots + 1] = { x = x, y = y }
            end
         end
      end
   end

   if #lootSpots == 0 then
      return true
   end

   for i = #lootSpots, 2, -1 do
      local j = rng:random(1, i)
      lootSpots[i], lootSpots[j] = lootSpots[j], lootSpots[i]
   end

   local numLoot = math.min(#lootSpots, rng:random(2, 3))
   builder:addActor(prism.actors.Torch(), lootSpots[1].x, lootSpots[1].y)
   for i = 2, numLoot do
      local p = lootSpots[i]
      builder:addActor(prism.actors.Sword(), p.x, p.y)
   end

   return true
end

return ThrumbleCampDecorator
