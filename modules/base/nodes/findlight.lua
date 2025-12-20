--- @class FindLightBehavior : BehaviorTree.Node
local FindLightBehavior = prism.BehaviorTree.Conditional:extend("FindLightBehavior")

function FindLightBehavior:run(level, actor, controller)
   local target
   local lightLevel = 0
   for other, light in actor:expect(prism.components.Senses):query(level, prism.components.Light):iter() do
      --- @cast light Light
      if light.radius > lightLevel then
         target = other
         lightLevel = light.radius
      end
   end
   if target then print(target:getName()) end
   controller.blackboard["target"] = target
   return not not target
end

return FindLightBehavior
