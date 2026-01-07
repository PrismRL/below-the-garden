prism.registerCell("Pit", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Pit"),
      prism.components.Drawable { index = 178, color = prism.Color4.DARK },
      prism.components.Collider({ allowedMovetypes = { "fly" } }),
      prism.components.Void(),
   }
end)
