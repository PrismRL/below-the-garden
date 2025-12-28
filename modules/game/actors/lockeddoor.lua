prism.registerActor("LockedDoor", function()
   return prism.Actor.fromComponents {
      prism.components.Name("LockedDoor"),
      prism.components.Drawable { index = 142, color = prism.Color4.YELLOW },
      prism.components.Position(),
   }
end)
