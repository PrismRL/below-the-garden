--- @class PlayerFaction : Component
--- @overload fun(): PlayerFaction
local PlayerFaction = prism.components.Faction:extend "PlayerFaction"

function PlayerFaction:getEnemies()
   return { prism.components.ThrumbleFaction, prism.components.SqeetoFaction, prism.components.GobFaction }
end

return PlayerFaction
