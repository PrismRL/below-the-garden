spectrum.registerAnimation("Damage", function(actor)
   local drawable = actor:expect(prism.components.Drawable)
   return spectrum.Animation({
      { index = drawable.index, color = prism.Color4.WHITE, background = drawable.background },
   }, 0.15, "pauseAtEnd")
end)
