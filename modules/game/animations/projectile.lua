spectrum.registerAnimation("Projectile", function(source, destination, sprite, totalTime)
   --- @cast source Vector2
   --- @cast destination Vector2
   --- @cast sprite Sprite

   local path = prism.Bresenham(source.x, source.y, destination.x, destination.y):getPath()
   return spectrum.Animation(function(time, display)
      local index = math.floor(time / 0.05) + 1
      display:putSprite(path[index].x, path[index].y, sprite)
      return index == #path
   end)
end)
