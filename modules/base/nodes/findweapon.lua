--- @class FindWeaponBehavior : BehaviorTree.Node
local FindWeaponBehavior = prism.BehaviorTree.Node:extend("FindWeaponBehavior")

function FindWeaponBehavior:run(level, actor, controller)
   if actor:expect(prism.components.Equipper):get("weapon") then return false end

   local senses = actor:expect(prism.components.Senses)

   local bestPos
   local bestDist = math.huge

   --- @param entities Actor[]
   local function consider(entities)
      for _, e in ipairs(entities) do
         local d = e:getRange(actor)
         if d < bestDist then
            bestDist = d
            bestPos = e
         end
      end
   end

   consider(senses:query(level, prism.components.Weapon):gather())
   consider(senses:query(level, prism.components.Torch):gather())

   if bestPos then
      controller.blackboard["target"] = bestPos
      return true
   end

   return false
end

return FindWeaponBehavior
