--- @class GobFaction : Component
--- @overload fun(): GobFaction
local GobFaction = prism.components.Faction:extend "GobFaction"

function GobFaction:getEnemies()
   return { prism.components.ThrumbleFaction, prism.components.PlayerFaction }
end

return GobFaction
