--- @class Fall : Action
--- @overload fun(owner: Actor): Fall
local Fall = prism.Action:extend "Fall"
Fall.requiredComponents = { prism.components.Position }

function Fall:canPerform(level)
   local x, y = self.owner:getPosition():decompose()
   local cell = level:getCell(x, y)
   print(cell:has(prism.components.Void))

   -- We can only fall on cells that are voids.
   if not cell:has(prism.components.Void) then return false end

   local cellMask = cell:getCollisionMask()
   local mover = self.owner:get(prism.components.Mover)
   if mover then
      -- We have a Void component on the cell. If the actor CAN'T move here
      -- then they fall.
      return not prism.Collision.checkBitmaskOverlap(cellMask, mover.mask)
   end

   return true
end

function Fall:perform(level)
   level:yield(prism.messages.AnimationMessage {
      animation = spectrum.animations.Fall(self.owner),
      blocking = true,
      actor = self.owner,
      override = true,
   })
   level:perform(prism.actions.Die(self.owner, true))
end

return Fall
