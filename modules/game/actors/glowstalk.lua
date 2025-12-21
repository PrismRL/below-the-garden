prism.registerActor("Glowstalk", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Glowstalk"),
      prism.components.Position(),
      prism.components.Drawable { index = 35, color = prism.Color4.LIME },
      prism.components.Light(prism.Color4.LIME * 1.5, 3, prism.lighteffects.Sin()),
   }
end)
