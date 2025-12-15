--- @class PickupWeaponBehavior : BehaviorTree.Node
local PickupWeaponBehavior = prism.BehaviorTree.Node:extend("PickupWeaponBehavior")

function PickupWeaponBehavior:run(level, actor, controller)
   local weapon = controller.blackboard["target"]
   local pickup = prism.actions.Equip(actor, weapon)
   return level:canPerform(pickup) and pickup or true
end

return PickupWeaponBehavior
