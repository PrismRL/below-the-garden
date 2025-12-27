prism.registerActor("Snail", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Snail"),
      prism.components.Drawable {
         index = 290,
         color = prism.Color4.YELLOW,
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
      prism.components.GloopController(),
      prism.components.SlimeProducer(),
   }
end)
