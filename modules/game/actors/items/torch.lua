prism.registerActor("Torch", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Torch"),
      prism.components.Drawable {
         index = 279,
         color = prism.Color4.GOLD,
      },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Light(
         (prism.Color4.GOLD + prism.Color4.GOLD) / 2,
         6,
         prism.lighteffects.Flicker { speed = 2, colorShift = 0.1 }
      ),
      prism.components.Torch(),
      prism.components.Attacker(1),
   }
end)
