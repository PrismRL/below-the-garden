local util = prism.levelgen.util

--- @class RoomGenerator : Object
local RoomGenerator = prism.Object:extend "RoomGenerator"

--- @return LevelBuilder
function RoomGenerator.generate(rng)
   error("This must be overriden!")
end

--- Works for any carved room shape.
--- @param builder LevelBuilder
--- @param rng RNG
function RoomGenerator.addDoors(builder, rng)
   local candidates = {}

   local tl, br = builder:getBounds()
   for x = tl.x - 1, br.x + 1 do
      for y = tl.y - 1, br.y + 1 do
         if util.isWall(builder, x, y) then
            local count = 0
            for _, d in ipairs(prism.Vector2.neighborhood4) do
               if util.isFloor(builder, x + d.x, y + d.y) then count = count + 1 end
            end
            if count == 1 then candidates[#candidates + 1] = { x = x, y = y } end
         end
      end
   end

   for _ = 1, math.min(7, #candidates) do
      local idx = rng:random(1, #candidates)
      local d = table.remove(candidates, idx)
      builder:addActor(prism.actors.DoorProxy(), d.x, d.y)
   end
end

--- @return LevelBuilder
function RoomGenerator:_generate(rng)
   local room = self.generate(rng)
   self.addDoors(room, rng)
   return room
end

return RoomGenerator
