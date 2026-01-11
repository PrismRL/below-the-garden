local Animation = spectrum.Animation

spectrum.registerAnimation("ScoutTorch", function()
   return Animation({ { index = 286, color = prism.Color4.GOLD }, { index = 287, color = prism.Color4.GOLD } }, 0.5)
end)

prism.registerActor("ScoutTorch", function()
   return prism.Actor.fromComponents {
      prism.components.Name("ScoutTorch"),
      prism.components.Drawable {
         index = 286,
         color = prism.Color4.ORANGE,
      },
      prism.components.IdleAnimation("ScoutTorch"),
      prism.components.Position(),
      prism.components.Camp(),
      prism.components.Light(prism.Color4.GOLD, 7, prism.lighteffects.Flicker()),
   }
end)
