--- @class EllipseRoomGenerator : RoomGenerator
local EllipseRoomGenerator = prism.levelgen.RoomGenerator:extend "EllipseRoomGenerator"

function EllipseRoomGenerator.generate(rng)
   local b = prism.LevelBuilder()

   local rx = rng:random(3, 7)
   local ry = rng:random(3, 6)

   local cx = rx + 2
   local cy = ry + 2

   b:ellipse("fill", cx, cy, rx, ry, prism.cells.Floor)
   return b
end

return EllipseRoomGenerator
