prism.registerActor("Log", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Log"),
      prism.components.Drawable {
         index = 256,
         color = prism.Color4.BROWN,
      },
      prism.components.Position(),
   }
end)
local Animation = spectrum.Animation

spectrum.registerAnimation("Fire", function()
   return Animation({ { index = 240, color = prism.Color4.GOLD }, { index = 272, color = prism.Color4.GOLD } }, 0.5)
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
      prism.components.Camp(),
      prism.components.Light((prism.Color4.GOLD + prism.Color4.GOLD) / 1.5, 7, prism.lighteffects.Flicker()),
      prism.components.Fire(),
   }
end)
