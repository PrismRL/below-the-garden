prism.registerActor("Hammer", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Hammer"),
      prism.components.Drawable {
         index = 277,
         color = prism.Color4.WHITE,
      },
      prism.components.Equipment("weapon", prism.condition.Condition(prism.modifiers.AttackModifier(1, 1))),
   }
end)
