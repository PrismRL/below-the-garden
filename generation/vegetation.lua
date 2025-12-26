local util = require "generation.util"
local vegetation = {}

--- Spawns TallGrass by blitting circular patches near walls.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.attempts integer?
---    opts.maxTotal integer?
---    opts.maxWallDistance integer?
---    opts.radiusMin integer?
---    opts.radiusMax integer?
function vegetation.addTallGrass(builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}

   local attempts = opts.attempts or 200
   local maxTotal = opts.maxTotal or 4
   local maxWallDistance = opts.maxWallDistance or 2
   local radiusMin = opts.radiusMin or 1
   local radiusMax = opts.radiusMax or 2

   local total = 0

   --- Attempts to place a single tall grass patch.
   --- @return integer placed
   local function tryPlace()
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if not util.isFloor(builder, x, y) then return 0 end

      local d = wallDistanceField:get(x, y)
      if not d or d > maxWallDistance then return 0 end

      if (heatmap:get(x, y) or 0) ~= 0 then return 0 end

      local r = rng:random(radiusMin, radiusMax)
      local grassBlob = prism.LevelBuilder()
      grassBlob:ellipse("fill", x, y, r, r, prism.cells.TallGrass)

      for x, y, cell in grassBlob:each() do
         if util.isFloor(builder, x, y) and (heatmap:get(x, y) or 0) < 3 then
            builder:set(x, y, prism.cells.TallGrass())
         end
      end

      return 1
   end

   for i = 1, attempts do
      if total >= maxTotal then return end

      total = total + tryPlace()
   end
end

--- Attempts to find a wall-adjacent placement by seeding far from walls.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param x integer
--- @param y integer
--- @param minSeedDistance integer
--- @return integer?, integer?
local function findGlowStalkSpot(builder, heatmap, wallDistanceField, x, y, minSeedDistance)
   if not util.isFloor(builder, x, y) then return nil end

   local d = wallDistanceField:get(x, y)
   if not d or d < minSeedDistance then return nil end

   local gx, gy = util.rollToWall(wallDistanceField, x, y)
   if not gx then
      print "FAILED TO FIND distanceField"
      return nil
   end

   print "ROLLED TO WALL"

   if (heatmap:get(gx, gy) or 0) ~= 0 then return nil end

   print "PASSED HEATMAP"

   if #builder:query():at(gx, gy):gather() ~= 0 then return nil end

   return gx, gy
end

--- Spawns GlowStalk actors by seeding far from walls and rolling toward them.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.attempts integer?
---    opts.maxTotal integer?
---    opts.minSeedDistance integer?
function vegetation.addGlowStalks(builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}
   local attempts = opts.attempts or 1000
   local maxTotal = opts.maxTotal or 30
   local minSeedDistance = opts.minSeedDistance or 3

   local total = 0

   for i = 1, attempts do
      if total >= maxTotal then return end

      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      local gx, gy = findGlowStalkSpot(builder, heatmap, wallDistanceField, x, y, minSeedDistance)

      if gx then
         builder:addActor(prism.actors.Glowstalk(), gx, gy)
         total = total + 1
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
function vegetation.addGrassPatch(builder, heatmap, wallDistanceField, rng, opts)
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

--- Randomly kills ~50% of GlowStalks that touch another GlowStalk.
--- Touching = 4-neighborhood by default.
--- @param builder LevelBuilder
--- @param rng RNG
--- @param opts table?
---    opts.diagonal boolean? -- include diagonals
function vegetation.thinTouchingGlowStalks(builder, opts)
   opts = opts or {}
   local includeDiagonal = opts.diagonal or false

   local dirs = prism.Vector2.neighborhood4
   if includeDiagonal then dirs = prism.Vector2.neighborhood8 end

   local stalks = builder:query(prism.components.Light):gather()
   if #stalks == 0 then return end

   local occupied = prism.SparseGrid() -- fast position lookup
   for _, a in ipairs(stalks) do
      local x, y = a:expectPosition():decompose()
      occupied:set(x, y, a)
   end

   local toKill = {}

   for _, a in ipairs(stalks) do
      local x, y = a:expectPosition():decompose()

      for _, d in ipairs(dirs) do
         local nx, ny = x + d.x, y + d.y
         local other = occupied:get(nx, ny)

         if other then toKill[a] = true end
      end
   end

   for actor in pairs(toKill) do
      builder:removeActor(actor)
   end
end

--- Spawns a meadow (water patch) in the most open nearby area.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.samples integer?
---    opts.radiusMin integer?
---    opts.radiusMax integer?
function vegetation.addMeadow(builder, heatmap, wallDistanceField, rng, opts)
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
end

--- Spawns a graveyard (tombstone cluster) in the most open nearby area.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
function vegetation.addGraveyard(builder, heatmap, wallDistanceField, rng, opts)
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

   local wispCount = opts.wispCount or rng:random(2, 5)
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

return vegetation
