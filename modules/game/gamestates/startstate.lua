local settings = require "settings"
local controls = require "controls"

--- @class GameStartState : GameState
--- @field display Display
--- @field overlay Display
--- @overload fun(display: Display, overlay: Display): GameStartState
local GameStartState = spectrum.GameState:extend("GameStartState")

function GameStartState:__new(display, overlay)
   self.display = display
   self.overlay = overlay

   if love.filesystem.getInfo("save.lz4") then self.save = love.filesystem.read("save.lz4") end
end

function GameStartState:draw()
   local midpoint = math.floor(self.display.height / 2) - 2

   -- stylua: ignore start
   self.overlay:clear()
   self.overlay:print(1, midpoint, "Below the Garden", prism.Color4.GREEN, nil, nil, "center", self.overlay.width)

   self.overlay:print(2, midpoint + 6, "Press any key to enter...", prism.Color4.GREY, nil, nil, "center", self.overlay.width)

   local i = 0

   -- self.display:print(1, midpoint + 4 + i, "[q] to quit", nil, nil, nil, "center", self.display.width)
   -- stylua: ignore end
   love.graphics.scale(settings.scale, settings.scale)
   self.overlay:draw()
end

function GameStartState:keypressed()
   self.manager:enter(spectrum.gamestates.GameLevelState(self.display, self.overlay))
end

return GameStartState
