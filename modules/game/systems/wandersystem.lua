--- @class WanderSystem : System
local WanderSystem = prism.System:extend "WanderSystem"

function WanderSystem:onTurn(level, actor)
   local wander = actor:get(prism.components.Wanderer)
   if not wander then return end

   wander.timer = (wander.timer or 0) + 1

   local halfPeriod = math.floor(wander.period / 2)
   local active = (wander.timer - 1) % wander.period < halfPeriod

   if not active then
      wander.goal = nil
      return
   end

   -- decrement cooldown
   wander.cooldown = wander.cooldown - 1

   -- only allow goal selection if:
   -- 1) cooldown fired, OR
   -- 2) we are active and have no goal
   local needsGoal = (wander.goal == nil) or (wander.cooldown <= 0)

   if not needsGoal then return end

   -- reset cooldown only when it actually fires
   if wander.cooldown <= 0 then
      wander.cooldown = wander._cooldown
   end

   local origin = actor:expectPosition()
   local mask = actor:expect(prism.components.Mover).mask

   local candidates = {}

   prism.breadthFirstSearch(origin,
      function(x, y, depth)
         return level:getCellPassableByActor(x, y, actor, mask)
            and depth <= math.floor(wander._cooldown/2)
      end,
      function(x, y, depth)
         if depth == math.floor(wander._cooldown/2) then
            candidates[#candidates + 1] = prism.Vector2(x, y)
         end
      end
   )

   print(#candidates)
   if #candidates > 0 then
      wander.goal = candidates[level.RNG:random(#candidates)]
   end
end

return WanderSystem
