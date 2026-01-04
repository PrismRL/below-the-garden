local util = prism.levelgen.util

local SqeetoThinningDecorator =
   prism.levelgen.Decorator:extend "SqeetoThinningDecorator"

local MAX_SQEETOS  = 16
local KILL_RADIUS = 10
local CLUMP_RADIUS = 5

function SqeetoThinningDecorator.tryDecorate(rng, builder)
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
            return util.isFloor(builder, x, y)
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
      local function localDensity(sq)
         local sx, sy = sq:expectPosition():decompose()
         local count = 0

         for _, other in ipairs(sqeetos) do
            if other ~= sq then
               local ox, oy = other:expectPosition():decompose()
               if math.abs(ox - sx) <= CLUMP_RADIUS
                  and math.abs(oy - sy) <= CLUMP_RADIUS then
                  count = count + 1
               end
            end
         end

         return count
      end

      table.sort(sqeetos, function(a, b)
         return localDensity(a) > localDensity(b)
      end)

      for i = 1, excess do
         builder:removeActor(sqeetos[i])
      end
   end

   return true
end

return SqeetoThinningDecorator
