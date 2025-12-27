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
      prism.components.Light(
         (prism.Color4.ORANGE + prism.Color4.ORANGE) / 2,
         5,
         prism.lighteffects.Flicker { speed = 2, colorShift = 0.1 }
      ),
   }
end)
