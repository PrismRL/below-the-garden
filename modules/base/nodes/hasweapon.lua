--- @class HasWeaponBehavior : BehaviorTree.Node
local HasWeaponBehavior = prism.BehaviorTree.Conditional:extend("HasWeaponBehavior")

function HasWeaponBehavior:run(level, actor)
   local equipper = actor:expect(prism.components.Equipper)
   return equipper:get("weapon") ~= nil or equipper:get("held") ~= nil
end

return HasWeaponBehavior
