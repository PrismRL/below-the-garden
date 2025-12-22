prism.registerActor("Firefly", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Firefly"),
      prism.components.Drawable {
         index = 8,
         color = prism.Color4.YELLOW,
         layer = 3,
      },
      prism.components.Senses(),
      prism.components.LightSight { range = 5, fov = true },
      prism.components.Mover { "fly" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Health(1),
      prism.components.Light(prism.Color4.YELLOW, 2, prism.lighteffects.Flicker()),
      prism.components.FireflyController()
   }
end)
