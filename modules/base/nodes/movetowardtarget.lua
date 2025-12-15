--- @class MoveTowardTargetBehavior : BehaviorTree.Node
local MoveTowardTargetBehavior = prism.BehaviorTree.Node:extend("MoveTowardTargetBehavior")
MoveTowardTargetBehavior.minDistance = 0

--- @param minDistance integer
function MoveTowardTargetBehavior:__new(minDistance)
   self.minDistance = minDistance
end

function MoveTowardTargetBehavior:run(level, actor, controller)
   local target = controller.blackboard["target"]
   if prism.Actor:is(target) then target = target:expectPosition() end
   local mover = actor:expect(prism.components.Mover)
   local path = level:findPath(actor:getPosition(), target, actor, mover.mask, self.minDistance)
   if not path then return false end

   local action = prism.actions.Move(actor, path:pop())

   if level:canPerform(action) then
      return action
   else
      return false
   end
end

return MoveTowardTargetBehavior
