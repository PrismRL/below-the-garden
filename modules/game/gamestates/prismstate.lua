local settings = require "settings"

--- @class PrismState : EditorState
local PrismState = spectrum.GameState:extend "PrismState"

local function smoothstep(t)
   return t * t * (3 - 2 * t)
end

local function makePrismNoiseDrawer(display)
   local w = display.width
   local h = display.height

   local fadeDuration = 1.5
   local scale = 0.15
   local timeScale = 0.2

   return function(t)
      local fade = math.min(1, t / fadeDuration)
      fade = smoothstep(fade)

      for x = 1, w do
         for y = 1, h do
            local n = love.math.noise(
               x * scale,
               y * scale,
               t * timeScale
            )

            local color = prism.Color4.PURPLE:copy()
            color.a = n * fade
            display:putBG(x, y, color)
         end
      end
   end
end

local function makeTypewriterDrawer(display, text, x, y, charDelay)
   local len = #text
   charDelay = charDelay or 0.05

   return function(t)
      local count = math.floor(t / charDelay)
      if count <= 0 then return end
      if count > len then count = len end

      display:print(
         x,
         y,
         text:sub(1, count),
         prism.Color4.WHITE,
         nil,
         nil,
         "center"
      )
   end
end
local function makeWhiteFlashDrawer(display, startTime, flashDuration, holdRatio)
   local w = display.width
   local h = display.height

   holdRatio = holdRatio or 0.35

   local holdTime = flashDuration * holdRatio
   local fadeTime = (flashDuration - holdTime) * 0.5

   return function(t)
      local dt = t - startTime
      if dt <= 0 or dt >= flashDuration then return end

      local a
      if dt < fadeTime then
         a = smoothstep(dt / fadeTime)
      elseif dt < fadeTime + holdTime then
         a = 1
      else
         a = smoothstep(1 - (dt - fadeTime - holdTime) / fadeTime)
      end

      local color = prism.Color4.WHITE:copy()
      color.a = a

      for x = 1, w do
         for y = 1, h do
            display:putBG(x, y, color)
         end
      end
   end
end

local function makeShatterTextDrawer(display, x, y, startTime, flashDuration, holdRatio)
   holdRatio = holdRatio or 0.35

   local holdTime = flashDuration * holdRatio
   local fadeTime = (flashDuration - holdTime) * 0.5

   return function(t)
      local dt = t - startTime
      if dt <= 0 or dt >= flashDuration then return end

      local a
      if dt < fadeTime then
         a = smoothstep(dt / fadeTime)
      elseif dt < fadeTime + holdTime then
         a = 1
      else
         a = smoothstep(1 - (dt - fadeTime - holdTime) / fadeTime)
      end

      local fg = prism.Color4.BLACK:copy()
      fg.a = a

      local bg = prism.Color4.WHITE:copy()
      bg.a = a

      display:print(
         x,
         y,
         "It shatters.",
         fg,
         bg,
         nil,
         "center"
      )
   end
end

function PrismState:__new(prevState, display)
   self.prevState = prevState
   self.display = display
   self.t = 0

   local cy = math.floor(display.height / 2)

   self.drawPrismNoise = makePrismNoiseDrawer(display)
   self.drawTypewriter = makeTypewriterDrawer(
      display,
      "You gaze upon the prism.",
      1,
      cy,
      0.045
   )

   self.shatterTime = 2.0
   self.flashDuration = 0.18

   self.drawWhiteFlash = makeWhiteFlashDrawer(
      display,
      self.shatterTime,
      self.flashDuration * 3
   )

   self.drawShatterText = makeShatterTextDrawer(
      display,
      1,
      cy + 2,
      self.shatterTime,
      self.flashDuration * 3
   )
end

function PrismState:update(dt)
   self.t = self.t + dt

   if self.t >= 3 then
      self.manager:pop()
   end
end

function PrismState:draw()
   self.prevState:draw()
   self.display:clear()

   if self.t < self.shatterTime then
      self.drawTypewriter(self.t)
      self.drawPrismNoise(self.t)
   end
   self.drawWhiteFlash(self.t)
   self.drawShatterText(self.t)

   self.display:draw()
end

return PrismState
