prism.registerCell("Floor", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Floor"),
      prism.components.Drawable { index = ".", color = prism.Color4.GREY, layer = 1 },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
