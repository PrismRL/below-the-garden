local util = prism.levelgen.util

local GlowStalkDecorator = prism.levelgen.Decorator:extend "GlowStalkDecorator"

--- Attempts to find a wall-adjacent placement by seeding far from walls
--- and sufficiently far from light.
--- @param builder LevelBuilder
--- @param wallDistanceField SparseGrid
--- @param lightDistanceField SparseGrid
--- @param x integer
--- @param y integer
--- @param minSeedDistance integer
--- @return integer?, integer?
local function findGlowStalkSpot(builder, wallDistanceField, lightDistanceField, x, y, minSeedDistance)
   print "FIND"
   if not util.isFloor(builder, x, y) then return nil end

   local d = wallDistanceField:get(x, y)
   if not d or d < minSeedDistance then return nil end

   local gx, gy = util.rollDownhill(wallDistanceField, x, y)
   if not gx then return nil end

   -- Reject if too close to light
   local ld = lightDistanceField:get(gx, gy)
   print("LIGHT DISTANCE", ld)
   if ld and ld < 12 then return nil end

   -- Reject occupied tiles
   if #builder:query():at(gx, gy):gather() ~= 0 then return nil end

   return gx, gy
end

function GlowStalkDecorator.tryDecorate(rng, builder, _)
   local attempts = 1000
   local maxTotal = 20
   local minSeedDistance = 3

   local wallDistanceField = util.buildWallDistanceField(builder)

   local query = builder:query(prism.components.Light)

   local lightDistanceField = util.buildDistanceField(
      builder,
      function(builder, x, y)
         query:at(x, y)
         return query:first() ~= nil
      end,
      util.isFloor
   )

   -- Track all spawned glowstalks
   local stalks = {}

   -- Phase 1: spawn freely
   for _ = 1, attempts do
      print "ATTEMPT"
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      local gx, gy = findGlowStalkSpot(
         builder,
         wallDistanceField,
         lightDistanceField,
         x, y,
         minSeedDistance
      )

      if gx then
         local actor = prism.actors.Glowstalk()
         builder:addActor(actor, gx, gy)
         table.insert(stalks, { x = gx, y = gy, actor = actor })
      end
   end

   -- Phase 2: hard cull (opaque tiles)
   local survivors = {}
   for _, s in ipairs(stalks) do
      local cell = builder:get(s.x, s.y)
      if cell and not cell:has(prism.components.Opaque) then
         table.insert(survivors, s)
      else
         builder:removeActor(s.actor)
      end
   end
   stalks = survivors

   -- Phase 3: wave-based density culling
   if #stalks > maxTotal then
      local grid = prism.SparseGrid()

      local function rebuildGrid()
         grid:clear()
         for _, s in ipairs(stalks) do
            grid:set(s.x, s.y, true)
         end
      end

      local function computeScores()
         for _, s in ipairs(stalks) do
            local score = 0
            for _, d in ipairs(prism.Vector2.neighborhood8) do
               if grid:get(s.x + d.x, s.y + d.y) then
                  score = score + 1
               end
            end
            s.score = score
         end
      end

      local wave = 0
      local maxWaves = 10
      local cullFraction = 0.25 -- 25% per wave

      while #stalks > maxTotal and wave < maxWaves do
         wave = wave + 1

         rebuildGrid()
         computeScores()

         table.sort(stalks, function(a, b)
            return a.score > b.score
         end)

         -- Remove only the worst offenders this wave
         local excess = #stalks - maxTotal
         local waveCull = math.max(1, math.floor(#stalks * cullFraction))
         local toRemove = math.min(excess, waveCull)

         for i = 1, toRemove do
            local s = stalks[i]
            builder:removeActor(s.actor)
         end

         -- Compact survivors
         local survivors = {}
         for i = toRemove + 1, #stalks do
            table.insert(survivors, stalks[i])
         end
         stalks = survivors
      end
   end


   return #stalks > 0
end

return GlowStalkDecorator
