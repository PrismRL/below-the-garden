local util = require "generation.util"
local features = {}

--- Spawns a meadow (water patch) in the most open nearby area.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.samples integer?
---    opts.radiusMin integer?
---    opts.radiusMax integer?
function features.addMeadow(rooms, builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}

   local samples = opts.samples or 40
   local radiusMin = opts.radiusMin or 2
   local radiusMax = opts.radiusMax or 4

   local bestX, bestY
   local bestD = -math.huge

   for i = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isFloor(builder, x, y) then
         local rx, ry = util.rollAwayFromWall(wallDistanceField, x, y)
         local d = wallDistanceField:get(rx, ry)

         if d and d > bestD and d > radiusMin + 1 then
            bestD = d
            bestX, bestY = rx, ry
         end
      end
   end

   if not bestX then return end

   local r = rng:random(radiusMin, math.min(radiusMax, bestD - 4))

   local blob = prism.LevelBuilder()
   blob:ellipse("fill", bestX, bestY, r, r, prism.cells.Water)

   for x, y in blob:each() do
      if util.isFloor(builder, x, y) then builder:set(x, y, prism.cells.Water()) end
   end

   -- Spawn fireflies in the meadow
   local count = rng:random(4, 7)

   for i = 1, count do
      local x = bestX + rng:random(-bestD, bestD)
      local y = bestY + rng:random(-bestD, bestD)

      if builder:get(x, y) == prism.cells.Water or util.isFloor(builder, x, y) then
         builder:addActor(prism.actors.Firefly(), x, y)
      end
   end

   --------------------------------------------------------------------------
   -- Tall grass inside the meadow (reeds / marsh grass)
   --------------------------------------------------------------------------

   local innerCount = rng:random(6, 10)

   for i = 1, innerCount do
      local gx = bestX + rng:random(-r, r)
      local gy = bestY + rng:random(-r, r)

      -- stay roughly inside the ellipse
      local dx = gx - bestX
      local dy = gy - bestY
      if (dx * dx + dy * dy) <= (r * r) then
         if builder:get(gx, gy) == prism.cells.Water then builder:set(gx, gy, prism.cells.TallGrass()) end
      end
   end

   --------------------------------------------------------------------------
   -- Tall grass tufts just outside the meadow
   --------------------------------------------------------------------------

   local outerCount = rng:random(4, 7)
   local outerMin = r + 1
   local outerMax = r + 3

   for i = 1, outerCount do
      local angle = rng:random() * math.pi * 2
      local dist = rng:random(outerMin, outerMax)

      local gx = math.floor(bestX + math.cos(angle) * dist + 0.5)
      local gy = math.floor(bestY + math.sin(angle) * dist + 0.5)

      if util.isFloor(builder, gx, gy) then builder:set(gx, gy, prism.cells.TallGrass()) end
   end
end

