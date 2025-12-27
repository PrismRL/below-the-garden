--- @class ThrumbleFaction : Component
--- @overload fun(): ThrumbleFaction
local ThrumbleFaction = prism.components.Faction:extend "ThrumbleFaction"

function ThrumbleFaction:getEnemies()
   return {prism.components.SqeetoFaction, prism.components.PlayerFaction}
end
return ThrumbleFaction