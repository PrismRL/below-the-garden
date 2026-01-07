local Animation = spectrum.Animation
spectrum.registerAnimation("EyeIdle", function()
   local animation = Animation(Animation.buildFrames { range = "273-274", color = prism.Color4.BLUE }, 0.5)
   animation:update(love.math.random())
   return animation
end)

prism.registerActor("Eye", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Eye"),
      prism.components.Drawable {
         index = 273,
         color = prism.Color4.BLUE,
      },
      prism.components.Mover { "fly" },
      prism.components.Light(prism.Color4.BLUE, 2),
      prism.components.IdleAnimation("EyeIdle"),
      prism.components.Position(),
      prism.components.EyeController(),
   }
end)
