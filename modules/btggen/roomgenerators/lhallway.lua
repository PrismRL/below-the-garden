--- @class HallwayLRoomGenerator : RoomGenerator
local HallwayLRoomGenerator = prism.levelgen.RoomGenerator:extend "HallwayLRoomGenerator"

function HallwayLRoomGenerator.generate(rng)
   local b = prism.LevelBuilder()

   local t = rng:random(2, 3)
   local lenA = rng:random(4, 8)
   local lenB = rng:random(4, 8)
   local ox, oy = 2, 2

   if rng:random() < 0.5 then
      b:rectangle("fill", ox, oy, ox + lenA, oy + t - 1, prism.cells.Floor)
      b:rectangle("fill", ox + lenA - (t - 1), oy, ox + lenA, oy + lenB, prism.cells.Floor)
   else
      b:rectangle("fill", ox, oy, ox + t - 1, oy + lenA, prism.cells.Floor)
      b:rectangle("fill", ox, oy + lenA - (t - 1), ox + lenB, oy + lenA, prism.cells.Floor)
   end

   return b
end

return HallwayLRoomGenerator
