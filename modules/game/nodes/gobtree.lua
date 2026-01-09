--- @class GobTree : BehaviorTree.Root
local GobTree = prism.BehaviorTree.Root:extend "GobTree"

local BT = prism.BehaviorTree

GobTree.children = {
   prism.nodes.WanderBehavior,
   prism.nodes.WaitBehavior,
}

return GobTree
