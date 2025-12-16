--- @diagnostic disable-next-line
function love.conf(t)
   t.window.vsync = 0 -- Enable vsync (1 by default)
   t.window.width = 30 * 8 * 4
   t.window.height = 25 * 8 * 4
   t.window.usedpiscale = false
   t.window.title = "Below the Garden"
   -- Other configurations...
end
