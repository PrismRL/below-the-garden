prism.registerCell("Water", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Water"),
      prism.components.Collider { allowedMovetypes = { "fly" } },
      prism.components.Drawable { index = "~", color = prism.Color4.BLUE, background = prism.Color4.NAVY / 2 },
      prism.components.Wet(),
   }
end)
