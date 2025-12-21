prism.registerActor("Door", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Door"),
      prism.components.Drawable{index = "/", color = prism.Color4.BROWN}
   }
end)