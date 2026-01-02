--- @class RectRoomGenerator : RoomGenerator
local RectRoomGenerator = prism.levelgen.RoomGenerator:extend "RectRoomGenerator"

function RectRoomGenerator.generate(rng)
   local b = prism.LevelBuilder()

   local w = rng:random(2, 9)
   local h = rng:random(2, 9)

   b:rectangle("fill", 2, 2, 2 + w, 2 + h, prism.cells.Floor)
   return b
end

return RectRoomGenerator
