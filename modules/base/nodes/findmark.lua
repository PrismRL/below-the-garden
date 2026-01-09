--- @class FindMarkBehavior : BehaviorTree.Node
local FindMarkBehavior = prism.BehaviorTree.Conditional:extend("FindMarkBehavior")

--- @param alert boolean
function FindMarkBehavior:__new(alert, maxRange, maxRangeNPC)
   self.alert = alert
   self.maxRange = maxRange
   self.maxRangeNPC = maxRangeNPC
end


function FindMarkBehavior:run(level, actor, controller)
   local maxRange = self.maxRange or math.huge
   local maxRangeNPC = self.maxRangeNPC or math.huge
   local bestD = math.huge
   local closest

   print "FINDING CANDIDATE"
   for candidate, _, equipper in actor:expect(prism.components.Senses)
      :query(level, prism.components.Health, prism.components.Equipper)
      :iter()
   do
      print("TESTING CANDIDATE", prism.components.Faction.isEnemy(actor, candidate), candidate ~= actor)
      --- @cast equipper Equipper
      if candidate ~= actor and prism.components.Faction.isEnemy(actor, candidate) then
         local hasItem = equipper:get("pocket") ~= nil

         print("HASITEM", hasItem)
         if hasItem then
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
   end

   if not closest then
      local lseen = actor:get(prism.components.LastSeen)
      if lseen and lseen.position then
         closest = lseen.position
      end
   end

   controller.blackboard["target"] = closest
   return not not closest
end

return FindMarkBehavior