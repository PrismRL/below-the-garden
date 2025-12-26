prism.registerActor("Tombstone", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Tombstone"),
      prism.components.Drawable { index = "D", color = prism.Color4.GREY },
      prism.components.Position(),
      prism.components.Collider { allowedMovetypes = { "fly" } },
   }
end)
