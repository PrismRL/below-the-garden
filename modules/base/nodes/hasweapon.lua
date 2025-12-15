--- @class HasWeaponBehavior : BehaviorTree.Node
local HasWeaponBehavior = prism.BehaviorTree.Conditional:extend("HasWeaponBehavior")

function HasWeaponBehavior:run(level, actor)
   return actor:expect(prism.components.Equipper):get("weapon") ~= nil
end

return HasWeaponBehavior
