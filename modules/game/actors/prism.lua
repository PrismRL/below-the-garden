local color = prism.Color4.fromHex(0x8aa1f6)
prism.registerActor("Prism", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Prism"),
      prism.components.Position(),
      prism.components.Drawable { index = 258, color = prism.Color4.PRISM, layer = 1 },
      prism.components.Item(),
      prism.components.Equipment("held"),
      prism.components.Prism(),
      prism.components.Light(prism.Color4.PRISM, 12, prism.lighteffects.Heartbeat { sharpness = 10, amplitude = 0.5 }),
   }
end)
