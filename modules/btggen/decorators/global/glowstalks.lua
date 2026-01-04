local util = prism.levelgen.util

local GlowStalkDecorator = prism.levelgen.Decorator:extend "GlowStalkDecorator"

local MAX_TOTAL     = 20
local CLUMP_RADIUS  = 5
local MIN_SEED_DIST = 3
local ATTEMPTS      = 1000

local function findGlowStalkSpot(builder, wallDistanceField, lightDistanceField, x, y, minSeedDistance)
   if not util.isFloor(builder, x, y) then return nil end

   local d = wallDistanceField:get(x, y)
   if not d or d < minSeedDistance then return nil end

   local gx, gy = util.rollDownhill(wallDistanceField, x, y)
   if not gx then return nil end

   local ld = lightDistanceField:get(gx, gy)
   if ld and ld < 12 then return nil end

   if #builder:query():at(gx, gy):gather() ~= 0 then return nil end

   return gx, gy
end

function GlowStalkDecorator.tryDecorate(rng, builder, _)
   local wallDistanceField = util.buildWallDistanceField(builder)

   local lightQuery = builder:query(prism.components.Light)
   local lightDistanceField = util.buildDistanceField(
      builder,
      function(builder, x, y)
         lightQuery:at(x, y)
         return lightQuery:first() ~= nil
      end,
      util.isFloor
   )

   local stalks = {}

   for _ = 1, ATTEMPTS do
      local x = rng:random(2, LEVELGENBOUNDSX - 1)
      local y = rng:random(2, LEVELGENBOUNDSY - 1)

      local gx, gy = findGlowStalkSpot(
         builder,
         wallDistanceField,
         lightDistanceField,
         x, y,
         MIN_SEED_DIST
      )

      if gx then
         local actor = prism.actors.Glowstalk()
         builder:addActor(actor, gx, gy)
         stalks[#stalks + 1] = { x = gx, y = gy, actor = actor }
      end
   end

   local survivors = {}
   for _, s in ipairs(stalks) do
      local cell = builder:get(s.x, s.y)
      if cell and not cell:has(prism.components.Opaque) then
         survivors[#survivors + 1] = s
      else
         builder:removeActor(s.actor)
      end
   end
   stalks = survivors

   local excess = #stalks - MAX_TOTAL
   if excess > 0 then
      local BUCKET = CLUMP_RADIUS
      local buckets = prism.SparseGrid()

      local function bucketCoord(v)
         return math.floor(v / BUCKET)
      end

      for _, s in ipairs(stalks) do
         local bx = bucketCoord(s.x)
         local by = bucketCoord(s.y)

         local bucket = buckets:get(bx, by)
         if not bucket then
            bucket = {}
            buckets:set(bx, by, bucket)
         end

         bucket[#bucket + 1] = s
      end

      local removedSomething = true

      while excess > 0 and removedSomething do
         removedSomething = false

         for _, _, bucket in buckets:each() do
            if excess <= 0 then break end

            if #bucket > 1 then
               local idx = rng:random(1, #bucket)
               builder:removeActor(bucket[idx].actor)
               table.remove(bucket, idx)

               excess = excess - 1
               removedSomething = true
            end
         end
      end
   end

   return #stalks > 0
end

return GlowStalkDecorator
