--- @class SlimeTrailSystem : System
local SlimeTrailSystem = prism.System:extend "SlimeTrailSystem"

function SlimeTrailSystem:onTurn(level, actor)
   if not actor:get(prism.components.PlayerController) then return end

   for _, actor in ipairs(level:query(prism.components.Slime):gather()) do
      local slime = actor:expect(prism.components.Slime)
      slime.lifetime = slime.lifetime - 1
      if slime.lifetime <= 0 then level:removeActor(actor) end
   end
end

return SlimeTrailSystem
