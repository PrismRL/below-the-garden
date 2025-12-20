prism.registerActor("Sling", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Sling"),
      prism.components.Equipment("weapon", prism.condition.Condition(prism.modifiers.ThrowRangeModifier(4))),
      prism.components.Position(),
      prism.components.Drawable { index = 159 },
   }
end)
