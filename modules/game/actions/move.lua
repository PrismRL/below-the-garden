local MoveTarget = prism.Target():isVector2():range(1)

--- @class Move : Action
--- @field name string
--- @field targets Target[]
--- @field previousPosition Vector2
--- @overload fun(owner: Actor, destination: Vector2): Move
local Move = prism.Action:extend("Move")
Move.targets = { MoveTarget }

Move.requiredComponents = {
   prism.components.Controller,
   prism.components.Mover,
}

--- @param level Level
--- @param destination Vector2
function Move:canPerform(level, destination)
   local mover = self.owner:expect(prism.components.Mover)
   return level:getCellPassableByActor(destination.x, destination.y, self.owner, mover.mask)
end

--- @param level Level
--- @param destination Vector2
function Move:perform(level, destination)
   local slimeProducer = self.owner:get(prism.components.SlimeProducer)
   local mover = self.owner:expect(prism.components.Mover)
   local direction = destination - self.owner:expectPosition()

   local modified = false
   while not slimeProducer and level:query(prism.components.Slime):at(destination:decompose()):first() do
      local x, y = (destination + direction):decompose()
      if level:getCellPassableByActor(x, y, self.owner, mover.mask) then
         modified = true
         destination = destination + direction
      else
         break
      end
   end

   if modified then
      level:yield(prism.messages.AnimationMessage {
         animation = spectrum.animations.Projectile(
            self.owner:expectPosition(),
            destination,
            self.owner:expect(prism.components.Drawable)
         ),
         blocking = true,
      })
   end

   if slimeProducer then level:addActor(prism.actors.Slime(6), self.owner:expectPosition():decompose()) end
   level:moveActor(self.owner, destination)
end

return Move
