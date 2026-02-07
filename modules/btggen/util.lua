local util = {}

--- Checks if a tile is a wall (no tile, no collision, or has collider)
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
--- @return boolean
function util.isWall(builder, x, y)
   if not builder:get(x, y) then return true end
   if builder:get(x, y):getCollisionMask() == 0 then return true end
   if builder:query(prism.components.Collider, prism.components.Opaque):at(x, y):first() then return true end
   return false
end

local walkmask = prism.Collision.createBitmaskFromMovetypes { "walk" }

--- Checks if a tile is walkable (has walkable collision mask)
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
--- @param mask number? Optional collision mask to test against (defaults to walk mask)
--- @return boolean
function util.isWalkable(builder, x, y, mask)
   if not builder:get(x, y) then return false end
   mask = mask or walkmask
   if prism.Collision.checkBitmaskOverlap(mask, builder:get(x, y):getCollisionMask()) then return true end
   return false
end

--- Checks if a tile blocks vision (has Opaque component)
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
--- @return boolean
function util.isOpaque(builder, x, y)
   return builder:get(x, y) and builder:get(x, y):get(prism.components.Opaque) ~= nil
end

--- Checks if a tile is a floor (walkable and not opaque)
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
--- @return boolean
function util.isFloor(builder, x, y)
   return util.isWalkable(builder, x, y)
end

--- Checks if a tile is an empty floor (floor with no actors)
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
--- @return boolean
function util.isEmptyFloor(builder, x, y)
   return util.isFloor(builder, x, y) and #builder:query():at(x, y):gather() == 0
end

--- Follows gradient downhill in distance field until reaching distance=1 (wall-adjacent)
--- @param distanceField SparseGrid Distance field to traverse
--- @param x integer Starting x coordinate
--- @param y integer Starting y coordinate
--- @return integer?, integer? Coordinates of wall-adjacent tile, or nil if unreachable
function util.rollDownhill(distanceField, x, y)
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

      if not nextX then break end
      bestX, bestY, bestD = nextX, nextY, nextD
   end

   if bestD == 1 then return bestX, bestY end
   return nil
end

--- Follows gradient uphill in distance field, moving away from walls until local maximum
--- @param distanceField SparseGrid Distance field to traverse
--- @param x integer Starting x coordinate
--- @param y integer Starting y coordinate
--- @return integer?, integer? Coordinates of local maximum, or nil if invalid start
function util.rollUphill(distanceField, x, y)
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

      if not nextX then break end
      bestX, bestY, bestD = nextX, nextY, nextD
   end

   return bestX, bestY
end

--- Generates a heatmap showing path frequency between all door pairs
--- @param builder LevelBuilder
--- @return SparseGrid Grid mapping coordinates to path traversal counts
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

--- Builds a distance field from walls to floors
--- @param builder LevelBuilder
--- @return SparseGrid Distance field (1 = wall-adjacent, increasing outward)
function util.buildWallDistanceField(builder)
   return util.buildDistanceField(builder, util.isWall, util.isFloor, prism.Vector2.neighborhood4)
end

--- Builds a distance field using Dijkstra from source tiles
--- @param builder LevelBuilder
--- @param isSource fun(builder: LevelBuilder, x: integer, y: integer): boolean Predicate for source tiles (distance=0)
--- @param isPassable fun(builder: LevelBuilder, x: integer, y: integer): boolean Predicate for traversable tiles
--- @param neighborhood table? Neighbor offsets (defaults to 4-neighborhood)
--- @return SparseGrid Distance field from sources
function util.buildDistanceField(builder, isSource, isPassable, neighborhood)
   neighborhood = neighborhood or prism.Vector2.neighborhood4
   local tl, br = builder:getBounds()
   local sources = {}

   for x = tl.x - 1, br.x + 1 do
      for y = tl.y - 1, br.y + 1 do
         if isSource(builder, x, y) then sources[#sources + 1] = prism.Vector2(x, y) end
      end
   end

   return prism.dijkstra(sources, function(x, y)
      return isPassable(builder, x, y)
   end, neighborhood)
end

--- Places item spawners in open areas, biased away from player spawnpoints
--- @param builder LevelBuilder
--- @param wallDistanceField SparseGrid Distance field from walls
--- @param rng RNG Random number generator
--- @param opts table? Configuration options
function util.addItemSpawns(builder, wallDistanceField, rng, opts)
   opts = opts or {}
   local finalCount = opts.count or 5
   local samples = opts.samples or 150
   local poolSize = opts.pool or 100
   local wallWeight = opts.wallWeight or 1.0
   local spawnWeight = opts.spawnWeight or 2

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

   for _, c in ipairs(chosen) do
      builder:addActor(prism.actors.ItemSpawner(), c.x, c.y)
   end
end

return util
