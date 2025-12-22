--- Removes doors (Door + DoorProxy) that are not between two opposite floors.
--- Valid if: (N and S are floors) OR (E and W are floors).
--- Assumes: wall == nil, non-nil == floor/door/etc.
--- Call this BEFORE final wall fill (nil -> Wall()).
--- @param builder LevelBuilder
local function pruneDoorsWithoutOppositeFloors(builder)
   local toRemove = {}

   local function shouldRemoveAt(x, y)
      local n = builder:get(x,     y - 1) ~= nil
      local s = builder:get(x,     y + 1) ~= nil
      local w = builder:get(x - 1, y    ) ~= nil
      local e = builder:get(x + 1, y    ) ~= nil

      -- Valid door if it separates two opposite walls
      if (n and s) or (w and e) then
         return false
      end

      return true
   end

   local function markBadDoors(query)
      for _, door in ipairs(query:gather()) do
         local x, y = door:expectPosition():decompose()
         if shouldRemoveAt(x, y) then
            table.insert(toRemove, door)
         end
      end
   end

   -- Prune both proxies and committed doors
   markBadDoors(builder:query(prism.components.DoorProxy))
   markBadDoors(builder:query(prism.components.Door))

   for _, door in ipairs(toRemove) do
      builder:removeActor(door)
   end
end