prism.register(prism.Component:extend "PoofOnThrow")

prism.registerActor("PoofEmitter", function ()
   return prism.Actor.fromComponents {
      prism.components.Name("PoofEmitter"),
      prism.components.SmokeEmitter{
         turnsUntilDecay = 3,
         radius = 2,
         decay = 1,
      },
      prism.components.Position(),
   }
end)

prism.registerActor("Poof", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Snip"),
      prism.components.Drawable {
         index = 338,
         color = prism.Color4.RED,
         layer = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.SnipController(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Senses(),
      prism.components.Sight { range = 4, fov = true, darkvision = 0 },
      prism.components.PoofOnThrow(),
   }
end)
