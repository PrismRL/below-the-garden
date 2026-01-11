local util = prism.levelgen.util

--- @class PrismRoom : Generator
local PrismRoom = prism.levelgen.Generator:extend "PrismRoom"

function PrismRoom.generate(generatorInfo, player)
   local seed = generatorInfo.seed
   local w, h = generatorInfo.w, generatorInfo.h

   local rng = prism.RNG(seed)
   local builder = prism.LevelBuilder()

   local cx = math.floor(w * 0.5)
   local cy = math.floor(h * 0.3)

   local rx = math.floor((h - 5) * 0.25)
   local ry = rx

   builder:ellipse(
      "fill",
      cx,
      cy,
      rx,
      ry,
      prism.cells.Floor
   )

   coroutine.yield(builder)

   local path = prism.astar((prism.Vector2(w, h)/2):floor(), prism.Vector2(cx, cy), function (x, y)
      return true
   end,
   function (x, y)
      return util.isFloor(builder, x, y) and 1 or love.math.noise(x, y) * 3
   end)

   for i = 1, #path.path do
      builder:set(path.path[i].x, path.path[i].y, prism.cells.Floor())
   end
   coroutine.yield(builder)

   local wallDistanceField = util.buildWallDistanceField(builder)
   local rm = prism.levelgen.RoomManager(builder, wallDistanceField)
   local room = rm.rooms[1]

   prism.decorators.ErosionDecorator.tryDecorate(generatorInfo, rng, builder)
   builder:rectangle("line", 1, 1, generatorInfo.w, generatorInfo.h, prism.cells.Wall)
   coroutine.yield(builder)
   
   prism.decorators.WaterPitDecorator.tryDecorate(generatorInfo, rng, builder, room)
   coroutine.yield(builder)

   --prism.decorators.GlowStalkDecorator.tryDecorate(generatorInfo, rng, builder)
   coroutine.yield(builder)

   local wallDistanceField = util.buildDistanceField(builder, function (builder, x, y)
      return not util.isWalkable(builder, x, y)
   end,
   function (builder, x, y)
      return util.isFloor(builder, x, y)
   end)
   local rm = prism.levelgen.RoomManager(builder, wallDistanceField)
   local im = rm:getImportantRooms()
   
   for i = 1, 3 do
      prism.decorators.SunlightDecorator.tryDecorate(generatorInfo, rng, builder, rm.rooms[rng:random(#rm.rooms)])
   end

   --builder:addActor(player, im[1].center:decompose())
   coroutine.yield(builder)

   local best, bestD = nil, 0
   for x = 1, generatorInfo.w do
      for y = 1, generatorInfo.h do
         local d = wallDistanceField:get(x, y)
         if d and d > bestD then
            best = prism.Vector2(x, y)
            bestD = d
         end
      end
   end
   builder:addActor(prism.actors.Crystal(), best:decompose())
   coroutine.yield(builder)
   
      -- Distance field from the crystal
   local crystalDistanceField = util.buildDistanceField(
      builder,
      function(builder, x, y)
         return x == best.x and y == best.y
      end,
      util.isWalkable
   )

   -- Find furthest walkable tile from the crystal
   local bestPlayerPos, bestDist = nil, 0
   for x = 1, w do
      for y = 1, h do
         if util.isWalkable(builder, x, y) then
            local d = crystalDistanceField:get(x, y)
            if d and d > bestDist then
               bestPlayerPos = prism.Vector2(x, y)
               bestDist = d
            end
         end
      end
   end

   builder:addActor(player, bestPlayerPos:decompose())
   builder:addActor(prism.actors.Torch(), bestPlayerPos:decompose())
   coroutine.yield(builder)

   prism.decorators.BridgeToFloorDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   prism.decorators.TallGrassNearWallsDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   prism.decorators.GrassSpreadDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   --prism.decorators.GlowStalkDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   prism.decorators.PruneMisalignedDoorsDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   for x = 1, w do
      for y = 1, h do
         if not builder:get(x, y) then builder:set(x, y, prism.cells.Wall()) end
      end
   end
   coroutine.yield(builder)

   prism.decorators.FireflyDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   return builder
end

return PrismRoom
