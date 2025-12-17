--- @type AnimationFrame
local function tongueFrame3(display, x, y)
   display:put(x, y, 363)
   display:put(x + 1, y, 364)
   display:put(x + 2, y, 365)
end

--- @type AnimationFrame
local function tongueFrame2(display, x, y)
   display:put(x, y, 363)
   display:put(x + 1, y, 365)
end

spectrum.registerAnimation("FrogTongue", function(...)
   return spectrum.Animation(
      { { index = 263 }, { index = 379 }, tongueFrame2, tongueFrame3, tongueFrame2, { index = 379 } },
      { 1, 0.05, 0.05, 0.5, 0.05, 0.05 }
   )
end)

spectrum.registerAnimation("FrogIdle", function()
   return spectrum.Animation(spectrum.Animation.buildFrames({ range = "263-264" }), 1)
end)

prism.registerActor("Frog", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Frog"),
      prism.components.Drawable { index = 224, layer = 3 },
      prism.components.IdleAnimation("FrogTongue"),
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Mover { "walk" },
      prism.components.SqeetoController(),
   }
end)
