prism.registerActor("Sword", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Sword"),
      prism.components.Item(),
      prism.components.Drawable {
         index = 157,
         color = prism.Color4.WHITE,
      },
      prism.components.Equipment("weapon"),
   }
end)
