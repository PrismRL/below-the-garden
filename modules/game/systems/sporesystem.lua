--- @class SporeSystem : System
local SporeSystem = prism.System:extend "SporeSystem"

function SporeSystem:onTurn(level, actor)
   if not actor:has(prism.components.PlayerController) then return end

   for actor, emitter in level:query(prism.components.SporeEmitter) do
      if not emitter.time then emitter.time = 0 end

      if emitter.time == 0 then
      end
   end
end

return SporeSystem