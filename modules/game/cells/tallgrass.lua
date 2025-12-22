prism.registerCell("TallGrass", function()
   return prism.Cell.fromComponents {
      prism.components.Name("TallGrass"),
      prism.components.Collider{allowedMovetypes = {"walk", "fly"}},
      prism.components.Opaque(),
      prism.components.Drawable{index = "V"}
   }
end)