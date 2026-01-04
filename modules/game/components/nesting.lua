--- @class Nesting : Component
--- @field nestType Component
--- @field nest Actor?
--- @overload fun(nestComponent: Component): Nesting
local Nesting = prism.Component:extend "Nesting"

function Nesting:__new(nestComponent)
   self.nestType = nestComponent
end

function Nesting.getNest(actor)
   local nesting = actor:get(prism.components.Nesting)
   if not nesting then
      return
   end

   return actor:getRelation(prism.relations.Home)
end
return Nesting