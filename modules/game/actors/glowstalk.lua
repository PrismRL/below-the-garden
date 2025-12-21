prism.registerActor("Glowstalk", function()
   local baseLight = prism.components.Light(prism.Color4.LIME * 1.5, 3, prism.lighteffects.Sin())
   local offLight = baseLight:clone()
   --- @cast offLight Light
   offLight.radius = 0

   return prism.Actor.fromComponents {
      prism.components.Name("Glowstalk"),
      prism.components.Position(),
      prism.components.Drawable { index = 35, color = prism.Color4.LIME },
      prism.components.ConditionHolder(),
      baseLight,
      prism.components.LightModulate({
         [0] = baseLight,
         [8] = offLight,
      }, 16),
   }
end)
