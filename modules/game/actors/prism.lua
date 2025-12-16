prism.registerActor("Prism", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Prism"),
      prism.components.Position(),
      prism.components.Drawable { index = 258, color = prism.Color4.PINK, layer = 1 },
      prism.components.Item(),
   }
end)
