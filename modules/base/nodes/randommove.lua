--- @class RandomMoveBehavior : BehaviorTree.Node
local RandomMoveBehavior = prism.BehaviorTree.Node:extend("RandomMoveBehavior")

function RandomMoveBehavior:run(level, actor, controller)
   local vec = prism.Vector2.neighborhood8[level.RNG:random(1, 8)]
   local action = prism.actions.Move(actor, actor:getPosition() + vec)

   if level:canPerform(action) then
      return action
   else
      return false
   end
end

return RandomMoveBehavior
