prism.registerActor("Stairs", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Stairs"),
      prism.components.Drawable { index = 143 },
      prism.components.Position(),
      prism.components.Stair(),
      prism.components.Collider(),
      prism.components.Remembered(),
   }
end)
