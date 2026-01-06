local util = prism.levelgen.util

--- @class FireflyDecorator : Decorator
local FireflyDecorator = prism.levelgen.Decorator:extend "FireflyDecorator"

function FireflyDecorator.tryDecorate(generatorInfo, rng, builder)
   local count = 8
   local placed = false

   for _ = 1, count do
      local query = builder:query(prism.components.Light)

      local lightDistanceField = util.buildDistanceField(
         builder,
         function(builder, x, y)
            query:at(x, y)
            return query:first() ~= nil
         end,
         util.isFloor
      )

      local bestX, bestY, bestD

      for x, y in builder:each() do
         if util.isFloor(builder, x, y) then
            if #builder:query():at(x, y):gather() == 0 then
               local d = lightDistanceField:get(x, y)
               if d and (not bestD or d > bestD) then
                  bestX, bestY, bestD = x, y, d
               end
            end
         end
      end

      if not bestX then
         break
      end

      builder:addActor(prism.actors.Firefly(), bestX, bestY)
      placed = true
   end

   return placed
end

return FireflyDecorator
