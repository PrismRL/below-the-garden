prism.registerActor("Chest", function(toSpawn)
   return prism.Actor.fromComponents {
      prism.components.Name("Chest"),
      prism.components.Drawable{
         index = 173,
         color = prism.Color4.YELLOW,
      },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Chest(toSpawn),
   }
end)