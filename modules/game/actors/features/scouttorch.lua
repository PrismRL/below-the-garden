prism.registerActor("ScoutTorch", function()
   return prism.Actor.fromComponents {
      prism.components.Name("ScoutTorch"),
      prism.components.Drawable {
         index = 240,
         color = prism.Color4.ORANGE,
      },
      prism.components.Position(),
      prism.components.Camp(),
      prism.components.Light((prism.Color4.YELLOW + prism.Color4.YELLOW) / 1.5, 7, prism.lighteffects.Flicker()),
   }
end)
