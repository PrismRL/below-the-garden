local util = prism.levelgen.util

local ItemSpawnerDecorator = prism.levelgen.Decorator:extend "ItemSpawnerDecorator"

--- Spawns exactly one item using standard candidate logic.
--- @param rng RNG
--- @param builder LevelBuilder
--- @param room Room
--- @param itemFactory function Function returning an actor (e.g. prism.actors.Pebble)
function ItemSpawnerDecorator.tryDecorate(rng, builder, room, itemFactory)
   if not room.size or room.size < 1 then return end
   if not itemFactory then return end

   local candidates = {}

   for x, y in room.tiles:each() do
      if util.isEmptyFloor(builder, x, y) then
         candidates[#candidates + 1] = { x = x, y = y }
      end
   end

   if #candidates == 0 then return end

   for i = #candidates, 2, -1 do
      local j = rng:random(1, i)
      candidates[i], candidates[j] = candidates[j], candidates[i]
   end

   local p = candidates[1]
   builder:addActor(itemFactory(), p.x, p.y)

   return true
end

return ItemSpawnerDecorator
