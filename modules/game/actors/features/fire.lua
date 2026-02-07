prism.registerActor("Log", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Log"),
      prism.components.Drawable {
         index = 256,
         color = prism.Color4.BROWN,
      },
      prism.components.Position(),
      prism.components.Ignitable("Fire", 0, -1),
      prism.components.Camp(),
   }
end)
local Animation = spectrum.Animation

spectrum.registerAnimation("Fire", function()
   return Animation(
      { { index = 240, color = prism.Color4.GOLD, layer = 3 }, { index = 272, color = prism.Color4.GOLD, layer = 3 } },
      0.5
   )
end)

prism.registerActor("Fire", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Fire"),
      prism.components.Drawable {
         index = 240,
         color = prism.Color4.ORANGE,
      },
      prism.components.Position(),
      prism.components.IdleAnimation("Fire"),
      prism.components.Light((prism.Color4.GOLD + prism.Color4.GOLD) / 1.5, 7, prism.lighteffects.FlickerEffect()),
      prism.components.Fire(),
      prism.components.Snuffable(),
   }
end)
