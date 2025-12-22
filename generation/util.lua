local util = {}

--- @param builder LevelBuilder
---@param x integer
---@param y integer
function util.isWall(builder, x, y)
   if not builder:get(x, y) then return true end
   if builder:get(x, y):getCollisionMask() == 0 then return true end

   return false
end

local walkmask = prism.Collision.createBitmaskFromMovetypes{"walk"}

function util.isWalkable(builder, x, y, mask)
   if not builder:get(x, y) then return false end

   mask = mask or walkmask
   if prism.Collision.checkBitmaskOverlap(mask, builder:get(x, y):getCollisionMask()) then return true end
   return false
end

--- @param builder LevelBuilder
---@param x integer
---@param y integer
function util.isOpaque(builder, x, y)
   return builder:get(x, y) and builder:get(x, y):get(prism.components.Opaque) ~= nil
end

function util.is()
   
end
--- @param builder LevelBuilder
---@param x integer
---@param y integer
function util.isFloor(builder, x, y)
   return util.isWalkable(builder, x, y) and not util.isOpaque(builder, x, y)
end

function util.isEmptyFloor(builder, x, y)
 return util.isFloor(builder, x, y) and #builder:query():get(x, y):gather() == 0
end

function util.rollToWall(distanceField, x, y)
   local bestX, bestY = x, y
   local bestD = distanceField:get(x, y)

   if not bestD then
      return nil
   end

   while bestD > 1 do
      local nextX, nextY
      local nextD = bestD

      for _, d in ipairs(prism.Vector2.neighborhood8) do
         local nx, ny = bestX + d.x, bestY + d.y
         local nd = distanceField:get(nx, ny)

         if nd and nd < nextD then
            nextX, nextY = nx, ny
            nextD = nd
         end
      end

      -- no downhill step found → stuck
      if not nextX then
         break
      end

      bestX, bestY, bestD = nextX, nextY, nextD
   end

   if bestD == 1 then
      return bestX, bestY
   end

   return nil
end

--- Rolls uphill in a distance field, away from walls.
--- Stops at a local maximum.
--- @param distanceField SparseGrid
--- @param x integer
--- @param y integer
--- @return integer?, integer?
function util.rollAwayFromWall(distanceField, x, y)
   local bestX, bestY = x, y
   local bestD = distanceField:get(x, y)

   if not bestD then
      return nil
   end

   while true do
      local nextX, nextY
      local nextD = bestD

      for _, d in ipairs(prism.Vector2.neighborhood8) do
         local nx, ny = bestX + d.x, bestY + d.y
         local nd = distanceField:get(nx, ny)

         if nd and nd > nextD then
            nextX, nextY = nx, ny
            nextD = nd
         end
      end

      -- no uphill step found → local maximum
      if not nextX then
         break
      end

      bestX, bestY, bestD = nextX, nextY, nextD
   end

   return bestX, bestY
end

