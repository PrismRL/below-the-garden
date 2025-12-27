local Drawable = prism.components.Drawable

local GrassAutoTile = prism.components.AutoTile {
   id = 4,
   drawables = {
      default = Drawable { index = ",", color = prism.Color4.LIME },
      plain = Drawable { index = ".", color = prism.Color4.LIME },
      apostrophe = Drawable { index = "'", color = prism.Color4.LIME },
   },
   rules = {
      {
         variations = {
            default = 150,
            plain = 100,
         },
      },
   },
   default = "default",
}

prism.registerCell("Grass", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Grass"),
      prism.components.Drawable { index = ",", color = prism.Color4.LIME },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
      GrassAutoTile,
   }
end)
