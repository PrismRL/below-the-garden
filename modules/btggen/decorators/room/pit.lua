local util = prism.levelgen.util
local PitDecorator = prism.levelgen.Decorator:extend "PitDecorator"

PitDecorator.pitCell = prism.cells.Pit
function PitDecorator.tryDecorate(generatorInfo, rng, builder, room)
   local minRoomSize = 9
   local minWallDist = 3
   local pitThreshold = 0.0
   local noiseScale1 = 0.08
   local noiseScale2 = 0.16
   local noiseWeight2 = 0.5

   local minIslandSize = 6
   local bridgeCost = 2
   local maxBridgeCost = 16

   local minFloorRatio = 0.30
   local maxNoiseRerolls = 5

   if room.size <= minRoomSize then return end

   local cx, cy = room.center:decompose()
   local wallDistanceField = util.buildWallDistanceField(builder)
   local centerD = wallDistanceField:get(cx, cy)
   if not centerD or centerD <= minWallDist then return end

   ----------------------------------------------------------------
   -- Noise-based pit carving (with floor-ratio reroll)
   ----------------------------------------------------------------
   local success = false

   for attempt = 1, maxNoiseRerolls do
      local seedX = rng:random() * 1000
      local seedY = rng:random() * 1000

      local floorCount = 0
      local totalCount = 0

      for x, y in room.tiles:each() do
         local v1 = love.math.noise(x * noiseScale1 + seedX, y * noiseScale1 + seedY)
         local v2 = love.math.noise(x * noiseScale2 + seedX, y * noiseScale2 + seedY)
         local v = (v1 + v2 * noiseWeight2) / (1 + noiseWeight2)
         v = v * 2 - 1

         totalCount = totalCount + 1

         if v > pitThreshold then
            builder:set(x, y, prism.cells.Pit())
         else
            builder:set(x, y, prism.cells.Floor())
            floorCount = floorCount + 1
         end
      end

      if floorCount / totalCount >= minFloorRatio then
         success = true
         break
      end
   end

   if not success then return false end

   ----------------------------------------------------------------
   -- Internal island detection via BFS (SparseGrid-based)
   ----------------------------------------------------------------
   local islands = {}
   local visited = prism.SparseGrid()

   local function passable(x, y)
      return room.tiles:get(x, y) and util.isWalkable(builder, x, y)
   end

   for x, y in room.tiles:each() do
      if passable(x, y) and not visited:get(x, y) then
         local island = prism.SparseGrid()
         local count = 0

         prism.bfs(prism.Vector2(x, y), passable, function(ix, iy)
            visited:set(ix, iy, true)
            island:set(ix, iy, true)
            count = count + 1
         end, prism.Vector2.neighborhood4)

         islands[#islands + 1] = {
            grid = island,
            size = count,
         }
      end
   end

   local function islandCenter(island)
      local sx, sy = 0, 0
      local n = 0

      for x, y in island.grid:each() do
         sx = sx + x
         sy = sy + y
         n = n + 1
      end

      return prism.Vector2(math.floor(sx / n + 0.5), math.floor(sy / n + 0.5))
   end

   if #islands > 1 then
      table.sort(islands, function(a, b)
         return a.size > b.size
      end)

      local mainCenter = islandCenter(islands[1])

      for i = 2, #islands do
         local island = islands[i]

         if island.size < minIslandSize then
            -- Remove tiny islands
            for x, y in island.grid:each() do
               builder:set(x, y, prism.cells.Pit())
            end
         else
            -- Bridge-connect larger islands
            local target = islandCenter(island)

            local path = prism.astar(mainCenter, target, function(x, y)
               return room.tiles:get(x, y) and not util.isWall(builder, x, y)
            end, function(x, y)
               return util.isWalkable(builder, x, y) and 0 or 3
            end, nil, "4way", prism.Vector2.neighborhood4)

            if path then
               for _, vec in ipairs(path:getPath()) do
                  if room.tiles:get(vec.x, vec.y) and not util.isWalkable(builder, vec.x, vec.y) then
                     builder:set(vec.x, vec.y, prism.cells.Bridge())
                  end
               end
            end
         end
      end
   end

   ----------------------------------------------------------------
   -- Between-room connectivity (neighbor → main island center)
   ----------------------------------------------------------------
   if islands and islands[1] then
      local mainCenter = islandCenter(islands[1])

      for neighbor in pairs(room.neighbors) do
         local path = prism.astar(neighbor.center, mainCenter, function(x, y)
            return not util.isWall(builder, x, y) and room.tiles:get(x,y) or neighbor.tiles:get(x, y)
         end, function(x, y)
            return util.isWalkable(builder, x, y) and 1 or bridgeCost
         end, nil, "4way", prism.Vector2.neighborhood4)

         if path then
            for _, vec in ipairs(path:getPath()) do
               if room.tiles:get(vec.x, vec.y) and not util.isWalkable(builder, vec.x, vec.y) then
                  builder:set(vec.x, vec.y, prism.cells.Bridge())
               end
            end
         end
      end
   end

   return true
end

return PitDecorator
