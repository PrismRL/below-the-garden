spectrum.registerAnimation("SnipIdle", function(...)
   return spectrum.Animation(
      spectrum.Animation.buildFrames({ range = "261-262", color = prism.Color4.PEACH, layer = 3 }),
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
         layer = 3,
      },
      prism.components.Mover { "walk" },
      prism.components.SnipController(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Position(),
      prism.components.Item(),
      prism.components.Senses(),
      prism.components.Sight { range = 5, fov = true },
   }
end)
