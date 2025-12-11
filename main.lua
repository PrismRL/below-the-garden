require "debugger"
require "prism"

prism.loadModule("prism/spectrum")
prism.loadModule("prism/geometer")
prism.loadModule("prism/extra/sight")
prism.loadModule("modules/base")
prism.loadModule("modules/game")

-- Used by Geometer for new maps
prism.defaultCell = prism.cells.Pit

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
   manager:push(spectrum.gamestates.GameLevelState(display))
   manager:hook()
   spectrum.Input:hook()
end
