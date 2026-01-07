--- @class EyeTree : BehaviorTree.Root
local EyeTree = prism.BehaviorTree.Root:extend "EyeTree"

local BT = prism.BehaviorTree

EyeTree.children = {
   prism.nodes.RandomMoveBehavior,
   prism.nodes.WaitBehavior,
}

return EyeTree
