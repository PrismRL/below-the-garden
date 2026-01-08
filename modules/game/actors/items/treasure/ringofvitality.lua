prism.registerActor("RingOfVitality", function()
   return prism.Actor.fromComponents {
      prism.components.Name("RingOfVitality"),
      prism.components.Equipment("amulet", prism.condition.Condition(prism.modifiers.HealthModifier(3))),
      prism.components.Position(),
      prism.components.Drawable {
         index = 353,
         color = prism.Color4.RED,
      },
   }
end)
