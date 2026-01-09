local controls = require "controls"
local Name = prism.components.Name

--- @class GeneralTargetHandler : TargetHandler
--- @field selectorPosition Vector2
local GeneralTargetHandler = spectrum.gamestates.TargetHandler:extend("GeneralTargetHandler")

function GeneralTargetHandler:getValidTargets()
   local valid = {}

   for foundTarget in
      self.owner
         :expect(prism.components.Senses)
         :query(self.level)
         :target(self.target, self.level, self.owner, self.targetList)
         :iter()
   do
      table.insert(valid, foundTarget)
   end

   table.sort(valid, function(a, b)
      if a:has(prism.components.Health) and (not b:has(prism.components.Health)) then return true end
      if b:has(prism.components.Health) and (not a:has(prism.components.Health)) then return false end
      return a:getName() < b:getName()
   end)

   if #valid == 0 and not (self.target.type and self.target.type ~= prism.Vector2) then
      table.insert(valid, self.owner:expectPosition())
   end

   return valid
end

function GeneralTargetHandler:setSelectorPosition()
   if prism.Vector2:is(self.curTarget) then
      self.selectorPosition = self.curTarget
   elseif self.curTarget then
      self.selectorPosition = self.curTarget:getPosition()
   end
end

function GeneralTargetHandler:init()
   GeneralTargetHandler.super.init(self)
   self.curTarget = self.validTargets[1]
   self:setSelectorPosition()
end

function GeneralTargetHandler:update(dt)
   controls:update()
   self.display:update(self.level, dt)

   if controls.next.pressed then
      local lastTarget = self.curTarget
      self.index, self.curTarget = next(self.validTargets, self.index)

      while (not self.index and #self.validTargets > 0) or (lastTarget == self.curTarget and #self.validTargets > 1) do
         self.index, self.curTarget = next(self.validTargets, self.index)
      end

      self:setSelectorPosition()
   end

   if (controls.select.pressed or controls.throw.pressed) and self.curTarget then
      table.insert(self.targetList, self.curTarget)
      self.manager:pop()
   end

   if controls.back.pressed then self.manager:pop("pop") end

   if controls.move.pressed then
      self.selectorPosition = self.selectorPosition + controls.move.vector
      self.curTarget = nil

      if self.target:validate(self.level, self.owner, self.selectorPosition, self.targetList) then
         self.curTarget = self.selectorPosition
      end

      local validTarget = self.level
         :query()
         :at(self.selectorPosition:decompose())
         :target(self.target, self.level, self.owner, self.targetList)
         :first()

      if validTarget then self.curTarget = validTarget end
   end
end

function GeneralTargetHandler:draw()
   self.levelState:draw()
   self.display:clear()

   local x, y = self.selectorPosition:decompose()
   self.display:put(x + self.camera.x, y + self.camera.y, 11)

   if not self.curTarget or prism.Vector2:is(self.curTarget) and self.curTarget ~= self.selectorPosition then
      self.display:put(x + self.camera.x, y + self.camera.y, 163)
   end

   love.graphics.push()
   love.graphics.translate(8, 8)
   self.display:draw()
   love.graphics.pop()
end

--- @class ThrowTargetHandler : GeneralTargetHandler
local ThrowTargetHandler = GeneralTargetHandler:extend "ThrowTargetHandler"

function ThrowTargetHandler:init()
   ThrowTargetHandler.super.init(self)
   self.maxRange = self.owner:expect(prism.components.Thrower):getRange()
   self.throwMask = prism.Collision.createBitmaskFromMovetypes { "fly" }
   self.start = self.owner:expectPosition()
end

function ThrowTargetHandler:draw()
   local positions = self.levelState.hudPositions
   self.levelState:draw()
   self.display:clear()

   local path = prism.Bresenham(
      self.start.x,
      self.start.y,
      self.selectorPosition.x,
      self.selectorPosition.y,
      function(cx, cy)
         local distance = self.start:distance(prism.Vector2(cx, cy))
         if
            not self.level:getCellPassable(cx, cy, self.throwMask)
            or distance >= self.maxRange
            or not self.owner:expect(prism.components.Senses).cells:get(cx, cy)
         then
            return false -- stop iteration
         end
         return true -- continue
      end
   )
   table.remove(path.path, 1)
   for _, point in ipairs(path:getPath()) do
      self.display:put(point.x + self.camera.x, point.y + self.camera.y, 11, prism.Color4.TEXT)
   end
   local x, y = self.selectorPosition:decompose()
   self.display:put(x + self.camera.x, y + self.camera.y, 11)
   self.display:print(positions.shift.x - 1, positions.shift.y - 1, "SHFT", prism.Color4.TEXT)
   self.display:print(positions.wait.x - 1, positions.wait.y - 1, "X", prism.Color4.TEXT)
   self.display:print(positions.drop.x - 1, positions.drop.y - 1, "V", prism.Color4.TEXT)
   love.graphics.push()
   love.graphics.translate(8, 8)
   self.display:draw()
   love.graphics.pop()
end

prism.register(ThrowTargetHandler)

return GeneralTargetHandler
