local DISTANCE = 3
local TONGUE_MASK = prism.Collision.createBitmaskFromMovetypes { "fly" }

--- @class Tongue : Action
--- @overload fun(owner: Actor, ...): Tongue
local Tongue = prism.Action:extend "Tongue"
Tongue.name = "grab"
local target = prism
   .Target()
   :isActor()
   :range(DISTANCE)
   :optional()
   :filter(function(level, owner, targetObject, previousTargets)
      local moveable = targetObject:has(prism.components.Health) or targetObject:has(prism.components.Equipment)
      local position = owner:expectPosition()
      local other = targetObject:expectPosition()
      return moveable and position.x == other.x or position.y == other.y
   end)

Tongue.targets = { target, prism.Target():isVector2():optional() }

function Tongue:canPerform(level, actor, direction)
   local tongue = self.owner:expect(prism.components.Equipper):get("held")
   return not not (actor or direction) and tongue and tongue:has(prism.components.Tonguer)
end

--- @param level Level
--- @param direction? Vector2
--- @param actor? Actor
function Tongue:perform(level, actor, direction)
   local position = self.owner:expectPosition()
   direction = direction or (actor:expectPosition() - position):normalize()
   actor = nil

   local distance = 0
   while not actor and distance < DISTANCE do
      position = position + direction
      for _, new in ipairs(level:query():target(target, level, self.owner):at(position:decompose()):gather()) do
         if not actor then
            actor = new
         elseif new:has(prism.components.Health) then
            actor = new
         end
      end
      distance = distance + 1
      if not level:getCellPassable(position.x, position.y, TONGUE_MASK) then break end
   end

   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.FrogTongue(
         direction,
         distance,
         self.owner:has(prism.components.PlayerController) and true or false
      ),
      actor = self.owner,
      blocking = true,
   })
   if not actor then return end
   level:moveActor(actor, self.owner:expectPosition() + direction)
end

return Tongue
