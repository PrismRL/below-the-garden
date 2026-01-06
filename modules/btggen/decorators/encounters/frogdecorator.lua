local util = prism.levelgen.util

local FrogDecorator =
   prism.levelgen.Decorator:extend "FrogDecorator"

-- Out of 8 neighbors
local MIN_OPAQUE_NEIGHBORS = 7

function FrogDecorator.tryDecorate(generatorInfo, rng, builder, room)
   if not room then
      return false
   end

   local candidates = {}
   local checked = 0

   for x, y in room.tiles:each() do
      checked = checked + 1

      if util.isWalkable(builder, x, y)
         and util.isOpaque(builder, x, y)
      then
         local opaqueCount = 0

         for dx = -1, 1 do
            for dy = -1, 1 do
               if not (dx == 0 and dy == 0) then
                  if util.isOpaque(builder, x + dx, y + dy) then
                     opaqueCount = opaqueCount + 1
                  end
               end
            end
         end

         if opaqueCount >= MIN_OPAQUE_NEIGHBORS then
            candidates[#candidates + 1] = { x = x, y = y }
         end
      end
   end


   if #candidates == 0 then
      return false
   end

   local index = rng:random(1, #candidates)
   local p = candidates[index]

   builder:addActor(prism.actors.Frog(), p.x, p.y)
   builder:addActor(prism.actors.FrogHome(), p.x, p.y)

   return true
end

return FrogDecorator
