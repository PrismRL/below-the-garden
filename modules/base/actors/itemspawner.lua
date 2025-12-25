prism.registerActor("ItemSpawner", function()
   return prism.Actor.fromComponents {
      prism.components.Name("ItemSpawner"),
      prism.components.ItemSpawner(),
      prism.components.Drawable{index = "!", color = prism.Color4.YELLOW},
      prism.components.Position(),
   }
end)