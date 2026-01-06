prism.registerActor("Staff", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Staff"),
      prism.components.Equipment(
         "weapon",
         prism.condition.Condition(prism.modifiers.ThrowRangeModifier(4), prism.modifiers.ThrowDamageModifier(2))
      ),
      prism.components.Position(),
      prism.components.Drawable { index = 159 },
   }
end)
