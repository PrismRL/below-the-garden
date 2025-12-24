local settings = require "settings"

--- @diagnostic disable-next-line
function love.conf(t)
   t.window.vsync = 0 -- Enable vsync (1 by default)
   t.window.width = 70 * 8 * settings.scale
   t.window.height = 32 * 8 * settings.scale
   t.window.usedpiscale = false
   t.window.title = "Below the Garden"
   -- Other configurations...
end
