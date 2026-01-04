prism.registerActor("Glowstalk", function()
   local baseLight = prism.components.Light(prism.Color4.LIME, 5, prism.lighteffects.Sin())
   local offLight = baseLight:clone()
   --- @cast offLight Light
   offLight.color = baseLight:getColor() / 2
   offLight.radius = 2

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
