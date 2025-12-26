--- @class RandomCheckBehavior : BehaviorTree.Node
local RandomCheckBehavior = prism.BehaviorTree.Conditional:extend("RandomCheckBehavior")

--- @param chance number
function RandomCheckBehavior:__new(chance)
   self.chance = chance
end

function RandomCheckBehavior:run(level, actor, controller)
   return self.chance >= level.RNG:random()
end

return RandomCheckBehavior
