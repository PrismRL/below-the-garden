prism.registerCell("Wall", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Wall"),
      prism.components.Drawable { index = "#", color = prism.Color4.GREY, layer = 2 },
      prism.components.Collider(),
      prism.components.Opaque(),
   }
end)