--- Spawns a graveyard (tombstone cluster) in the most open nearby area.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
function features.addGraveyard(rooms, builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}

   local samples = opts.samples or 40
   local countMin = opts.countMin or 4
   local countMax = opts.countMax or 8
   local minWallDist = opts.minWallDist or 3
   local radiusMin = opts.radiusMin or 2
   local radiusMax = opts.radiusMax or 4

   --------------------------------------------------------------------------
   -- Choose location (identical logic to grass patch)
   --------------------------------------------------------------------------

   local bestX, bestY
   local bestD = -math.huge

   for i = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isFloor(builder, x, y) then
         local rx, ry = util.rollAwayFromWall(wallDistanceField, x, y)
         local d = wallDistanceField:get(rx, ry)

         if d and d > bestD then
            bestD = d
            bestX, bestY = rx, ry
         end
      end
   end

   if not bestX then return end

   --------------------------------------------------------------------------
   -- Spawn tombstones
   --------------------------------------------------------------------------

   local count = rng:random(countMin, countMax)
   local radius = rng:random(radiusMin, math.min(radiusMax, bestD - minWallDist))

   print(radiusMin, radius)

   local placed = {}
   local attempts = count * 30

   for i = 1, attempts do
      print "ATTEMPT"
      if #placed >= count then break end

      local angle = rng:random() * math.pi * 2
      local dist = rng:random(radiusMin, radius)

      local x = math.floor(bestX + math.cos(angle) * dist + 0.5)
      local y = math.floor(bestY + math.sin(angle) * dist + 0.5)

      if util.isFloor(builder, x, y) then
         local wallD = wallDistanceField:get(x, y)

         if wallD and wallD >= minWallDist then
            -- Avoid placing stones too close to each other
            local ok = true
            for _, p in ipairs(placed) do
               local dx = x - p.x
               local dy = y - p.y
               if math.sqrt(dx * dx + dy * dy) < 2 then
                  ok = false
                  break
               end
            end

            if ok then
               print "SUCCESS"
               builder:addActor(prism.actors.Tombstone(), x, y)
               table.insert(placed, { x = x, y = y })
            end
         end
      end
   end

   local REMOVE_RADIUS = radius + 3
   local REMOVE_RADIUS_SQ = REMOVE_RADIUS * REMOVE_RADIUS

   for _, sp in ipairs(builder:query(prism.components.Spawner):gather()) do
      local sx, sy = sp:expectPosition():decompose()

      local dx = sx - bestX
      local dy = sy - bestY

      print("TRYING TO REMOVE")
      if dx * dx + dy * dy <= REMOVE_RADIUS_SQ then builder:removeActor(sp) end
   end

   local wispCount = opts.wispCount or rng:random(3, 4)
   local wispTries = opts.wispTries or 30

   for i = 1, wispTries do
      if wispCount <= 0 then break end

      local x = rng:random(math.max(2, bestX - radiusMax), math.min(LEVELGENBOUNDSX - 1, bestX + radiusMax))
      local y = rng:random(math.max(2, bestY - radiusMax), math.min(LEVELGENBOUNDSY - 1, bestY + radiusMax))

      if util.isFloor(builder, x, y) then
         builder:addActor(prism.actors.Wisp(), x, y)
         wispCount = wispCount - 1
      end
   end
end

--- Spawns a tall grass patch in the most open nearby area.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.samples integer?
---    opts.radiusMin integer?
---    opts.radiusMax integer?
function features.addGrassPatch(rooms, builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}

   local samples = opts.samples or 40
   local radiusMin = opts.radiusMin or 2
   local radiusMax = opts.radiusMax or 4

   local bestX, bestY
   local bestD = -math.huge

   for i = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isFloor(builder, x, y) then
         local rx, ry = util.rollAwayFromWall(wallDistanceField, x, y)
         local d = wallDistanceField:get(rx, ry)

         if d and d > bestD then
            bestD = d
            bestX, bestY = rx, ry
         end
      end
   end

   if not bestX then return end

   local r = rng:random(radiusMin, math.min(radiusMax, bestD - 3))

   local blob = prism.LevelBuilder()
   blob:ellipse("fill", bestX, bestY, r, r, prism.cells.Grass)

   for x, y in blob:each() do
      if util.isFloor(builder, x, y) then builder:set(x, y, prism.cells.Grass()) end
   end

   -- Remove nearby light-emitting entities
   local killRadius = r + radiusMax
   local killR2 = killRadius * killRadius

   local toRemove = {}

   for x = bestX - killRadius, bestX + killRadius do
      for y = bestY - killRadius, bestY + killRadius do
         local dx = x - bestX
         local dy = y - bestY

         if dx * dx + dy * dy <= killR2 then
            for _, a in ipairs(builder:query(prism.components.Light):at(x, y):gather()) do
               toRemove[a] = true
            end
         end
      end
   end

   for a in pairs(toRemove) do
      builder:removeActor(a)
   end

   builder:addActor(prism.actors.Sunlight(), bestX, bestY)
end

