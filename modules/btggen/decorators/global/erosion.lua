local util = prism.levelgen.util

local ErosionDecorator = prism.levelgen.Decorator:extend "ErosionDecorator"

function ErosionDecorator.tryDecorate(rng, builder, _)
   local toCarve = {}

   for x = 1, LEVELGENBOUNDSX do
      for y = 1, LEVELGENBOUNDSY do
         if util.isWall(builder, x, y) then
            local n = util.isFloor(builder, x, y - 1)
            local s = util.isFloor(builder, x, y + 1)
            local w = util.isFloor(builder, x - 1, y)
            local e = util.isFloor(builder, x + 1, y)

            local floors = 0
            if n then floors = floors + 1 end
            if s then floors = floors + 1 end
            if w then floors = floors + 1 end
            if e then floors = floors + 1 end

            local chance = 0

            if (n and s) or (w and e) then
               chance = 0.4
            elseif floors == 3 then
               chance = 0.1
            elseif floors == 4 then
               chance = 0.2
            end

            if chance > 0 and rng:random() < chance then toCarve[#toCarve + 1] = { x = x, y = y } end
         end
      end
   end

   for _, p in ipairs(toCarve) do
      builder:set(p.x, p.y, prism.cells.Floor())
   end
end

return ErosionDecorator
