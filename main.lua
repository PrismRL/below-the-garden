require "debugger"
require "prism"

prism.loadModule("prism/spectrum")
prism.loadModule("prism/geometer")
prism.loadModule("prism/extra/sight")
prism.loadModule("prism/extra/inventory")
prism.loadModule("modules/equipment")
prism.loadModule("prism/extra/condition")
prism.loadModule("prism/extra/log")
prism.loadModule("modules/base")
prism.loadModule("modules/game")

prism.logger.setOptions { level = "debug" }

-- Load a sprite atlas and configure the terminal-style display,
love.graphics.setDefaultFilter("nearest", "nearest")
local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 8, 8)
local display = spectrum.Display(50, 30, spriteAtlas, prism.Vector2(8, 8))

-- spin up our state machine
--- @type GameStateManager
local manager = spectrum.StateManager()

-- we put out levelstate on top here, but you could create a main menu
--- @diagnostic disable-next-line
function love.load()
   manager:push(spectrum.gamestates.GameStartState(display))
   manager:hook()
   spectrum.Input:hook()
end
