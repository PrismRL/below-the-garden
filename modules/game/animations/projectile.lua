spectrum.registerAnimation("Projectile", function(source, destination, sprite, thrower)
   --- @cast source Vector2
   --- @cast destination Vector2
   --- @cast sprite Sprite
   --- @cast thrower Actor?

   local senses = thrower and thrower:get(prism.components.Senses)

   local path = prism.Bresenham(source.x, source.y, destination.x, destination.y):getPath()
   return spectrum.Animation(function(time, display)
      local index = math.floor(time / 0.05) + 1
      local x, y = path[index]:decompose()
      if not senses or senses.cells:get(x, y) then display:putSprite(path[index].x, path[index].y, sprite) end
      return index == #path
   end)
end)
