--- @class WanderSystem : System
local WanderSystem = prism.System:extend "WanderSystem"

function WanderSystem:onTurn(level, actor)
   if not actor:get(prism.components.Wanderer) then return end

   local wander = actor:get(prism.components.Wanderer)
   wander.cooldown = wander.cooldown - 1

   if wander.cooldown ~= 0 then return end
   wander.cooldown = wander._cooldown

   local origin = actor:expectPosition()
   local mask = actor:expect(prism.components.Mover).mask

   local bestDepth = -1
   local candidates = {}

   prism.bfs(origin,
      function(x, y, depth)
         return level:getCellPassableByActor(x, y, actor, mask) and depth <= 5
      end,
      function(x, y, depth)
         if depth > bestDepth then
            bestDepth = depth
            candidates = { prism.Vector2(x, y) }
         elseif depth == bestDepth then
            candidates[#candidates + 1] = prism.Vector2(x, y)
         end
      end
   )

   if #candidates > 0 then
      wander.goal = candidates[level.RNG:random(#candidates)]
   end
end

return WanderSystem
