--- @class SnipFaction : Component
--- @overload fun(): SnipFaction
local SnipFaction = prism.components.Faction:extend "SnipFaction"

function SnipFaction:getEnemies()
   return { prism.components.PlayerFaction }
end

return SnipFaction
