local color = prism.Color4.fromHex(0x8aa1f6)
prism.registerActor("Prism", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Prism"),
      prism.components.Position(),
      prism.components.Drawable { index = 258, color = color, layer = 1 },
      prism.components.Item(),
   }
end)
