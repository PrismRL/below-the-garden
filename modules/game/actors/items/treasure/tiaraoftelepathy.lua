prism.registerActor("TiaraOfTelepathy", function()
   return prism.Actor.fromComponents {
      prism.components.Name("TiaraOfTelepathy"),
      prism.components.Equipment("amulet", prism.condition.Condition(prism.modifiers.TelepathyModifier(6))),
      prism.components.Position(),
      prism.components.Drawable {
         index = 337,
         color = prism.Color4.WHITE,
      },
   }
end)
