prism.registerActor("Torch", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Torch"),
      prism.components.Drawable {
         index = 279,
         color = prism.Color4.ORANGE,
      },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
   }
end)
