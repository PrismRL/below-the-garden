--- The TelepathySystem manages telepathic awareness between actors.
--- It does not reveal terrain or cells, only other actors with controllers
--- within a fixed range.
--- @class TelepathySystem : System
local TelepathySystem = prism.System:extend("TelepathySystem")

function TelepathySystem:getRequirements()
   return prism.systems.SensesSystem
end

---@param level Level
---@param actor Actor
function TelepathySystem:onSenses(level, actor)
   local sensesComponent = actor:get(prism.components.Senses)
   if not sensesComponent then return end
   --- @cast sensesComponent Senses

   local range = 0
   local conditionHolder = actor:get(prism.components.ConditionHolder)
   if conditionHolder then
      local telepathies = conditionHolder:getModifiers(prism.modifiers.TelepathyModifier)
      for _, telepathy in pairs(telepathies) do
         range = math.max(range, telepathy.range)
      end
   end

   local telepathyComponent = actor:get(prism.components.Telepathy)
   if telepathyComponent then range = math.max(range, telepathyComponent:getRange()) end

   actor:removeAllRelations(prism.relations.Telepathed)
   if range == 0 then return end
   --- @cast telepathyComponent Telepathy

   local actorPos = actor:getPosition()
   if not actorPos then return end

   local r2 = range * range

   for other, _ in level:query(prism.components.Controller):iter() do
      if other ~= actor then
         local otherPos = other:getPosition()
         if otherPos then
            local dx = otherPos.x - actorPos.x
            local dy = otherPos.y - actorPos.y
            if dx * dx + dy * dy <= r2 then
               actor:addRelation(prism.relations.SensesRelation, other)
               actor:addRelation(prism.relations.TelepathedRelation, other)
            end
         end
      end
   end
end

return TelepathySystem
