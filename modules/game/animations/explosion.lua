spectrum.registerAnimation("Explosion", function(tiles)
   --- @cast source Vector2
   --- @cast tiles SparseGrid

   return spectrum.Animation(function(time, display)
      local progress = math.min(time / 0.5, 1)
      for x, y in tiles:each() do
         display:putBG(x, y, prism.Color4.GREEN)
      end

      return progress == 1
   end)
end)
