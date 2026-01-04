--- @class CircleRoomGenerator : RoomGenerator
local CircleRoomGenerator = prism.levelgen.RoomGenerator:extend "CircleRoomGenerator"

function CircleRoomGenerator.generate(rng)
   local b = prism.LevelBuilder()

   local r = rng:random(3, 6)
   local cx = r + 2
   local cy = r + 2

   b:ellipse("fill", cx, cy, r, r, prism.cells.Floor)
   return b
end

return CircleRoomGenerator
