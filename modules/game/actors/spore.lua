prism.registerActor("Spore", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Spore"),
      prism.components.Drawable { index = "X", color = prism.Color4.GREEN },
   }
end)
