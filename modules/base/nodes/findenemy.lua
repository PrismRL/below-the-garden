--- @class FindEnemyBehavior : BehaviorTree.Node
local FindEnemyBehavior = prism.BehaviorTree.Conditional:extend("FindEnemyBehavior")

function FindEnemyBehavior:run(level, actor, controller)
   local closest
   local bestD = math.huge
   for candidate, _ in actor:expect(prism.components.Senses):query(level, prism.components.Health):iter() do
      if prism.components.Faction.isEnemy(actor, candidate) then
         local distance = actor:getRange(candidate)

         if distance < bestD then
            closest = candidate
         end
      end
   end

   controller.blackboard["target"] = closest
   return not not closest
end

return FindEnemyBehavior
