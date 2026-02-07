--- @class SmokeSystem : System
local SmokeSystem = prism.System:extend "SmokeSystem"

local smokeMask = prism.Collision.getMovetypeByName("fly")

function SmokeSystem:__new()
   self._lastComponents = {}
end

function SmokeSystem:onTurn(level, actor)
   if not actor:has(prism.components.PlayerController) then return end

   -- Collect components from current emitters
   local currentComponents = {}

   for _, emitter in level:query(prism.components.SmokeEmitter):iter() do
      if emitter.component then
         currentComponents[emitter.component] = true
      end
   end

   -- Remove smoke for current + no-longer-existing components
   for component in pairs(currentComponents) do
      self._lastComponents[component] = true
   end

   for component in pairs(self._lastComponents) do
      local toRemove = level:query(component):gather()
      for _, smoke in ipairs(toRemove) do
         level:removeActor(smoke)
      end
   end

   -- Process emitters and spawn new actors
   local emittersToRemove = {}

   for emitterActor, emitter in level:query(prism.components.SmokeEmitter):iter() do
      prism.breadthFirstSearch(
         emitterActor:expectPosition(),
         function(x, y, depth)
            return level:getCellPassable(x, y, smokeMask)
               and depth <= emitter.radius
         end,
         function(x, y)
            level:addActor(emitter.actor(), x, y)
         end
      )

      emitter.turnsUntilDecay = emitter.turnsUntilDecay - 1

      if emitter.turnsUntilDecay < 0 and emitter.decay then
         emitter.radius = emitter.radius - emitter.decay

         if emitter.radius < 0 and emitter.remove then
            table.insert(emittersToRemove, emitterActor)
         elseif emitter.radius < 0 and emitter.loop then
            emitter.radius = emitter._radius
            emitter.decay = emitter._decay
            emitter.turnsUntilDecay = emitter._turnsUntilDecay
         end
      end
   end

   for _, emitterActor in ipairs(emittersToRemove) do
      level:removeActor(emitterActor)
   end

   -- Store components for next turn
   self._lastComponents = currentComponents
end

return SmokeSystem
