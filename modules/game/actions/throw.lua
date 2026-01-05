--- @class Throw : Action
--- @overload fun(owner: Actor, ...): Throw
local Throw = prism.Action:extend "Throw"
Throw.name = "thrw"
Throw.requiredComponents = { prism.components.Equipper, prism.components.Thrower }

local throwMask = prism.Collision.createBitmaskFromMovetypes { "fly" }
local target = prism.Target():excludeOwner()

Throw.targets = {
   target,
}

--- @param level Level
--- @param object Vector2|Actor
function Throw:canPerform(level, object)
   -- local position = object
   -- if prism.Actor:is(object) then position = object:expectPosition() end
   -- local held = self.owner:expect(prism.components.Equipper):get("held")
   -- return held and level:getCellPassableByActor(position.x, position.y, held, throwMask)
   return true
end

--- @param level Level
function Throw:perform(level, object)
   local held = self.owner:expect(prism.components.Equipper):get("held")
   --- @cast held Actor
   local position = object
   if prism.Actor:is(object) then position = object:expectPosition() end

   if position.x > level.map.w then position.x = level.map.w end
   if position.y > level.map.h then position.y = level.map.w end
   if position.x < 1 then position.x = 1 end
   if position.y < 1 then position.y = 1 end

   local path = nil
   local minimumDistance = 0

   while not path and minimumDistance < 32 do
      path = level:findPath(self.owner:expectPosition(), position, self.owner, throwMask, minimumDistance)
      minimumDistance = minimumDistance + 1
   end
   if not path then return end

   level:perform(prism.actions.Unequip(self.owner, held))

   local maximumDistance = self.owner:expect(prism.components.Thrower):getRange()
   position = path:length() > maximumDistance and path.path[maximumDistance] or path.path[#path.path]

   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Projectile(
         self.owner:expectPosition(),
         position,
         held:expect(prism.components.Drawable)
      ),
      blocking = true,
   })

   if held:get(prism.components.SlimeProducer) then
      local ox, oy = self.owner:expectPosition():decompose()
      local tx, ty = position:decompose()
      local path = prism.Bresenham(ox, oy, tx, ty)

      for i, cell in ipairs(path:getPath()) do
         level:addActor(prism.actors.Slime(), cell.x, cell.y)
      end
   end

   local damage = self.owner:expect(prism.components.Thrower):getDamage()
   level:tryPerform(prism.actions.Damage(object, damage))
   held:give(prism.components.Position(position))

   local explode = held:get(prism.components.ExplodeOnThrow)
   if explode then
      local tiles = prism.SparseGrid()
      local query = level:query(prism.components.Health)
      level:computeFOV(held:expectPosition(), explode.radius, function(x, y)
         tiles:set(x, y, true)
         query:at(x, y)
         for actor in query:iter() do
            local damage = prism.actions.Damage(actor, explode.damage)
            level:tryPerform(damage)
         end
      end)

      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Explosion(tiles),
      })

      level:removeActor(held)
   end

   local poof = held:get(prism.components.PoofOnThrow)
   if poof then
      level:addActor(prism.actors.PoofEmitter(), position:decompose())
      level:removeActor(held)
   end
end

return Throw
