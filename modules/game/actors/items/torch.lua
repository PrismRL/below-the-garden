prism.registerActor("Stick", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Stick"),
      prism.components.Drawable {
         index = 279,
         color = prism.Color4.BROWN,
      },
      prism.components.Position(),
      prism.components.Ignitable("Torch"),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Attacker(1),
   }
end)

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
         prism.lighteffects.FlickerEffect { speed = 2, colorShift = 0.1 }
      ),
      prism.components.Torch(),
      prism.components.Snuffable("Stick"),
      prism.components.Attacker(1),
      prism.components.Fire(),
   }
end)
