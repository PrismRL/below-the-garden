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

   local start = self.owner:expectPosition()
   local maximumDistance = self.owner:expect(prism.components.Thrower):getRange()

   local path = prism.Bresenham(start.x, start.y, position.x, position.y, function(cx, cy)
      local distance = start:distance(prism.Vector2(cx, cy))
      if not level:getCellPassable(cx, cy, throwMask) or distance >= maximumDistance then return false end
      return true
   end)
   if path:length() == 0 then return end
   position = path.path[#path.path]

   level:perform(prism.actions.Unequip(self.owner, held))
   held:give(prism.components.Position(start))

   if held:get(prism.components.SlimeProducer) then
      local ox, oy = self.owner:expectPosition():decompose()
      local tx, ty = position:decompose()
      local path = prism.Bresenham(ox, oy, tx, ty)

      for i, cell in ipairs(path:getPath()) do
         level:addActor(prism.actors.Slime(), cell.x, cell.y)
      end
   end

   local previousMover = held:get(prism.components.Mover)
   held:give(prism.components.Mover { "fly" })
   for _, point in ipairs(path:getPath()) do
      level:moveActor(held, point)
      level:getSystem(prism.systems.SensesSystem):triggerRebuild(level, self.owner)
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Wait(0.04),
         blocking = true,
      })
   end
   held:remove(prism.components.Mover)
   if previousMover then held:give(previousMover) end

   local damage = self.owner:expect(prism.components.Thrower):getDamage()
   level:tryPerform(prism.actions.Damage(object, damage))

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
