prism.registerActor("Key", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Key"),
      prism.components.Drawable{
         index = "k",
         color = prism.Color4.YELLOW,
      },
      prism.components.Position()
   }
end)