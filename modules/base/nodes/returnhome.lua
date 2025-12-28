--- @class ReturnHomeBehavior : BehaviorTree.Node
local ReturnHomeBehavior = prism.BehaviorTree.Node:extend("ReturnHomeBehavior")
ReturnHomeBehavior.distanceToHome = 15

--- @param distance integer
function ReturnHomeBehavior:__new(distance)
   self.distanceToHome = distance
end

function ReturnHomeBehavior:run(level, actor, controller)
   local home = actor:getRelation(prism.relations.Home)
   if not home then return false end
   --- @cast home Actor

   local distance = actor:getRange(home)
   if distance > self.distanceToHome then
      print("RETURNING HOME")
      local vec = prism.Vector2.neighborhood8[level.RNG:random(1, 8)]
      controller.blackboard["target"] = home:expectPosition() + vec
      return true
   end

   return false
end

return ReturnHomeBehavior
