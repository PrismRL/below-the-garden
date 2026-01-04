--- @class SqeetoFaction : Faction
--- @overload fun(): SqeetoFaction
local SqeetoFaction = prism.components.Faction:extend "SqeetoFaction"

function SqeetoFaction:getEnemies()
   return {prism.components.PlayerFaction, prism.components.ThrumbleFaction}
end

return SqeetoFaction
