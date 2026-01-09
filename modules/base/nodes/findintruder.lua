--- @class FindIntruderBehavior : BehaviorTree.Conditional
local FindIntruderBehavior =
   prism.BehaviorTree.Conditional:extend("FindIntruderBehavior")

--- @param range number Maximum distance from home an intruder can be
--- @param alert boolean?
function FindIntruderBehavior:__new(range, alert)
   self.range = range or math.huge
   self.alert = alert or false
end

function FindIntruderBehavior:run(level, actor, controller)
   local home = actor:getRelation(prism.relations.Home)
   if not home then return false end
   --- @cast home Actor

   local homePos = home:expectPosition()
   local bestD = math.huge
   local closest

   for candidate, _ in actor:expect(prism.components.Senses)
      :query(level, prism.components.Health)
      :iter()
   do
      if
         candidate ~= actor
         and prism.components.Faction.isEnemy(actor, candidate)
      then
         local candidatePos = candidate:getPosition()
         if candidatePos then
            local dHome = candidatePos:getRange(homePos)
            if dHome <= self.range and dHome < bestD then
               bestD = dHome
               closest = candidate
            end
         end
      end
   end

   -- Optional alert animation
   if self.alert and closest
      and controller.blackboard.previous ~= closest
   then
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Alert(),
         actor = actor,
         y = -1,
      })
   end

   -- Fallback to last seen position
   if not closest then
      local lseen = actor:get(prism.components.LastSeen)
      if lseen and lseen.position then
         controller.blackboard.target = lseen.position
         return true
      end
      return false
   end

   controller.blackboard.target = closest
   return true
end

return FindIntruderBehavior
