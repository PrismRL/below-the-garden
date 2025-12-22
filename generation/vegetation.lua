local util = require "generation.util"
local vegetation = {}

local neighbors4 = prism.Vector2.neighborhood4

--- Returns true if tile borders a wall.
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
local function bordersWall(builder, x, y)
   for _, d in ipairs(neighbors4) do
      local nx, ny = x + d.x, y + d.y
      if not util.isFloor(builder, nx, ny) then
         return true
      end
   end
   return false
end

--- Counts adjacent TallGrass tiles.
--- @param builder LevelBuilder
--- @param x integer
--- @param y integer
local function countAdjacentOpaque(builder, x, y)
   local n = 0
   for _, d in ipairs(neighbors4) do
      local nx, ny = x + d.x, y + d.y
      if util.isOpaque(builder, nx, ny) then
         n = n + 1
      end
   end
   return n
end


--- Grows a blobby patch of tall grass from a seed.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param rng RNG
--- @param sx integer
--- @param sy integer
--- @param maxCount integer
--- @return integer placedCount
local function growTallGrassBlob(builder, heatmap, rng, sx, sy, maxCount)
   local frontier = {}
   local count = 0

   local function canPlace(x, y)
      if not util.isFloor(builder, x, y) then
         return false
      end

      if (heatmap:get(x, y) or 0) ~= 0 then
         return false
      end

      if countAdjacentOpaque(builder, x, y) < 2 then
         return false
      end

      return true
   end

   if not canPlace(sx, sy) then
      return 0
   end

   builder:set(sx, sy, prism.cells.TallGrass())
   frontier[1] = { x = sx, y = sy }
   count = 1

   for i = 1, maxCount * 3 do
      if count >= maxCount then
         break
      end

      local fcount = #frontier
      if fcount == 0 then
         break
      end

      local p = frontier[rng:random(1, fcount)]

      local bestAdj = -1
      local bestX, bestY = nil, nil
      local ties = 0

      for _, d in ipairs(neighbors4) do
         local nx = p.x + d.x
         local ny = p.y + d.y

         if canPlace(nx, ny) then
            local adj = countAdjacentOpaque(builder, nx, ny)

            if adj >= 2 then
               if adj > bestAdj then
                  bestAdj = adj
                  bestX, bestY = nx, ny
                  ties = 1
               elseif adj == bestAdj then
                  ties = ties + 1
                  if rng:random(ties) == 1 then
                     bestX, bestY = nx, ny
                  end
               end
            end
         end
      end

      if bestX then
         builder:set(bestX, bestY, prism.cells.TallGrass())
         frontier[#frontier + 1] = { x = bestX, y = bestY }
         count = count + 1
      end
   end

   return count
end

--- Spawns TallGrass by seeding near walls and locally spreading.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param distanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.attempts integer?
function vegetation.addTallGrass(builder, heatmap, distanceField, rng, opts)
   opts = opts or {}
   local attempts = opts.attempts or 200
   local totalMaxCount = 40
   local totalCount = 0

   for i = 1, attempts do
      if totalCount >= totalMaxCount then
         return
      end

      local x = rng:random(1, LEVELGENBOUNDSX)
      local y = rng:random(1, LEVELGENBOUNDSY)

      if util.isFloor(builder, x, y) then
         local sx, sy = util.rollToWall(distanceField, x, y)

         if sx then
            if (heatmap:get(sx, sy) or 0) == 0 then
               local maxCount = rng:random(6, 10)

               local placed = growTallGrassBlob(
                  builder,
                  heatmap,
                  rng,
                  sx,
                  sy,
                  maxCount
               )

               totalCount = totalCount + placed
            end
         end
      end
   end
end

--- Spawns GlowStalk actors adjacent to walls using wallDistanceField.
--- @param builder LevelBuilder
--- @param heatmap SparseGrid
--- @param wallDistanceField SparseGrid
--- @param rng RNG
--- @param opts table?
---    opts.attempts integer?
---    opts.maxTotal integer?
function vegetation.addGlowStalks(builder, heatmap, wallDistanceField, rng, opts)
   opts = opts or {}
   local attempts = opts.attempts or 1000
   local maxTotal = opts.maxTotal or 12
   local total = 0

   for i = 1, attempts do
      if total >= maxTotal then return end

      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      if util.isFloor(builder, x, y) and #builder:query():at(x, y):gather() == 0 then
         local d = wallDistanceField:get(x, y)

         -- exactly one tile away from a wall
         if d == 1 then
            -- avoid doors / traffic
            if (heatmap:get(x, y) or 0) == 0 then
               builder:addActor(prism.actors.Glowstalk(), x, y)
               total = total + 1
            end
         end
      end
   end
end

return vegetation