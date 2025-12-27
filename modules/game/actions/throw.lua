--- @class Throw : Action
--- @overload fun(owner: Actor, ...): Throw
local Throw = prism.Action:extend "Throw"
Throw.name = "thrw"
Throw.requiredComponents = { prism.components.Equipper, prism.components.Thrower }

local throwMask = prism.Collision.createBitmaskFromMovetypes { "fly" }
local target = prism.Target():los(throwMask):excludeOwner():filter(function(level, owner, targetObject, previousTargets)
   local range = owner:expect(prism.components.Thrower):getRange()
   local position = targetObject
   if prism.Actor:is(targetObject) then position = targetObject:expectPosition() end
   return owner:getRangeVec(position) <= range
end)
Throw.targets = {
   target,
}

--- @param level Level
function Throw:canPerform(level)
   return not not self.owner:expect(prism.components.Equipper):get("held")
end

--- @param level Level
function Throw:perform(level, object)
   local held = self.owner:expect(prism.components.Equipper):get("held")
   level:perform(prism.actions.Unequip(self.owner, held))
   local position = object
   if prism.Actor:is(object) then position = object:expectPosition() end
   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Projectile(
         self.owner:expectPosition(),
         position,
         held:expect(prism.components.Drawable)
      ),
      actor = held,
      blocking = true,
   })

   local damage = self.owner:expect(prism.components.Thrower):getDamage()
   level:tryPerform(prism.actions.Damage(object, damage))
   held:give(prism.components.Position(position))

   local explode = held:get(prism.components.ExplodeOnThrow)
   if explode then
      local query = level:query(prism.components.Health)
      level:computeFOV(held:expectPosition(), explode.radius, function (x, y)
         query:at(x, y)
         for actor in query:iter() do
            local damage = prism.actions.Damage(actor, explode.damage)
            level:tryPerform(damage)
         end
      end)

      level:removeActor(held)
   end
end

return Throw
