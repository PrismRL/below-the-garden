local Animation = spectrum.Animation
spectrum.registerAnimation("FireflyIdle", function()
   local animation = Animation(Animation.buildFrames { range = "275-276", color = prism.Color4.YELLOW, layer = 2 }, 0.4)
   animation:update(love.math.random())
   return animation
end)

prism.registerActor("Firefly", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Firefly"),
      prism.components.Drawable {
         index = 8,
         color = prism.Color4.YELLOW,
         layer = 2,
      },
      prism.components.Senses(),
      prism.components.LightSight { range = 1, fov = true },
      prism.components.Mover { "walk", "fly" },
      prism.components.Position(),
      prism.components.Light(prism.Color4.YELLOW, 3, prism.lighteffects.Flicker()),
      prism.components.IdleAnimation("FireflyIdle"),
      prism.components.FireflyController(),
      prism.components.Item(),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Equipment("held"),
      prism.components.Slow(),
   }
end)
