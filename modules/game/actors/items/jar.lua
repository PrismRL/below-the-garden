prism.registerActor("Jar", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Jar"),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Drawable { index = 265, color = prism.Color4.WHITE },
      prism.components.Position(),
   }
end)
