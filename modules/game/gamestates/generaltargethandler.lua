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
      if a:has(prism.components.Controller) and (not b:has(prism.components.Controller)) then return true end
      if b:has(prism.components.Controller) and (not a:has(prism.components.Controller)) then return false end
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
   self.super.init(self)
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

   if controls.select.pressed and self.curTarget then
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
   --- @type Entity
   local entity = self.level:getCell(x, y)
   local actor = self.level:query():at(x, y):first()
   if actor then entity = actor end
   -- self.display:putDrawable(23, 23, entity:expect(prism.components.Drawable))
   -- self.display:print(25, 23, entity:getName(), palette[22], palette[6], 2)

   love.graphics.push()
   love.graphics.translate(8, 8)
   self.display:draw()
   love.graphics.pop()
   -- self.display:print(self.selectorPosition.x, self.selectorPosition.y, "X", prism.Color4.RED)
   -- local cameraPos = self.selectorPosition
   --
   -- self.display:clear()
   -- -- set the camera position on the display
   -- local ox, oy = self.display:getCenterOffset(cameraPos:decompose())
   -- self.display:setCamera(ox, oy)
   --
   -- -- draw the level
   -- local primary, secondary = self.levelState:getSenses()
   -- self.display:putSenses(primary, secondary)
   --
   -- -- put a string to let the player know what's happening
   -- self.display:print(1, 1, "Select a target!")
   --
   -- -- if there's a target then we should draw it's name!
   -- if self.curTarget then
   --    local x, y = cameraPos:decompose()
   --    self.display:print(x + ox + 1, y + oy, Name.get(self.curTarget))
   -- end
   -- self.display:draw()
end

return GeneralTargetHandler
