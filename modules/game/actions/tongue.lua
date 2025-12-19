--- @class Tongue : Action
--- @overload fun(owner: Actor, ...): Tongue
local Tongue = prism.Action:extend "Tongue"
Tongue.targets = {
   prism.Target():sensed():isActor():range(3):filter(function(level, owner, targetObject, previousTargets)
      local position = owner:expectPosition()
      local other = targetObject:expectPosition()

      return position.x == other.x or position.y == other.y
   end),
}

--- @param level Level
function Tongue:canPerform(level, actor)
   return true
end

--- @param level Level
--- @param actor Actor
function Tongue:perform(level, actor)
   local position = self.owner:expectPosition()
   local other = actor:expectPosition()
   local direction = (other - position):normalize()
   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.FrogTongue(),
      actor = self.owner,
      blocking = true,
   })
   level:moveActor(actor, position + direction)
end

return Tongue
