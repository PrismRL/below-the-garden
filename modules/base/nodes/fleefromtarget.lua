--- @class FleeFromTargetBehavior : BehaviorTree.Node
local FleeFromTargetBehavior = prism.BehaviorTree.Node:extend("FleeFromTargetBehavior")

function FleeFromTargetBehavior:run(level, actor, controller)
   local target = controller.blackboard["target"]
   if prism.Actor:is(target) then
      target = target:expectPosition()
   end

   local pos = actor:getPosition()
   local delta = pos - target

   local dx, dy = delta:decompose()
   if dx ~= 0 then dx = dx / math.abs(dx) end
   if dy ~= 0 then dy = dy / math.abs(dy) end

   local dest = pos + prism.Vector2(dx, dy)
   local action = prism.actions.Move(actor, dest)

   if level:canPerform(action) then
      return action
   end

   return false
end

return FleeFromTargetBehavior
