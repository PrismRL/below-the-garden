prism.registerTarget("EquippedTarget", function(slot, ...)
   return prism.Target(...):outsideLevel():filter(function(level, owner, targetObject, previousTargets)
      local equipper = owner:expect(prism.components.Equipper)
      if slot then return equipper:get(slot) == targetObject end
      return equipper:isEquipped(targetObject)
   end)
end)
