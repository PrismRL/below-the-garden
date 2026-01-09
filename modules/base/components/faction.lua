--- @class Faction : Component
--- @field set table<Faction, boolean>
--- @overload fun(): Faction
local Faction = prism.Component:extend "Faction"

function Faction:getEnemies()
   return {}
end

function Faction:buildSet()
   self.set = {}
   if not self.cache then self.cache = self:getEnemies() end
   for _, enemy in ipairs(self.cache) do
      self.set[enemy.className] = true
   end
end

--- @param owner Actor
---@param possibleEnemy Actor
function Faction.isEnemy(owner, possibleEnemy)
   local factionComp = owner:get(prism.components.Faction)
   print("SELF FACTION COMP", factionComp)
   if not factionComp then return false end
   if not factionComp.set then factionComp:buildSet() end

   local otherFactionComp = possibleEnemy:get(prism.components.Faction)
   if not otherFactionComp then return false end

   print(factionComp.className, factionComp.set[otherFactionComp.className])
   return factionComp.set[otherFactionComp.className]
end

return Faction
