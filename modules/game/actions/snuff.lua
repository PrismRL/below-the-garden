--- @class Snuff : Action
--- @overload fun(owner: Actor, ...): Snuff
local Snuff = prism.Action:extend "Snuff"
Snuff.targets = { prism.Target(prism.components.Snuffable):isActor() }

--- @param level Level
--- @param fire Actor
function Snuff:perform(level, fire)
   local fuel = fire:getRelation(prism.relations.Ignited)
   if fuel then fuel:remove(prism.components.Lit) end
   fire:removeAllRelations(prism.relations.Ignited)
   level:removeActor(fire)
end

return Snuff
