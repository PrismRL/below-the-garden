--- @class SmokeSystem : System
local SmokeSystem = prism.System:extend "SmokeSystem"

local smokeMask = prism.Collision.getMovetypeByName("fly")
function SmokeSystem:onTurn(level, actor)
   if not actor:has(prism.components.PlayerController) then return end

   local toRemove = level:query(prism.components.Smoke):gather()
   for _, smoke in ipairs(toRemove) do
      level:removeActor(smoke)
   end

   local toRemove = {}
   for actor, emitter in level:query(prism.components.SmokeEmitter):iter() do
      prism.bfs(actor:expectPosition(), function (x, y, depth)
         return level:getCellPassable(x, y, smokeMask) and depth <= emitter.radius
      end,
      function (x, y)
         level:addActor(prism.actors.Smoke(), x, y)
      end)

      emitter.turnsUntilDecay = emitter.turnsUntilDecay - 1

      if emitter.turnsUntilDecay < 0 and emitter.decay then
         emitter.radius = emitter.radius - emitter.decay

         if emitter.radius <= 0 and emitter.remove then
            table.insert(toRemove, actor)
         end
      end
   end

   for _, actor in ipairs(toRemove) do
      level:removeActor(actor)
   end
end

return SmokeSystem