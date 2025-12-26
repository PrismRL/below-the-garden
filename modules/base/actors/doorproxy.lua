prism.registerActor("DoorProxy", function()
   return prism.Actor.fromComponents {
      prism.components.Name("DoorProxy"),
      prism.components.DoorProxy(),
      prism.components.Position(),
      prism.components.Drawable { index = "!", color = prism.Color4.RED },
   }
end)
