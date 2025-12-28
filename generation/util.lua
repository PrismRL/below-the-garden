local util = {}

--- @param builder LevelBuilder
---@param x integer
---@param y integer
function util.isWall(builder, x, y)
   if not builder:get(x, y) then return true end
   if builder:get(x, y):getCollisionMask() == 0 then return true end
   if builder:query(prism.components.Collider):at(x, y):first() then
      print "COLLIDER"
      return true
   end

   return false
end

local walkmask = prism.Collision.createBitmaskFromMovetypes { "walk" }

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

function util.is() end
--- @param builder LevelBuilder
---@param x integer
---@param y integer
function util.isFloor(builder, x, y)
   return util.isWalkable(builder, x, y) and not util.isOpaque(builder, x, y)
end

function util.isEmptyFloor(builder, x, y)
   return util.isFloor(builder, x, y) and #builder:query():at(x, y):gather() == 0
end

function util.rollToWall(distanceField, x, y)
   local bestX, bestY = x, y
   local bestD = distanceField:get(x, y)

   if not bestD then return nil end

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
      if not nextX then break end

      bestX, bestY, bestD = nextX, nextY, nextD
   end

   if bestD == 1 then return bestX, bestY end

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

   if not bestD then return nil end

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
      if not nextX then break end

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
               if util.isWall(builder, x + offset.x, y + offset.y) then walls = walls + 1 end
            end

            if walls >= wallThreshold then table.insert(toFill, { x = x, y = y }) end
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
            local n = util.isFloor(builder, x, y - 1)
            local s = util.isFloor(builder, x, y + 1)
            local w = util.isFloor(builder, x - 1, y)
            local e = util.isFloor(builder, x + 1, y)

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

            if chance > 0 and rng:random() < chance then toCarve[#toCarve + 1] = { x = x, y = y } end
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

   local doors = builder:query(prism.components.Door):gather()

   for i = 1, #doors do
      for j = i + 1, #doors do
         local door = doors[i]
         local otherDoor = doors[j]
         local path = prism.astar(door:expectPosition(), otherDoor:expectPosition(), function(x, y)
            return builder:get(x, y) ~= nil
         end)

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
   return util.buildDistanceField(builder, util.isWall, util.isFloor, prism.Vector2.neighborhood4)
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
         if isSource(builder, x, y) then sources[#sources + 1] = prism.Vector2(x, y) end
      end
   end

   return prism.djisktra(sources, function(x, y)
      return isPassable(builder, x, y)
   end, neighborhood)
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
            if floorCount > 1 then break end
         end
      end

      if floorCount ~= 1 or util.isFloor(builder, x, y) then table.insert(toRemove, door) end
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
            if walls > 2 then return false end
         end
      end

      return walls == 2
   end

   for door in builder:query(prism.components.Door):iter() do
      local x, y = door:expectPosition():decompose()

      if not isValidDoor(x, y) then toRemove[#toRemove + 1] = door end
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

   local finalCount = opts.count or 15 -- FINAL spawnpoints
   local samples = opts.samples or 150 -- random probes
   local poolSize = opts.pool or 100 -- candidates kept before separation

   local candidates = {}

   local function tryInsertCandidate(x, y, d)
      if #candidates < poolSize then
         candidates[#candidates + 1] = { x = x, y = y, d = d }
         return
      end

      -- replace weakest wall-distance candidate
      local weakest = 1
      for i = 2, #candidates do
         if candidates[i].d < candidates[weakest].d then weakest = i end
      end

      if d > candidates[weakest].d then candidates[weakest] = { x = x, y = y, d = d } end
   end

   -- Phase 1: sample good open spots
   for _ = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isWalkable(builder, x, y) then
         local rx, ry = util.rollAwayFromWall(wallDistanceField, x, y)
         if
            rx
            and util.isWalkable(builder, rx, ry)
            and #builder:query(prism.components.Collider):at(rx, ry):gather() == 0
         then
            local d = wallDistanceField:get(rx, ry)
            if d then tryInsertCandidate(rx, ry, d) end
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
         if d2 < min then min = d2 end
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
   local spawners = builder:query(prism.components.Spawner):gather()

   if #spawners <= 3 then return spawners end

   -- Cache positions
   local nodes = {}
   for i, s in ipairs(spawners) do
      local x, y = s:expectPosition():decompose()
      nodes[i] = { actor = s, x = x, y = y }
   end

   -- Path distance cache
   local dist = {}

   local function pathDistance(a, b)
      local path = prism.astar(prism.Vector2(a.x, a.y), prism.Vector2(b.x, b.y), function(x, y)
         return util.isWalkable(builder, x, y)
      end)

      if not path then return math.huge end

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

   if not a then return { spawners[1], spawners[2], spawners[3] } end

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

   if not c then return { nodes[a].actor, nodes[b].actor } end

   return {
      nodes[a].actor,
      nodes[b].actor,
      nodes[c].actor,
   }
end

--- Spawns item spawners in open areas, biased away from existing spawnpoints.
--- @param builder LevelBuilder
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.count integer?        -- final item spawns
---    opts.samples integer?      -- random probes
---    opts.pool integer?         -- candidate pool
---    opts.wallWeight number?    -- weight for wall distance
---    opts.spawnWeight number?   -- weight for spawnpoint distance
function util.addItemSpawns(builder, wallDistanceField, rng, opts)
   opts = opts or {}

   local finalCount = opts.count or 5
   local samples = opts.samples or 150
   local poolSize = opts.pool or 100
   local wallWeight = opts.wallWeight or 1.0
   local spawnWeight = opts.spawnWeight or 2

   --------------------------------------------------------------------------
   -- Build distance field from existing spawnpoints
   --------------------------------------------------------------------------

   local spawnDistanceField = util.buildDistanceField(builder, function(builder, x, y)
      return builder:query(prism.components.Spawner):at(x, y):first() ~= nil
   end, function(builder, x, y)
      return util.isWalkable(builder, x, y)
   end)

   local candidates = {}

   local function tryInsertCandidate(x, y, score, wallD, spawnD)
      if #candidates < poolSize then
         candidates[#candidates + 1] = {
            x = x,
            y = y,
            score = score,
            wallD = wallD,
            spawnD = spawnD,
         }
         return
      end

      local weakest = 1
      for i = 2, #candidates do
         if candidates[i].score < candidates[weakest].score then weakest = i end
      end

      if score > candidates[weakest].score then
         candidates[weakest] = {
            x = x,
            y = y,
            score = score,
            wallD = wallD,
            spawnD = spawnD,
         }
      end
   end

   --------------------------------------------------------------------------
   -- Phase 1: sample good candidates
   --------------------------------------------------------------------------

   for _ = 1, samples do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isWalkable(builder, x, y) then
         local rx, ry = x, y
         if rx and util.isWalkable(builder, rx, ry) and #builder:query():at(rx, ry):gather() == 0 then
            local wallD = wallDistanceField:get(rx, ry)
            local spawnD = spawnDistanceField:get(rx, ry)

            if wallD and spawnD then
               local score = wallD * wallWeight + spawnD * spawnWeight

               tryInsertCandidate(rx, ry, score, wallD, spawnD)
            end
         end
      end
   end

   if #candidates == 0 then return end

   --------------------------------------------------------------------------
   -- Phase 2: maximize mutual separation (same as spawnpoints)
   --------------------------------------------------------------------------

   table.sort(candidates, function(a, b)
      return a.score > b.score
   end)

   local chosen = {}
   chosen[1] = table.remove(candidates, 1)

   local function minDistSqToChosen(c)
      local min = math.huge
      for _, s in ipairs(chosen) do
         local dx = c.x - s.x
         local dy = c.y - s.y
         local d2 = dx * dx + dy * dy
         if d2 < min then min = d2 end
      end
      return min
   end

   while #chosen < finalCount and #candidates > 0 do
      local bestIdx = 1
      local bestScore = -1

      for i, c in ipairs(candidates) do
         local sep = minDistSqToChosen(c)
         if sep > bestScore then
            bestScore = sep
            bestIdx = i
         end
      end

      chosen[#chosen + 1] = table.remove(candidates, bestIdx)
   end

   --------------------------------------------------------------------------
   -- Spawn item spawners
   --------------------------------------------------------------------------

   for _, c in ipairs(chosen) do
      builder:addActor(prism.actors.ItemSpawner(), c.x, c.y)
   end
end

--- Finds rooms by flood-filling areas with wall distance > 1.
--- Treats wall distance of 1 as hallways, larger values as room tiles.
--- Then expands each room once to include adjacent floor tiles (hallways/edges).
--- Finally, flood-fills remaining unclaimed floor tiles as hallway rooms.
--- @param builder LevelBuilder
--- @param wallDistanceField SparseGrid
--- @param minRoomSize integer? -- minimum tiles to count as a room (default: 9)
--- @return table[] -- array of rooms, each room is {tiles = SparseGrid, size = number, isHallway = boolean, center = {x = number, y = number}}
function util.findRooms(builder, wallDistanceField, minRoomSize)
   minRoomSize = minRoomSize or 9
   local claimed = prism.SparseGrid()
   local rooms = {}

   local function isRoomTile(x, y)
      local d = wallDistanceField:get(x, y)
      return d and d > 1 and util.isFloor(builder, x, y)
   end

   local function findRoomCenter(tiles)
      local bestX, bestY
      local bestDist = -1

      for tx, ty in tiles:each() do
         local dist = wallDistanceField:get(tx, ty) or 0
         if dist > bestDist then
            bestDist = dist
            bestX, bestY = tx, ty
         end
      end

      return bestX and prism.Vector2(bestX, bestY) or nil
   end

   local tl, br = builder:getBounds()

   -- Phase 1: Find and expand large rooms (wall distance > 1)
   for x = tl.x, br.x do
      for y = tl.y, br.y do
         if not claimed:get(x, y) and isRoomTile(x, y) then
            local tiles = prism.SparseGrid()
            local count = 0

            prism.bfs(prism.Vector2(x, y), function(bx, by)
               return isRoomTile(bx, by) and not claimed:get(bx, by)
            end, function(bx, by)
               tiles:set(bx, by, true)
               claimed:set(bx, by, true)
               count = count + 1
            end)

            if count >= minRoomSize then
               -- Expand room by one tile to include adjacent floors
               local expanded = prism.SparseGrid()
               local expandedCount = 0

               -- Copy original tiles
               for tx, ty in tiles:each() do
                  expanded:set(tx, ty, true)
                  expandedCount = expandedCount + 1
               end

               -- Add adjacent floor tiles that aren't claimed
               for tx, ty in tiles:each() do
                  for _, d in ipairs(prism.Vector2.neighborhood8) do
                     local nx, ny = tx + d.x, ty + d.y
                     if not expanded:get(nx, ny) and not claimed:get(nx, ny) and util.isFloor(builder, nx, ny) then
                        expanded:set(nx, ny, true)
                        claimed:set(nx, ny, true)
                        expandedCount = expandedCount + 1
                     end
                  end
               end

               rooms[#rooms + 1] = {
                  tiles = expanded,
                  size = expandedCount,
                  isHallway = false,
                  center = findRoomCenter(expanded),
                  color = prism.Color4(math.random(), math.random(), math.random()),
                  neighbors = {},
               }
            end
         end
      end
   end

   -- Phase 2: Flood-fill remaining unclaimed floor tiles as hallway rooms
   for x = tl.x, br.x do
      for y = tl.y, br.y do
         if not claimed:get(x, y) and util.isFloor(builder, x, y) then
            local tiles = prism.SparseGrid()
            local count = 0

            prism.bfs(prism.Vector2(x, y), function(bx, by)
               return util.isFloor(builder, bx, by) and not claimed:get(bx, by)
            end, function(bx, by)
               tiles:set(bx, by, true)
               claimed:set(bx, by, true)
               count = count + 1
            end)

            if count > 0 then
               rooms[#rooms + 1] = {
                  tiles = tiles,
                  size = count,
                  isHallway = false,
                  center = findRoomCenter(tiles),
                  color = prism.Color4(math.random(), math.random(), math.random()),
                  neighbors = {},
               }
            end
         end
      end
   end

   return rooms
end

--- Two rooms are connected if they share adjacent floor tiles.
--- @param rooms table[] -- output from util.findRooms
--- @return table -- graph where graph[room] = {connectedRoom1, connectedRoom2, ...}
function util.buildRoomGraph(rooms)
   -- Build tile -> room lookup
   local tileToRoom = prism.SparseGrid()
   for _, room in ipairs(rooms) do
      for x, y in room.tiles:each() do
         tileToRoom:set(x, y, room)
      end
   end

   -- Track which room pairs we've already connected
   local connected = {}

   -- Check each tile's neighbors once
   for x, y, room in tileToRoom:each() do
      for _, d in ipairs(prism.Vector2.neighborhood4) do
         local nx, ny = x + d.x, y + d.y
         local neighborRoom = tileToRoom:get(nx, ny)

         if neighborRoom and neighborRoom ~= room then
            -- Create unique key for this pair (using table addresses)
            local a, b = room, neighborRoom
            if tostring(a) > tostring(b) then
               a, b = b, a
            end
            local key = tostring(a) .. "," .. tostring(b)

            if not connected[key] then
               connected[key] = true
               room.neighbors[neighborRoom] = true
               neighborRoom.neighbors[room] = true
            end
         end
      end
   end
end

--- Finds all rooms that are part of non-looping branches
--- (i.e. not in any cycle)
--- @param rooms table[]
--- @return table set -- rooms that are in branches
function util.findBranchRooms(rooms)
   -- Copy adjacency into mutable degrees
   local degree = {}
   local queue = {}
   local inCore = {}

   for _, room in ipairs(rooms) do
      local d = 0
      for _ in pairs(room.neighbors) do
         d = d + 1
      end
      degree[room] = d
      inCore[room] = true

      if d <= 1 then table.insert(queue, room) end
   end

   -- Peel leaves
   while #queue > 0 do
      local room = table.remove(queue)
      inCore[room] = false

      for neighbor in pairs(room.neighbors) do
         if inCore[neighbor] then
            degree[neighbor] = degree[neighbor] - 1
            if degree[neighbor] == 1 then table.insert(queue, neighbor) end
         end
      end
   end

   -- Anything NOT in core is a branch
   local branches = {}
   for _, room in ipairs(rooms) do
      if not inCore[room] then branches[room] = true end
   end

   return branches
end

return util