--- @param builder LevelBuilder
--- @param rng RNG
function util.randomFloor(builder, rng)
   local floors = {}

   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if util.isFloor(builder, x, y) then table.insert(floors, { x = x, y = y }) end
      end
   end

   if #floors == 0 then error("No floor tiles to place player") end

   return floors[rng:random(1, #floors)]
end

--- Turns isolated floor tiles into walls.
--- Any floor with >= wallThreshold surrounding wall/nil neighbors is filled.
--- @param builder LevelBuilder
--- @param wallThreshold integer
function util.collapseIsolatedFloors(builder, wallThreshold)
   wallThreshold = wallThreshold or 5

   local toFill = {}

   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if util.isFloor(builder, x, y) then -- floor
            local walls = 0

            for _, offset in ipairs(prism.Vector2.neighborhood4) do
               if util.isWall(builder, x + offset.x, y + offset.y) then
                  walls = walls + 1
               end
            end

            if walls >= wallThreshold then
               table.insert(toFill, { x = x, y = y })
            end
         end
      end
   end

   for _, p in ipairs(toFill) do
      builder:set(p.x, p.y, prism.cells.Wall())
   end
end

--- Removes thin / isolated wall tiles (probabilistic).
--- Uses util.isWall / util.isFloor.
--- @param rng RNG
--- @param builder LevelBuilder
function util.collapseThinWalls(rng, builder)
   local toCarve = {}

   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if util.isWall(builder, x, y) then
            local n = util.isFloor(builder, x,     y - 1)
            local s = util.isFloor(builder, x,     y + 1)
            local w = util.isFloor(builder, x - 1, y    )
            local e = util.isFloor(builder, x + 1, y    )

            local floors = 0
            if n then floors = floors + 1 end
            if s then floors = floors + 1 end
            if w then floors = floors + 1 end
            if e then floors = floors + 1 end

            local chance = 0

            -- Strong case: sandwiched wall
            if (n and s) or (w and e) then
               chance = 0.4

            -- Weaker case: wall nub
            elseif floors == 3 then
               chance = 0.1
            elseif floors == 4 then
               chance = 0.2
            end

            if chance > 0 and rng:random() < chance then
               toCarve[#toCarve + 1] = { x = x, y = y }
            end
         end
      end
   end

   for _, p in ipairs(toCarve) do
      builder:set(p.x, p.y, prism.cells.Floor())
   end
end

--- @return SparseGrid
function util.doorPathHeatmap(builder)
   local result = prism.SparseGrid()

   local doors = builder
      :query(prism.components.Door)
      :gather()

      for i = 1, #doors do
         for j = i + 1, #doors do
         local door = doors[i]
         local otherDoor = doors[j]
         local path = prism.astar(door:expectPosition(), otherDoor:expectPosition(), function(x, y) return builder:get(x, y) ~= nil end)

         if path then
            for _, node in ipairs(path:getPath()) do
               result:set(node.x, node.y, (result:get(node.x, node.y) or 0) + 1)
            end
         end
      end
   end
   
   return result

end

function util.buildWallDistanceField(builder)
   return util.buildDistanceField(
      builder,
      util.isWall,
      util.isFloor,
      prism.Vector2.neighborhood4
   )
end


--- Builds a distance field from source tiles defined by a predicate.
--- @param builder LevelBuilder
--- @param isSource fun(builder: LevelBuilder, x: integer, y: integer): boolean
--- @param isPassable fun(builder: LevelBuilder, x: integer, y: integer): boolean
--- @param neighborhood table? -- defaults to 4-neighborhood
--- @return SparseGrid
function util.buildDistanceField(builder, isSource, isPassable, neighborhood)
   neighborhood = neighborhood or prism.Vector2.neighborhood4

   local tl, br = builder:getBounds()
   local sources = {}

   for x = tl.x - 1, br.x + 1 do
      for y = tl.y - 1, br.y + 1 do
         if isSource(builder, x, y) then
            sources[#sources + 1] = prism.Vector2(x, y)
         end
      end
   end

   return prism.djisktra(
      sources,
      function(x, y)
         return isPassable(builder, x, y)
      end,
      neighborhood
   )
end


--- Removes doors that do not neighbor exactly one floor (cardinal only).
--- A valid door must have exactly one adjacent floor in neighborhood4.
--- @param builder LevelBuilder
function util.pruneInvalidDoors(builder)
   local toRemove = {}

   for door in builder:query(prism.components.DoorProxy):iter() do
      local x, y = door:expectPosition():decompose()

      local floorCount = 0
      for _, d in ipairs(prism.Vector2.neighborhood4) do
         if util.isFloor(builder, x + d.x, y + d.y) then
            floorCount = floorCount + 1
            if floorCount > 1 then
               break
            end
         end
      end

      if floorCount ~= 1 or util.isFloor(builder, x, y) then
         table.insert(toRemove, door)
      end
   end

   for _, door in ipairs(toRemove) do
      builder:removeActor(door)
   end
end

--- Removes doors that do not have exactly two wall neighbors (cardinal).
--- @param builder LevelBuilder
function util.pruneMisalignedDoors(builder)
   local toRemove = {}

   --- @param x integer
   --- @param y integer
   local function isValidDoor(x, y)
      local walls = 0

      for _, d in ipairs(prism.Vector2.neighborhood4) do
         if util.isWall(builder, x + d.x, y + d.y) then
            walls = walls + 1
            if walls > 2 then
               return false
            end
         end
      end

      return walls == 2
   end

   for door in builder:query(prism.components.Door):iter() do
      local x, y = door:expectPosition():decompose()

      if not isValidDoor(x, y) then
         toRemove[#toRemove + 1] = door
      end
   end

   for _, door in ipairs(toRemove) do
      builder:removeActor(door)
   end
end

--- Spawns spawnpoints in the most open sampled areas (furthest from walls),
--- then keeps only the most mutually separated ones.
--- @param builder LevelBuilder
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
function util.addSpawnpoints(builder, wallDistanceField, rng, opts)
   opts = opts or {}

   local finalCount = opts.count   or 15      -- FINAL spawnpoints
   local samples    = opts.samples or 150     -- random probes
   local poolSize   = opts.pool    or 100      -- candidates kept before separation

   local candidates = {}

   local function tryInsertCandidate(x, y, d)
      if #candidates < poolSize then
         candidates[#candidates + 1] = { x = x, y = y, d = d }
         return
      end

      -- replace weakest wall-distance candidate
      local weakest = 1
      for i = 2, #candidates do
         if candidates[i].d < candidates[weakest].d then
            weakest = i
         end
      end

      if d > candidates[weakest].d then
         candidates[weakest] = { x = x, y = y, d = d }
      end
   end

   -- Phase 1: sample good open spots
   for i = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isWalkable(builder, x, y) then
         local rx, ry = util.rollAwayFromWall(wallDistanceField, x, y)
         if rx
            and util.isWalkable(builder, rx, ry)
            and #builder:query():at(rx, ry):gather() == 0
         then
            local d = wallDistanceField:get(rx, ry)
            if d then
               tryInsertCandidate(rx, ry, d)
            end
         end
      end
   end

   if #candidates == 0 then return end

   -- Phase 2: maximize separation
   table.sort(candidates, function(a, b)
      return a.d > b.d -- start from most open
   end)

   local chosen = {}
   chosen[1] = table.remove(candidates, 1)

   local function minDistSqToChosen(c)
      local min = math.huge
      for _, s in ipairs(chosen) do
         local dx = c.x - s.x
         local dy = c.y - s.y
         local d2 = dx * dx + dy * dy
         if d2 < min then
            min = d2
         end
      end
      return min
   end

   while #chosen < finalCount and #candidates > 0 do
      local bestIdx = 1
      local bestScore = -1

      for i, c in ipairs(candidates) do
         local score = minDistSqToChosen(c)
         if score > bestScore then
            bestScore = score
            bestIdx = i
         end
      end

      print(#chosen, finalCount)
      chosen[#chosen + 1] = table.remove(candidates, bestIdx)
   end

   -- Spawn
   for _, c in ipairs(chosen) do
      builder:addActor(prism.actors.Spawner(), c.x, c.y)
   end
end

--- Returns the 3 most mutually distant spawnpoints using A* path distance.
--- Distance is measured by walkable path length, not Euclidean distance.
--- @param builder LevelBuilder
--- @return Actor[] -- prism.actors.Spawner
function util.getImportantSpawnpoints(builder)
   local spawners = builder
      :query(prism.components.Spawner)
      :gather()

   if #spawners <= 3 then
      return spawners
   end

   -- Cache positions
   local nodes = {}
   for i, s in ipairs(spawners) do
      local x, y = s:expectPosition():decompose()
      nodes[i] = { actor = s, x = x, y = y }
   end

   -- Path distance cache
   local dist = {}

   local function pathDistance(a, b)
      local path = prism.astar(
         prism.Vector2(a.x, a.y),
         prism.Vector2(b.x, b.y),
         function(x, y)
            return util.isWalkable(builder, x, y)
         end
      )

      if not path then
         return math.huge
      end

      return #path:getPath()
   end

   -- Precompute distances
   for i = 1, #nodes do
      dist[i] = {}
      for j = i + 1, #nodes do
         local d = pathDistance(nodes[i], nodes[j])
         dist[i][j] = d
         dist[j] = dist[j] or {}
         dist[j][i] = d
      end
   end

   -- Pick farthest pair
   local a, b
   local best = -1

   for i = 1, #nodes do
      for j = i + 1, #nodes do
         local d = dist[i][j]
         if d < math.huge and d > best then
            best = d
            a, b = i, j
         end
      end
   end

   if not a then
      return { spawners[1], spawners[2], spawners[3] }
   end

   -- Pick third maximizing total distance to {a,b}
   local c
   local bestScore = -1

   for i = 1, #nodes do
      if i ~= a and i ~= b then
         local d1 = dist[i][a] or math.huge
         local d2 = dist[i][b] or math.huge

         if d1 < math.huge and d2 < math.huge then
            local score = (d1 ^ 2) * (d2 ^ 2)
            if score > bestScore then
               bestScore = score
               c = i
            end
         end
      end
   end

   if not c then
      return { nodes[a].actor, nodes[b].actor }
   end

   return {
      nodes[a].actor,
      nodes[b].actor,
      nodes[c].actor,
   }
end


return util