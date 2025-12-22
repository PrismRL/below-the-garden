spectrum.registerAnimation("Projectile", function(source, destination, sprite, totalTime)
   --- @cast source Vector2
   --- @cast destination Vector2
   --- @cast sprite Sprite

   totalTime = source:distance(destination) * 0.04
   return spectrum.Animation(function(time, display)
      local progress = math.min(time / totalTime, 1)
      local position = source:lerp(destination, progress)
      display:putSprite(math.floor(position.x), math.floor(position.y), sprite)
      return time >= totalTime
   end)
end)
