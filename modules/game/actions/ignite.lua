--- @class Ignite : Action
--- @overload fun(owner: Actor, ...): Ignite
local Ignite = prism.Action:extend "Ignite"
Ignite.requiredComponents = { prism.components.Senses, prism.components.Equipper }
Ignite.targets = { prism.Target(prism.components.Ignitable):range(1):sensed() }

function Ignite:canPerform(level, actor)
   local equipper = self.owner:expect(prism.components.Equipper)
   return (equipper:get("held") and equipper:get("held"):has(prism.components.Fire))
      and not actor:has(prism.components.Lit)
end

--- @param level Level
--- @param actor Actor
function Ignite:perform(level, actor)
   local ignitable = actor:expect(prism.components.Ignitable)
   --- @type Actor
   local light = prism.actors[ignitable.light]()
   light:addRelation(prism.relations.Ignited, actor)
   local position = actor:expectPosition()
   -- level:removeActor(actor)
   actor:give(prism.components.Lit())
   level:addActor(light, position.x + (ignitable.x or 0), position.y + (ignitable.y or 0))
end

return Ignite
