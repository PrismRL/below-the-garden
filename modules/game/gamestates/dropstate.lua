local controls = require "controls"

--- @class DropState : GameState
local DropState = spectrum.GameState:extend "DropState"

local grid = prism.Grid(2, 2)
grid:set(1, 1, "held")
grid:set(2, 1, "pocket")
grid:set(1, 2, "weapon")
grid:set(2, 2, "amulet")

local animation = spectrum.Animation({
   function(display, x, y)
      display:itemBorder(x, y, prism.Color4.CORNFLOWER)
   end,
   function(display, x, y)
      display:itemBorder(x, y, prism.Color4.DARK)
   end,
}, 0.4)

--- @param levelState GameLevelState
--- @param player Actor
function DropState:__new(levelState, player, targets)
   self.levelState = levelState
   self.player = player
   self.display = levelState.overlay
   self.position = prism.Vector2(1, 1)
   self.targets = targets
   self.item = player:expect(prism.components.Equipper):get("held")
end

function DropState:draw()
   self.levelState:draw()

   local positions = self.levelState.hudPositions
   local position = positions[grid:get(self.position:decompose())]
   local heldPosition = self.levelState.hudPositions["held"]

   self.display:itemBorder(heldPosition.x, heldPosition.y, prism.Color4.DARK)
   self.display:print(positions.shift.x, positions.shift.y, "SHFT", prism.Color4.TEXT)
   self.display:putFG(positions.throw.x, positions.throw.y, prism.Color4.TEXT, math.huge)
   self.display:putFG(positions.throw.x, positions.throw.y + 1, prism.Color4.TEXT)
   animation:draw(self.display, position:decompose())
   self.display:draw()
end

local function wrap(v, lo, hi)
   return (v - lo) % (hi - lo) + lo
end

function DropState:update(dt)
   animation:update(dt)
   controls:update()

   if controls.move.pressed then
      animation.timer = 0
      local new = self.position + controls.move.vector
      new.x = wrap(new.x, 1, 3)
      new.y = wrap(new.y, 1, 3)
      self.position = new

      local slot = grid:get(self.position:decompose())
      if slot == "pocket" then
         self.item = self.player:expect(prism.components.Inventory):query():first()
      else
         self.item = self.player:expect(prism.components.Equipper):get(slot)
      end
   end

   if controls.select.pressed or controls.drop.pressed then
      self.targets[1] = self.item
      self.manager:pop()
   end

   if controls.back.pressed then self.manager:pop() end
end

return DropState
