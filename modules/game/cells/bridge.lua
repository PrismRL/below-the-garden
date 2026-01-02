prism.registerCell("Bridge", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Bridge"),
      prism.components.Collider { allowedMovetypes = { "walk", "fly" } },
      prism.components.Drawable {
         index = 241,
         color = prism.Color4.BROWN,
      },
      prism.components.BridgeComponent(),
   }
end)
