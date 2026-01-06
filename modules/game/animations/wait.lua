spectrum.registerAnimation("Wait", function(time)
   return spectrum.Animation({ { index = 0, layer = -1 } }, time or 0.3, "pauseAtEnd")
end)
