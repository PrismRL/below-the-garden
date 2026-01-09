--- @class FindLootBehavior : BehaviorTree.Node
local FindLootBehavior = prism.BehaviorTree.Node:extend("FindLootBehavior")

function FindLootBehavior:run(level, actor, controller)
   local home = actor:getRelation(prism.relations.Home)
   local equipper = actor:expect(prism.components.Equipper)
   if equipper:get("weapon") or equipper:get("held") then return false end

   local senses = actor:expect(prism.components.Senses)

   local bestPos
   local bestDist = math.huge

   --- @param entities Actor[]
   local function consider(entities)
      for _, e in ipairs(entities) do
         local d = e:getRange(actor)
         if not e:has(prism.components.Mover) then
            if d < bestDist and e:getRange(home) > 2 then
               bestDist = d
               bestPos = e
            end
         end
      end
   end

   consider(senses:query(level, prism.components.Equipment):gather())

   if bestPos then
      controller.blackboard["target"] = bestPos
      return true
   end

   return false
end

return FindLootBehavior
