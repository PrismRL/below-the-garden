prism.registerCell("Grass", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Grass"),
      prism.components.Drawable { index = ",", color = prism.Color4.LIME },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
