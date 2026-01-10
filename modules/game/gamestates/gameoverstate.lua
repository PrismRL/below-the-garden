local settings = require "settings"
local controls = require "controls"

--- @class GameOverState : GameState
--- @field display Display
--- @overload fun(display: Display): GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(display, overlay)
   self.display = display
   self.overlay = overlay
end

function GameOverState:load(previous)
   GAME.depth = 1
   GAME.player = prism.actors.Player()
end

function GameOverState:draw()
   local midpoint = math.floor(self.display.height / 2)

   -- stylua: ignore start
   self.overlay:clear()
   self.overlay:print(1, midpoint, "Game over!", nil, nil, nil, "center", self.display.width)
   self.overlay:print(1, midpoint + 3, "[r] to restart", nil, nil, nil, "center", self.display.width)
   self.overlay:print(1, midpoint + 4, "[q] to quit", nil, nil, nil, "center", self.display.width)
   love.graphics.scale(settings.scale, settings.scale)
   self.overlay:draw()
   -- stylua: ignore end
end

function GameOverState:update(dt)
   controls:update()

   if controls.quit.pressed then
      love.event.quit()
   elseif controls.restart.pressed then
      self.manager:enter(spectrum.gamestates.GameStartState(self.display, self.overlay))
   end
end

return GameOverState