--- @param rooms table
---@param builder LevelBuilder
---@param heatmap any
---@param wallDistanceField any
---@param rng RNG
---@param opts any
function features.addPit(rooms, builder, heatmap, wallDistanceField, rng, opts)
   local room
   for i = 1, #rooms do
      room = rooms[i]
      local ncount = 0
      for _ in pairs(room.neighbors) do
         ncount = ncount + 1
      end

      if room.size > 25 and room.size < 64 and wallDistanceField:get(room.center:decompose()) > 3 then break end
   end

   if not room then return end

   for x, y in room.tiles:each() do
      builder:set(x, y, prism.cells.Pit())
   end

   for neighbor in pairs(room.neighbors) do
      local existingPath = prism.astar(neighbor.center, room.center, function(x, y)
         return util.isFloor(builder, x, y)
      end)

      local path = prism.astar(neighbor.center, room.center, function(x, y)
         return not util.isWall(builder, x, y)
      end, nil, nil, "4way", prism.Vector2.neighborhood4)

      if (not existingPath or existingPath:getTotalCost() > 16) and path then
         for _, vec in ipairs(path:getPath()) do
            if room.tiles:get(vec.x, vec.y) then builder:set(vec.x, vec.y, prism.cells.Bridge()) end
         end
      end
   end

   local radiusx = rng:random(0, wallDistanceField:get(room.center:decompose()) - 2)
   local radiusy = math.max(0, rng:random(-1, 1) + radiusx)

   if radiusx ~= 0 or radiusy ~= 0 then
      prism.Ellipse("fill", room.center, radiusx, radiusy, function(x, y)
         if room.tiles:get(x, y) then builder:set(x, y, prism.cells.Floor()) end
      end)
   end
end

--- @param rooms table
---@param builder LevelBuilder
---@param heatmap any
---@param wallDistanceField any
---@param rng RNG
---@param opts any
function features.addWaterPit(rooms, builder, heatmap, wallDistanceField, rng, opts)
   local room
   for i = 1, #rooms do
      room = rooms[i]
      local ncount = 0
      for _ in pairs(room.neighbors) do
         ncount = ncount + 1
      end

      if room.size > 25 and room.size < 64 and wallDistanceField:get(room.center:decompose()) > 3 then break end
   end

   if not room then return end

   for x, y in room.tiles:each() do
      builder:set(x, y, prism.cells.Water())
   end

   for neighbor in pairs(room.neighbors) do
      local existingPath = prism.astar(neighbor.center, room.center, function(x, y)
         return util.isFloor(builder, x, y)
      end)

      local path = prism.astar(neighbor.center, room.center, function(x, y)
         return not util.isWall(builder, x, y)
      end, nil, nil, "4way", prism.Vector2.neighborhood4)

      if (not existingPath or existingPath:getTotalCost() > 16) and path then
         for _, vec in ipairs(path:getPath()) do
            if room.tiles:get(vec.x, vec.y) then builder:set(vec.x, vec.y, prism.cells.Bridge()) end
         end
      end
   end

   local radiusx = rng:random(0, wallDistanceField:get(room.center:decompose()) - 2)
   local radiusy = math.max(0, rng:random(-1, 1) + radiusx)

   if radiusx ~= 0 or radiusy ~= 0 then
      prism.Ellipse("fill", room.center, radiusx, radiusy, function(x, y)
         if room.tiles:get(x, y) then builder:set(x, y, prism.cells.Floor()) end
      end)
   end
end

--- @param rooms table
---@param builder LevelBuilder
---@param heatmap any
---@param wallDistanceField any
---@param rng RNG
---@param opts any
function features.addTallGrassClearing(rooms, builder, heatmap, wallDistanceField, rng, opts)
   local room
   for i = 1, #rooms do
      room = rooms[i]
      local ncount = 0
      for _ in pairs(room.neighbors) do
         ncount = ncount + 1
      end

      if room.size > 25 and room.size < 64 and wallDistanceField:get(room.center:decompose()) > 3 then break end
   end

   if not room then return end

   for x, y in room.tiles:each() do
      builder:set(x, y, prism.cells.TallGrass())
   end

   for neighbor in pairs(room.neighbors) do
      local existingPath = prism.astar(neighbor.center, room.center, function(x, y)
         return util.isFloor(builder, x, y)
      end)

      local path = prism.astar(neighbor.center, room.center, function(x, y)
         return not util.isWall(builder, x, y)
      end, nil, nil, "4way", prism.Vector2.neighborhood4)

      if (not existingPath or existingPath:getTotalCost() > 16) and path then
         for _, vec in ipairs(path:getPath()) do
            if room.tiles:get(vec.x, vec.y) then builder:set(vec.x, vec.y, prism.cells.Floor()) end
         end
      end
   end

   local radiusx = rng:random(0, wallDistanceField:get(room.center:decompose()) - 2)
   local radiusy = math.max(0, rng:random(-1, 1) + radiusx)

   if radiusx ~= 0 or radiusy ~= 0 then
      prism.Ellipse("fill", room.center, radiusx, radiusy, function(x, y)
         if room.tiles:get(x, y) then builder:set(x, y, prism.cells.Floor()) end
      end)
   end
end

return features
