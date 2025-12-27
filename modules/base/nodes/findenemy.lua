--- @class FindEnemyBehavior : BehaviorTree.Node
local FindEnemyBehavior = prism.BehaviorTree.Conditional:extend("FindEnemyBehavior")

--- @param alert boolean
function FindEnemyBehavior:__new(alert)
   self.alert = alert
end

function FindEnemyBehavior:run(level, actor, controller)
   local closest
   local bestD = math.huge
   for candidate, _ in actor:expect(prism.components.Senses):query(level, prism.components.Health):iter() do
      if prism.components.Faction.isEnemy(actor, candidate) then
         local distance = actor:getRange(candidate)

         if distance < bestD then closest = candidate end
      end
   end

   if self.alert and closest and controller.blackboard["previous"] ~= closest then
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Alert(),
         actor = actor,
         y = -1,
      })
   end

   controller.blackboard["target"] = closest
   return not not closest
end

return FindEnemyBehavior
