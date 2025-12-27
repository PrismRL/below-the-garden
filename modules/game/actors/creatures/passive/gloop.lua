prism.registerActor("Gloop", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gloop"),
      prism.components.Drawable {
         index = 289,
         color = prism.Color4.GREEN,
         layer = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Senses(),
      prism.components.Sight { range = 2, fov = true, darkvision = 2 / 16 },
      prism.components.Slow(),
      prism.components.ConditionHolder(),
      prism.components.Eatable(1),
      prism.components.GloopController(),
      prism.components.ExplodeOnThrow(1, 2)
   }
end)
