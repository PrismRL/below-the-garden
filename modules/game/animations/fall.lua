spectrum.registerAnimation("Fall", function(actor)
   local drawable = actor:expect(prism.components.Drawable)
   local blank = { index = " ", layer = 2 }
   return spectrum.Animation({ drawable, blank, drawable, blank }, 0.1, "pauseAtEnd")
end)
