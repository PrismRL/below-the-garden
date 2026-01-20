local DISTANCE = 4
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

Tongue.targets = { prism.Target():isVector2():optional(), target }

function Tongue:canPerform(level, actor, direction)
   local tongue = self.owner:expect(prism.components.Equipper):get("held")
   return not not (actor or direction) and tongue and tongue:has(prism.components.Tonguer)
end

--- @param level Level
--- @param direction? Vector2
--- @param actor? Actor
function Tongue:perform(level, direction, actor)
   local position = self.owner:expectPosition()
   --- @diagnostic disable-next-line
   direction = direction or (actor:expectPosition() - position):normalize()
   actor = nil
   --- @cast actor Actor

   local maxPosition = position + (direction * DISTANCE)
   local path = prism
      .Bresenham(position.x + direction.x, position.y + direction.y, maxPosition.x, maxPosition.y, function(cx, cy)
         for _, new in ipairs(level:query():target(target, level, self.owner):at(cx, cy):gather()) do
            if not actor then
               actor = new
            elseif new:has(prism.components.Health) then
               actor = new
            end
         end
         if not level:getCellPassable(cx, cy, TONGUE_MASK) or actor then return false end
         return true
      end)
      :getPath()

   if #path == 0 then return end

   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Tongue(
         direction,
         #path > 0 and #path + 1 or 0,
         (actor and actor:has(prism.components.ConditionHolder) and actor) or nil,
         self.owner:has(prism.components.PlayerController) and true or false
      ),
      actor = self.owner,
      blocking = true,
   })

   if not actor then return end

   local conditions = actor:get(prism.components.ConditionHolder)
   if conditions then conditions:add(prism.conditions.Stunned()) end

   local previousMover = actor:get(prism.components.Mover)
   actor:give(prism.components.Mover { "fly" })
   for i = #path, 1, -1 do
      level:moveActor(actor, path[i])
      level:getSystem(prism.systems.SensesSystem):triggerRebuild(level, self.owner)
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Wait(0.03),
         blocking = true,
      })
   end
   actor:remove(prism.components.Mover)
   if previousMover then actor:give(previousMover) end
   level:moveActor(actor, self.owner:expectPosition() + direction)
end

return Tongue
