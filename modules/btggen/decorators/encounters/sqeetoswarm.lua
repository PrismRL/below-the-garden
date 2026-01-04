local util = prism.levelgen.util

local SqeetoSwarmDecorator = prism.levelgen.Decorator:extend "SqeetoSwarmDecorator"

local flyMask = prism.Collision.getMovetypeByName("fly")
function SqeetoSwarmDecorator.tryDecorate(rng, builder, room)
   local candidates = {}

   for x, y in room.tiles:each() do
      if util.isWalkable(builder, x, y, flyMask) then
         candidates[#candidates + 1] = { x = x, y = y }
      end
   end

   local count = 3

   ----------------------------------------------------------------
   -- Shuffle candidates
   ----------------------------------------------------------------
   for i = #candidates, 2, -1 do
      local j = rng:random(1, i)
      candidates[i], candidates[j] = candidates[j], candidates[i]
   end

   for i = 1, math.min(count, #candidates) do
      local p = candidates[i]
      builder:addActor(prism.actors.Sqeeto(), p.x, p.y)
   end

   return true
end

return SqeetoSwarmDecorator
