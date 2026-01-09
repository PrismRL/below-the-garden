local util = prism.levelgen.util

local GobLair =
   prism.levelgen.Decorator:extend "GobLair"

local MIN_WALL_DIST = 3

function GobLair.tryDecorate(generatorInfo, rng, builder, room)
   if not room then return false end

   local cx, cy = room.center:decompose()
   if not util.isEmptyFloor(builder, cx, cy) then
      return false
   end

   local wallDistanceField = util.buildWallDistanceField(builder)
   local d = wallDistanceField:get(cx, cy)

   if not d or d < MIN_WALL_DIST then
      return false
   end

   local spots = {}

   for dx = -1, 1 do
      for dy = -1, 1 do
         local x = cx + dx
         local y = cy + dy
         if util.isEmptyFloor(builder, x, y) then
            spots[#spots + 1] = { x = x, y = y }
         end
      end
   end

   if #spots < 1 then
      return false
   end

   local i = rng:random(1, #spots)
   local thrumbleSpot = table.remove(spots, i)
   builder:addActor(prism.actors.Gob(), thrumbleSpot.x, thrumbleSpot.y)
   builder:addActor(prism.actors.GobHome(), thrumbleSpot.x, thrumbleSpot.y)

   return true
end

return GobLair
