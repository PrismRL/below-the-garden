local util = prism.levelgen.util

local ThrumbleScoutDecorator =
   prism.levelgen.Decorator:extend "ThrumbleScoutDecorator"

local MIN_WALL_DIST = 3

function ThrumbleScoutDecorator.tryDecorate(generatorInfo, rng, builder, room)
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

   if #spots < 2 then
      return false
   end

   local i = rng:random(1, #spots)
   local thrumbleSpot = table.remove(spots, i)
   builder:addActor(prism.actors.Thrumble(), thrumbleSpot.x, thrumbleSpot.y)

   if #spots > 0 then
      local torchSpot = spots[rng:random(1, #spots)]
      builder:addActor(prism.actors.Sword(), torchSpot.x, torchSpot.y)
   end

   if #spots > 0 then
      local scoutSpot = spots[rng:random(1, #spots)]
      builder:addActor(prism.actors.ScoutTorch(), scoutSpot.x, scoutSpot.y)
   end

   return true
end

return ThrumbleScoutDecorator
