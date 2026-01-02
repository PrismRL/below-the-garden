--- @class RingRoomGenerator : RoomGenerator
local RingRoomGenerator = prism.levelgen.RoomGenerator:extend "RingRoomGenerator"

function RingRoomGenerator.generate(rng)
   local b = prism.LevelBuilder()

   local rOuter = rng:random(6, 8)

   local rWall = rOuter - 4
   local rInner = rWall - 1

   local cx = rOuter + 2
   local cy = rOuter + 2

   -- outer walkable ring
   b:ellipse("fill", cx, cy, rOuter, rOuter, prism.cells.Floor)
   -- wall ring
   b:ellipse("fill", cx, cy, rWall, rWall, prism.cells.Wall)
   -- inner void
   if rInner > 0 then b:ellipse("fill", cx, cy, rInner, rInner, prism.cells.Floor) end

   -- carve a radial opening
   local d = prism.Vector2.neighborhood4[rng:random(1, 4)]
   for i = rInner + 1, rOuter - 1 do
      b:setCell(cx + d.x * i, cy + d.y * i, prism.cells.Floor())
   end

   return b
end

return RingRoomGenerator
