local util = prism.levelgen.util

local SqeetoThinningDecorator =
   prism.levelgen.Decorator:extend "SqeetoThinningDecorator"

local KILL_RADIUS  = 10
local CLUMP_RADIUS = 10

function SqeetoThinningDecorator.tryDecorate(generatorInfo, rng, builder)
   local area = generatorInfo.w * generatorInfo.h
   local MAX_SQEETOS = math.floor(area / 150)

   local sqeetos = {}
   for actor in builder:query(prism.components.SqeetoFaction):iter() do
      sqeetos[#sqeetos + 1] = actor
   end

   if #sqeetos <= MAX_SQEETOS then
      return false
   end

   local targets = {}

   local player = builder:query(prism.components.PlayerController):first()
   if player then
      targets[#targets + 1] = player
   end

   for thrumble in builder:query(prism.components.ThrumbleFaction):iter() do
      targets[#targets + 1] = thrumble
   end

   if #targets > 0 then
      local targetDistanceField = util.buildDistanceField(
         builder,
         function(builder, x, y)
            for _, target in ipairs(targets) do
               local tx, ty = target:expectPosition():decompose()
               if x == tx and y == ty then
                  return true
               end
            end
            return false
         end,
         function(builder, x, y)
            return not util.isWall(builder, x, y)
         end,
         prism.Vector2.neighborhood8
      )

      local survivors = {}

      for _, sqeeto in ipairs(sqeetos) do
         local sx, sy = sqeeto:expectPosition():decompose()
         local d = targetDistanceField:get(sx, sy)

         if d and d <= KILL_RADIUS then
            builder:removeActor(sqeeto)
         else
            survivors[#survivors + 1] = sqeeto
         end
      end

      sqeetos = survivors
   end

   local excess = #sqeetos - MAX_SQEETOS
   if excess > 0 then
      local BUCKET = CLUMP_RADIUS
      local buckets = prism.SparseGrid()

      local function bucketCoord(v)
         return math.floor(v / BUCKET)
      end

      for _, sq in ipairs(sqeetos) do
         local x, y = sq:expectPosition():decompose()
         local bx = bucketCoord(x)
         local by = bucketCoord(y)

         local bucket = buckets:get(bx, by)
         if not bucket then
            bucket = {}
            buckets:set(bx, by, bucket)
         end

         bucket[#bucket + 1] = sq
      end

      local removedSomething = true

      while excess > 0 and removedSomething do
         removedSomething = false

         for _, _, bucket in buckets:each() do
            if excess <= 0 then break end

            if #bucket > 1 then
               local idx = rng:random(1, #bucket)
               builder:removeActor(bucket[idx])
               table.remove(bucket, idx)

               excess = excess - 1
               removedSomething = true
            end
         end
      end
   end

   return true
end

return SqeetoThinningDecorator
