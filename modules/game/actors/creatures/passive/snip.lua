spectrum.registerAnimation("SnipIdle", function(...)
   return spectrum.Animation(
      spectrum.Animation.buildFrames({ range = "261-262", color = prism.Color4.PEACH, layer = 2 }),
      0.5
   )
end)

prism.registerActor("Snip", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Snip"),
      prism.components.IdleAnimation("SnipIdle"),
      prism.components.Drawable {
         index = 261,
         color = prism.Color4.PEACH,
         background = prism.Color4.BLACK,
         layer = 2,
      },
      prism.components.Mover { "walk" },
      prism.components.SnipController(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Senses(),
      prism.components.Sight { range = 4, fov = true, darkvision = 2/16},
      prism.components.Eatable(1),
   }
end)
