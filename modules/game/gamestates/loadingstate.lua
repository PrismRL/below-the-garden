local settings = require "settings"

--- A wrapper around Geometer's EditorState meant for stepping through map generation.
--- @class LoadingState : EditorState
--- @overload fun(generator: function, display: Display): LoadingState
local LoadingState = spectrum.GameState:extend "LoadingState"

--- @param generator function
--- @param display Display
--- @param overlay Display
function LoadingState:__new(generator, display, overlay)
   self.co = coroutine.create(generator)
   self.display = display
   self.overlay = overlay
   self.timer = 0
   self.index = 0
end

function LoadingState:update(dt)
   self.timer = self.timer + dt
   if self.timer > 0.5 then self.timer = 0 end
   self.index = math.floor(self.timer * 6 + 1)
   local success, builder = coroutine.resume(self.co)
   if not success then error(builder .. "\n" .. debug.traceback(self.co)) end

   if coroutine.status(self.co) == "dead" then
      self.manager:enter(spectrum.gamestates.GameLevelState(builder, self.display, self.overlay))
   end
end

local strings = {
   "Descending.",
   "Descending..",
   "Descending...",
}
function LoadingState:draw()
   local midpoint = math.floor(self.display.height / 2) - 2
   local x = math.floor(self.display.width / 2)

   self.overlay:clear()
   self.overlay:print(1, midpoint, "Below the Garden", prism.Color4.GREEN, nil, nil, "center", self.overlay.width)
   self.overlay:print(x - 2, midpoint + 6, strings[self.index], prism.Color4.GREY)
   love.graphics.scale(settings.scale, settings.scale)
   self.overlay:draw()
end

return LoadingState
