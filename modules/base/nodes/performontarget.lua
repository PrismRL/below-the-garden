--- @class PerformOnBehavior : BehaviorTree.Node
local PerformOnBehavior = prism.BehaviorTree.Node:extend("PerformOnBehavior")

--- @param action Action
function PerformOnBehavior:__new(action, onOwner)
   self.action = action
   self.onOwner = onOwner or false
end

function PerformOnBehavior:run(level, actor, controller)
   local instance = self.action(actor, (not self.onOwner) and controller.blackboard["target"] or nil)
   print("HELLO", level:canPerform(instance))
   if level:canPerform(instance) then return instance end
   return true
end

return PerformOnBehavior
