local settings = require "settings"

require "debugger"
require "prism"

love.graphics.setDefaultFilter("nearest", "nearest")

prism.loadModule("prism/spectrum")
prism.loadModule("prism/geometer")
prism.loadModule("prism/extra/sight")
prism.loadModule("modules/inventory")
prism.loadModule("modules/equipment")
prism.loadModule("prism/extra/condition")
prism.loadModule("prism/extra/log")
prism.loadModule("prism/extra/lighting")
prism.loadModule("modules/telepathy")
prism.loadModule("modules/autotile")
prism.loadModule("modules/base")
prism.loadModule("modules/game")
prism.loadModule("modules/levelgen")
prism.loadModule("modules/btggen")
prism.loadModule("modules/smoke")

prism.logger.setOptions { level = "debug" }

-- Load a sprite atlas and configure the terminal-style display,
local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 8, 8)
spriteAtlas.quadsByName["held"] = spriteAtlas:getQuadByIndex(28)
spriteAtlas.quadsByName["pocket"] = spriteAtlas:getQuadByIndex(266)
spriteAtlas.quadsByName["weapon"] = spriteAtlas:getQuadByIndex(157)
spriteAtlas.quadsByName["amulet"] = spriteAtlas:getQuadByIndex(158)
local display = spectrum.Display(settings.windowWidth - 7, settings.windowHeight - 2, spriteAtlas, prism.Vector2(8, 8))
local overlay = spectrum.Display(settings.windowWidth, settings.windowHeight, spriteAtlas, prism.Vector2(8, 8))

-- spin up our state machine
--- @type GameStateManager
local manager = spectrum.StateManager()

love.keyboard.setKeyRepeat(true)

-- we put out levelstate on top here, but you could create a main menu
--- @diagnostic disable-next-line
function love.load(args)
   local testing = args[1] == "-t"
   local map = args[1] == "-m"
   if testing then
      manager:push(spectrum.gamestates.GameLevelState(display, overlay, testing))
   elseif map then
      MAPDEBUG = true

      manager:push(spectrum.gamestates.MapGeneratorState(function()
            prism.generators.FirstThird.generate({
               seed = love.timer.getTime(),
               w = 60,
               h = 30,
               depth = 1,
            }, prism.actors.Player())
      end, nil, overlay))
   else
      manager:push(spectrum.gamestates.GameStartState(display, overlay))
   end
   manager:hook()
   spectrum.Input:hook()
end
