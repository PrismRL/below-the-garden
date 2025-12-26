prism.registerActor("Spawner", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Spawner"),
      prism.components.Spawner(),
      prism.components.Drawable { index = "!", color = prism.Color4.BLUE },
      prism.components.Position(),
   }
end)
