prism.registerActor("Door", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Door"),
      prism.components.Drawable { index = 142, color = prism.Color4.BROWN },
      prism.components.Position(),
      prism.components.Door(),
   }
end)
