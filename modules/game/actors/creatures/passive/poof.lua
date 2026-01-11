prism.register(prism.Component:extend "PoofOnThrow")
prism.register(prism.Component:extend "PoofSmoke")

prism.registerActor("PoofSmoke", function()
   return prism.Actor.fromComponents {
      prism.components.Name("PoofSmoke"),
      prism.components.PoofSmoke(),
      prism.components.Opaque(),
      prism.components.Drawable {
         index = 17,
         color = prism.Color4.GREY,
      },
      prism.components.Position(),
   }
end)

prism.registerActor("PoofEmitter", function()
   return prism.Actor.fromComponents {
      prism.components.Name("PoofEmitter"),
      prism.components.SmokeEmitter {
         turnsUntilDecay = 6,
         radius = 2,
         decay = 1,
         actor = prism.actors.PoofSmoke,
         component = prism.components.PoofSmoke,
         remove = true,
      },
      prism.components.Position(),
   }
end)

prism.registerActor("Poof", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Poof"),
      prism.components.Drawable {
         index = 338,
         color = prism.Color4.RED,
         layer = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.PoofController(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Senses(),
      prism.components.Sight { range = 4, fov = true, darkvision = 0 },
      prism.components.PoofOnThrow(),
      prism.components.Slow(),
      prism.components.ConditionHolder(),
   }
end)
