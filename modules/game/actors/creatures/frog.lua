-- --- @type AnimationFrame
-- local function tongueFrame3(display, x, y)
--    display:put(x, y, 363)
--    display:put(x + 1, y, 364)
--    display:put(x + 2, y, 365)
-- end
--
-- --- @type AnimationFrame
-- local function tongueFrame2(display, x, y)
--    display:put(x, y, 363)
--    display:put(x + 1, y, 365)
-- end
--
-- spectrum.registerAnimation("FrogTongue", function(direction, length)
--    --- @cast direction Vector2
--    --- @cast length integer
--    return spectrum.Animation(
--       { { index = 263 }, { index = 379 }, tongueFrame2, tongueFrame3, tongueFrame2, { index = 379 } },
--       { 1, 0.05, 0.05, 0.5, 0.05, 0.05 },
--       "pauseAtEnd"
--    )
-- end)
--
local function makeTongueFrame(direction, length, stage)
   -- direction: Vector2
   -- stage: 1 = base, 2..length = extending, length+1 = full, length+2.. = retracting
   return function(display, x, y)
      local dx, dy, base, tip, mid, full
      if direction == prism.Vector2.RIGHT then
         dx, dy = 1, 0
         base, tip, mid, full = 293, 292, 291, 130
      elseif direction == prism.Vector2.LEFT then
         dx, dy = -1, 0
         base, tip, mid, full = 296, 295, 294, 130
      elseif direction == prism.Vector2.DOWN then
         dx, dy = 0, 1
         base, tip, mid, full = 299, 298, 297, 129
      else -- prism.Vector2.UP
         dx, dy = 0, -1
         base, tip, mid, full = 302, 301, 300, 129
      end
      -- Draw base
      if stage > 1 then
         display:put(x, y, mid)
      else
         display:put(x, y, base)
      end

      if stage > 1 then display:put(x + direction.x, y + direction.y, tip) end
      if stage > 2 and length > 2 then
         display:put(x + direction.x * 2, y + direction.y * 2, tip)
         display:put(x + direction.x, y + direction.y, full, prism.Color4.PEACH)
      end
   end
end

spectrum.registerAnimation("FrogTongue", function(direction, length)
   print(direction, length)
   local frames = {}
   local times = {}

   -- Extend
   for stage = 1, length do
      table.insert(frames, makeTongueFrame(direction, length, stage))
      table.insert(times, 0.05)
   end
   -- Full
   table.insert(frames, makeTongueFrame(direction, length, length + 1))
   table.insert(times, 0.5)
   -- Retract
   for stage = length, 1, -1 do
      table.insert(frames, makeTongueFrame(direction, length, stage))
      table.insert(times, 0.05)
   end

   return spectrum.Animation(frames, times, "pauseAtEnd")
end)

spectrum.registerAnimation("FrogIdle", function()
   return spectrum.Animation(spectrum.Animation.buildFrames({ range = "263-264" }), 1)
end)

prism.registerActor("Frog", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Frog"),
      prism.components.Drawable { index = 224, layer = 3 },
      prism.components.IdleAnimation("FrogIdle"),
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Mover { "walk" },
      prism.components.Senses(),
      prism.components.Sight { range = 6, fov = true },
      prism.components.FrogController(),
      prism.components.Health(6),
   }
end)
