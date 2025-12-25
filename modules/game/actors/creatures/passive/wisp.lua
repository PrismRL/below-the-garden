local Animation = spectrum.Animation
spectrum.registerAnimation("WispIdle", function()
   local animation = Animation(Animation.buildFrames { range = "275-276", color = prism.Color4.BLUE }, 0.4)
   animation:update(love.math.random())
   return animation
end)

prism.registerActor("Wisp", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Wisp"),
      prism.components.Drawable {
         index = 8,
         color = prism.Color4.BLUE,
         layer = 3,
      },
      prism.components.Senses(),
      prism.components.LightSight { range = 1, fov = true },
      prism.components.Mover { "fly" },
      prism.components.Position(),
      prism.components.Collider(),
      prism.components.Health(1),
      prism.components.Light(prism.Color4.BLUE, 2, prism.lighteffects.Heartbeat()),
      prism.components.IdleAnimation("WispIdle"),
      prism.components.FireflyController(),
   }
end)
