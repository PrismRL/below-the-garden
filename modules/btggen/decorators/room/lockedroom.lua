local util = prism.levelgen.util

local LockRoomDecorator = prism.levelgen.Decorator:extend "LockRoomDecorator"

--- Seals a room by walling off all exits except one door.
function LockRoomDecorator.tryDecorate(rng, builder, room)
   if not room or not room.tiles then return end

   local doorRoomPos
   local doorOutPos

   -- Step 1: collect all cardinal boundary pairs
   local cardinalPairs = {}

   for rx, ry in room.tiles:each() do
      local roomPos = prism.Vector2(rx, ry)

      for _, d4 in ipairs(prism.Vector2.neighborhood4) do
         local ox, oy = rx + d4.x, ry + d4.y

         if room.tiles:get(ox, oy) == nil
            and util.isWalkable(builder, ox, oy)
         then
            local outPos = prism.Vector2(ox, oy)

            -- Check that this is the ONLY external neighbor in neighborhood8
            local clean = true

            for _, d8 in ipairs(prism.Vector2.neighborhood8) do
               local nx, ny = rx + d8.x, ry + d8.y
               if room.tiles:get(nx, ny) == nil then
                  if nx ~= ox or ny ~= oy then
                     clean = false
                     break
                  end
               end
            end

            if clean then
               print "FOUND CLEAN"
               cardinalPairs[#cardinalPairs + 1] = {
                  room = roomPos,
                  out  = outPos,
               }
            end
         end
      end
   end


   if #cardinalPairs == 0 then return end

   local chosen = cardinalPairs[rng:random(1, #cardinalPairs)]
   doorRoomPos = chosen.room
   doorOutPos  = chosen.out

   -- Step 2: seal everything in neighborhood8 except the door positions
   for rx, ry in room.tiles:each() do
      for _, d in ipairs(prism.Vector2.neighborhood8) do
         local nx, ny = rx + d.x, ry + d.y
         local pos = prism.Vector2(nx, ny)

         if room.tiles:get(nx, ny) == nil then
            if pos ~= doorOutPos then
               builder:set(nx, ny, prism.cells.Wall())
               builder:set(rx, ry, prism.cells.Wall())
               
               for _, actor in ipairs(builder:query():at(nx, ny):collect()) do
                  builder:removeActor(actor)
               end

               for _, actor in ipairs(builder:query():at(rx, ry):collect()) do
                  builder:removeActor(actor)
               end
            end
         end
      end
   end

   -- Step 3: place door
   builder:set(doorRoomPos.x, doorRoomPos.y, prism.cells.Floor())
   builder:set(doorOutPos.x,  doorOutPos.y,  prism.cells.Floor())
   builder:addActor(
      prism.actors.LockedDoor(),
      doorRoomPos.x,
      doorRoomPos.y
   )

   for _, actor in ipairs(builder:query():at(rx, ry):collect()) do
      builder:removeActor(actor)
   end
end

return LockRoomDecorator
