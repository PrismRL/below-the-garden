prism.registerActor("Shield", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Shield"),
      prism.components.Equipment("amulet", prism.condition.Condition(prism.modifiers.BlockChanceModifier(0.15))),
      prism.components.Position(),
      prism.components.Drawable {
         index = 158,
         color = prism.Color4.BROWN,
      },
   }
end)
