--- @class FindWeaponBehavior : BehaviorTree.Node
local FindWeaponBehavior = prism.BehaviorTree.Node:extend("FindWeaponBehavior")

function FindWeaponBehavior:run(level, actor, controller)
   if actor:expect(prism.components.Equipper):get("weapon") then return false end
   local weapon = actor:expect(prism.components.Senses):query(level, prism.components.Equipment):first()
   if weapon then controller.blackboard["target"] = weapon end
   return not not weapon
end

return FindWeaponBehavior
