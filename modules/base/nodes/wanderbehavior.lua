--- @class WanderBehavior : BehaviorTree.Node
local WanderBehavior = prism.BehaviorTree.Node:extend("WanderBehavior")

function WanderBehavior:run(level, actor, controller)
   local mover = actor:get(prism.components.Mover)
   if not mover then return end

   local mask = mover.mask

   local origin = actor:expectPosition()
   local wander = actor:get(prism.components.Wanderer)
   print("WOAH", wander, wander.goal)
   if not wander or not wander.goal then return end

   local path = level:findPath(origin, wander.goal, actor, mask)
   print("PATH", path)
   if not path then return false end

   print "ACTION"
   local action = prism.actions.Move(actor, path:pop())

   if level:canPerform(action) then
      print "SUCCESS"
      return action
   end

   return false
end

return WanderBehavior
