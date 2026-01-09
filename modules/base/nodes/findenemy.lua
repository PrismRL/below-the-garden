--- @class FindEnemyBehavior : BehaviorTree.Node
local FindEnemyBehavior = prism.BehaviorTree.Conditional:extend("FindEnemyBehavior")

--- @param alert boolean
function FindEnemyBehavior:__new(alert, maxRange, maxRangeNPC)
   self.alert = alert
   self.maxRange = maxRange
   self.maxRangeNPC = maxRangeNPC
end

function FindEnemyBehavior:run(level, actor, controller)
   local maxRange = self.maxRange or math.huge
   local maxRangeNPC = self.maxRangeNPC or math.huge
   local bestD = math.huge
   local closest

   for candidate, _ in actor:expect(prism.components.Senses)
      :query(level, prism.components.Health)
      :iter()
   do
      if candidate ~= actor and prism.components.Faction.isEnemy(actor, candidate) then
         print("CANDIDATE: ", prism.components.Name.get(candidate))
         local distance = actor:getRange(candidate)

         local maxAllowed =
            actor:get(prism.components.PlayerController)
            and maxRange
            or maxRangeNPC

         if distance < bestD and distance < maxAllowed then
            bestD = distance
            closest = candidate
         end
      end
   end


   if self.alert and closest and controller.blackboard["previous"] ~= closest then
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Alert(),
         actor = actor,
         y = -1,
      })
   end

   if not closest then
      local lseen = actor:get(prism.components.LastSeen)
      if lseen then
         if lseen.position then closest = lseen.position end
      end
   end

   if closest then
      print(not not closest, prism.components.Name.get(closest))
   end
   controller.blackboard["target"] = closest
   return not not closest
end

return FindEnemyBehavior
