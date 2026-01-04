prism.registerActor("Flippers", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Flippers"),
      prism.components.Equipment("amulet", prism.conditions.Aquatic()),
      prism.components.Position(),
      prism.components.Drawable {
         index = 285,
         color = prism.Color4.RED,
      },
   }
end)
