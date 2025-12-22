prism.registerActor("Stairs", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Stairs"),
      prism.components.Drawable{index = ">"},
      prism.components.Position()
   }
end)