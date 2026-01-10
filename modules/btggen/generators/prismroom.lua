local util = prism.levelgen.util

--- @class PrismRoom : Generator
local PrismRoom = prism.levelgen.Generator:extend "PrismRoom"

function PrismRoom.generate(generatorInfo, player)
   local seed = generatorInfo.seed
   local w, h = generatorInfo.w, generatorInfo.h
   local depth = generatorInfo.depth

   local rng = prism.RNG(seed)
   local builder = prism.LevelBuilder()


   builder:rectangle("fill", 10, 2, generatorInfo.w - 10, generatorInfo.h - 1, prism.cells.Floor)
   coroutine.yield(builder)

   local wallDistanceField = util.buildWallDistanceField(builder)
   local rm = prism.levelgen.RoomManager(builder, wallDistanceField)
   local room = rm.rooms[1]

   prism.decorators.ErosionDecorator.tryDecorate(generatorInfo, rng, builder)
   builder:rectangle("line", 1, 1, generatorInfo.w, generatorInfo.h, prism.cells.Wall)
   coroutine.yield(builder)
   
   prism.decorators.PitDecorator.tryDecorate(generatorInfo, rng, builder, room)
   coroutine.yield(builder)

   prism.decorators.GlowStalkDecorator.tryDecorate(generatorInfo, rng, builder)
   coroutine.yield(builder)

   local wallDistanceField = util.buildWallDistanceField(builder)
   local rm = prism.levelgen.RoomManager(builder, wallDistanceField)
   local im = rm:getImportantRooms()
   
   builder:addActor(player, im[1].center:decompose())
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

   prism.decorators.FireflyDecorator.tryDecorate(generatorInfo, rng, builder)
   --coroutine.yield(builder)

   return builder
end

return PrismRoom
