local controls = require "controls"

--- @class GameOverState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(display)
   self.display = display
end

function GameOverState:draw()
   local midpoint = math.floor(self.display.height / 2)

   -- stylua: ignore start
   self.display:clear()
   self.display:print(1, midpoint, "Game over!", nil, nil, nil, "center", self.display.width)
   self.display:print(1, midpoint + 3, "[r] to restart", nil, nil, nil, "center", self.display.width)
   self.display:print(1, midpoint + 4, "[q] to quit", nil, nil, nil, "center", self.display.width)
   love.graphics.scale(3, 3)
   self.display:draw()
   -- stylua: ignore end
end

function GameOverState:update(dt)
   controls:update()

   if controls.quit.pressed then
      love.event.quit()
   elseif controls.restart.pressed then
      love.event.restart()
   end
end

return GameOverState
