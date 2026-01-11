--- @class FrogFaction : Component
--- @overload fun(): FrogFaction
local FrogFaction = prism.components.Faction:extend "FrogFaction"

function FrogFaction:getEnemies()
   return { prism.components.GobFaction, prism.components.SqeetoFaction, prism.components.PlayerFaction }
end

return FrogFaction
