--- @class Sing : Action
--- @overload fun(owner: Actor, ...): Sing
local Sing = prism.Action:extend "Sing"
Sing.targets = { prism.Target(prism.components.PlayerController):range(3) }

--- @param level Level
function Sing:canPerform(level)
   return true
end

--- @param level Level
function Sing:perform(level)
   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Sing(),
      actor = self.owner,
      y = -1,
   })
end

return Sing
