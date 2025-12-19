--- @class FindWeaponBehavior : BehaviorTree.Node
local FindWeaponBehavior = prism.BehaviorTree.Node:extend("FindWeaponBehavior")

function FindWeaponBehavior:run(level, actor, controller)
   local weapon = actor:expect(prism.components.Senses):query(level, prism.components.Equipment):first()
   controller.blackboard["target"] = weapon
   return not not weapon
end

return FindWeaponBehavior
