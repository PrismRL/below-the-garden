local controls = require "controls"

--- @class GameStartState : GameState
--- @field display Display
--- @overload fun(display: Display): GameStartState
local GameStartState = spectrum.GameState:extend("GameStartState")

function GameStartState:__new(display)
   self.display = display

   if love.filesystem.getInfo("save.lz4") then self.save = love.filesystem.read("save.lz4") end
end

function GameStartState:draw()
   local midpoint = math.floor(self.display.height / 2) - 2
   love.graphics.scale(3, 3)

   -- stylua: ignore start
   self.display:clear()
   self.display:print(1, midpoint, "Below the Garden", prism.Color4.GREEN, nil, nil, "center", self.display.width)

   self.display:print(2, midpoint + 6, "Press any key to enter...", prism.Color4.GREY, nil, nil, "center", self.display.width)

   local i = 0

   -- self.display:print(1, midpoint + 4 + i, "[q] to quit", nil, nil, nil, "center", self.display.width)
   -- stylua: ignore end
   self.display:draw()
end

function GameStartState:keypressed()
   self.manager:enter(spectrum.gamestates.GameLevelState(self.display))
end

return GameStartState
