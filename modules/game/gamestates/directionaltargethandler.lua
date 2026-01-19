local controls = require "controls"
local Name = prism.components.Name

--- @class DirectionalTargetHandler : TargetHandler
local DirectionalTargetHandler = spectrum.gamestates.TargetHandler:extend("DirectionalTargetHandler")

function DirectionalTargetHandler:getValidTargets()
   return prism.Vector2.neighborhood4
end

function DirectionalTargetHandler:init()
   self.super.init(self)
   self.curTarget = self.validTargets[1]
end

function DirectionalTargetHandler:update(dt)
   controls:update()
   self.display:update(self.level, dt)

   if controls.next.pressed then
      local lastTarget = self.curTarget
      self.index, self.curTarget = next(self.validTargets, self.index)

      while (not self.index and #self.validTargets > 0) or (lastTarget == self.curTarget and #self.validTargets > 1) do
         self.index, self.curTarget = next(self.validTargets, self.index)
      end
   end

   if (controls.select.pressed or controls.pickup.pressed) and self.curTarget then
      table.insert(self.targetList, self.curTarget)
      self.manager:pop()
   end

   if controls.back.pressed then self.manager:pop("pop") end

   if controls.move.pressed then self.curTarget = controls.move.vector end
end

function DirectionalTargetHandler:draw()
   local positions = self.levelState.hudPositions
   self.levelState:draw()
   self.display:clear()
   local x, y = self.owner:getPosition():decompose()
   if self.curTarget == prism.Vector2.RIGHT then
      self.display:put(x + self.camera.x + 1, y + self.camera.y, 13, prism.Color4.WHITE, prism.Color4.BLACK)
   elseif self.curTarget == prism.Vector2.LEFT then
      self.display:put(x + self.camera.x - 1, y + self.camera.y, 14, prism.Color4.WHITE, prism.Color4.BLACK)
   elseif self.curTarget == prism.Vector2.UP then
      self.display:put(x + self.camera.x, y + self.camera.y - 1, 15, prism.Color4.WHITE, prism.Color4.BLACK)
   elseif self.curTarget == prism.Vector2.DOWN then
      self.display:put(x + self.camera.x, y + self.camera.y + 1, 16, prism.Color4.WHITE, prism.Color4.BLACK)
   end
   self.display:print(positions.shift.x - 1, positions.shift.y - 1, "SHFT", prism.Color4.TEXT)
   self.display:print(positions.shift.x - 1, positions.throw.y, "T", prism.Color4.TEXT)
   self.display:print(positions.wait.x - 1, positions.wait.y - 1, "X", prism.Color4.TEXT)
   self.display:print(positions.drop.x - 1, positions.drop.y - 1, "V", prism.Color4.TEXT)

   love.graphics.push()
   love.graphics.translate(8, 8)
   self.display:draw()
   love.graphics.pop()
end

return DirectionalTargetHandler
