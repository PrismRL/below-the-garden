--- A wrapper around Geometer's EditorState meant for stepping through map generation.
--- @class LoadingState : EditorState
--- @overload fun(generator: function, display: Display): LoadingState
local LoadingState = spectrum.GameState:extend "LoadingState"

--- @param generator function
--- @param display Display
function LoadingState:__new(generator, display, overlay)
   self.co = coroutine.create(generator)
   self.display = display
   self.overlay = overlay
end

function LoadingState:update(dt)
   local success, builder = coroutine.resume(self.co)
   if not success then error(builder .. "\n" .. debug.traceback(self.co)) end

   if coroutine.status(self.co) == "dead" then
      self.manager:enter(spectrum.gamestates.GameLevelState(builder, self.display, self.overlay))
   end
end

local strings = {
   "Loading",
   "Loading.",
   "Loading..",
}
function LoadingState:draw()
   time = love.timer.getTime()
   self.display:clear()
   self.display:print(1, 1, "Loading")
   self.display:draw()
end

return LoadingState
