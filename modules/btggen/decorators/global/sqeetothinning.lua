local util = prism.levelgen.util

local SqeetoThinningDecorator =
   prism.levelgen.Decorator:extend "SqeetoThinningDecorator"

local MAX_SQEETOS  = 16
local KILL_RADIUS = 8

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

   if #targets == 0 then
      local excess = #sqeetos - MAX_SQEETOS
      for i = #sqeetos, 2, -1 do
         local j = rng:random(i)
         sqeetos[i], sqeetos[j] = sqeetos[j], sqeetos[i]
      end
      for i = 1, excess do
         builder:removeActor(sqeetos[i])
      end
      return true
   end

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

   local excess = #survivors - MAX_SQEETOS
   if excess > 0 then
      for i = #survivors, 2, -1 do
         local j = rng:random(i)
         survivors[i], survivors[j] = survivors[j], survivors[i]
      end

      for i = 1, excess do
         builder:removeActor(survivors[i])
      end
   end

   return true
end

return SqeetoThinningDecorator
