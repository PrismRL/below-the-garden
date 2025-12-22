prism.registerActor("Spawner", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Spawner"),
      prism.components.Spawner(),
      prism.components.Drawable{index = "!", prism.Color4.RED}
   }
end)