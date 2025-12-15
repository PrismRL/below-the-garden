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
   return Animation({ { index = 240, color = prism.Color4.ORANGE }, { index = 272, color = prism.Color4.ORANGE } }, 0.5)
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
   }
end)
