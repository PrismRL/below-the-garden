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


return util