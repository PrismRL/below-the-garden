local util = prism.levelgen.util
local FirstThird = prism.levelgen.Generator:extend "FirstThird"

LEVELGENBOUNDSX, LEVELGENBOUNDSY = 60, 30
--- @return LevelBuilder
local function randomRoom(rng)
   --- @type RoomGenerator[]
   local rooms = {
      prism.roomgenerators.CircleRoomGenerator,
      prism.roomgenerators.EllipseRoomGenerator,
      prism.roomgenerators.HallwayLRoomGenerator,
      prism.roomgenerators.RectRoomGenerator,
      prism.roomgenerators.RingRoomGenerator
   }

   return rooms[rng:random(#rooms)]:_generate(rng)
end

local function doorNormal(builder, x, y)
   for _, d in ipairs(prism.Vector2.neighborhood4) do
      if util.isFloor(builder, x + d.x, y + d.y) then
         return prism.Vector2(-d.x, -d.y) -- outward
      end
   end
end

local function tryDoor(builder, room, rs, rf, ax, ay, normal, rdoor, rng)
   local rx, ry = rdoor:expectPosition():decompose()

   -- hallway length (0 = direct attach)
   local hallLen = (rng:random() < 0.2) and rng:random(1, 6) or 0

   -- offset room so its door aligns with anchor + hallway
   local ox = ax + normal.x * hallLen - (rx - rs.x)
   local oy = ay + normal.y * hallLen - (ry - rs.y)

   ----------------------------------------------------------------
   -- validate hallway (no touching floors, incl diagonals)
   ----------------------------------------------------------------
   local hx, hy = ax, ay
   for i = 1, hallLen do
      hx = hx + normal.x
      hy = hy + normal.y

      if hx < 1 or hx > LEVELGENBOUNDSX or hy < 1 or hy > LEVELGENBOUNDSY then return false end

      for _, d in ipairs(prism.Vector2.neighborhood8) do
         if util.isFloor(builder, hx + d.x, hy + d.y) then return false end
      end
   end

   ----------------------------------------------------------------
   -- validate room placement (no touching existing floors)
   ----------------------------------------------------------------
   for x = rs.x, rf.x do
      for y = rs.y, rf.y do
         if room:get(x, y) then
            local gx = ox + (x - rs.x)
            local gy = oy + (y - rs.y)

            if gx <= 1 or gx >= LEVELGENBOUNDSX or gy <= 1 or gy >= LEVELGENBOUNDSY then return false end

            for _, d in ipairs(prism.Vector2.neighborhood8) do
               if util.isFloor(builder, gx + d.x, gy + d.y) then return false end
            end
         end
      end
   end

   ----------------------------------------------------------------
   -- commit
   ----------------------------------------------------------------
   builder:blit(room, ox, oy)

   hx, hy = ax, ay
   for i = 1, hallLen do
      hx = hx + normal.x
      hy = hy + normal.y
      builder:set(hx, hy, prism.cells.Floor())
   end

   builder:set(ax, ay, prism.cells.Floor())

   -- remove consumed door proxies
   for _, door in ipairs(builder:query(prism.components.DoorProxy):at(ax, ay):gather()) do
      builder:removeActor(door)
   end

   for _, door in ipairs(builder:query(prism.components.DoorProxy):at(ox, oy):gather()) do
      builder:removeActor(door)
   end

   builder:addActor(prism.actors.Door(), ax, ay)

   return true
end


local function tryAccrete(builder, rng)
   local anchors = builder:query(prism.components.DoorProxy):gather()
   if #anchors == 0 then return false end

   local room = randomRoom(rng)
   local rs, rf = room:getBounds()

   assert(#room:query(prism.components.DoorProxy):gather() > 0)

   for _, anchor in ipairs(anchors) do
      local ax, ay = anchor:expectPosition():decompose()
      local normal = doorNormal(builder, ax, ay)

      if normal then
         for rdoor in room:query(prism.components.DoorProxy):iter() do
            if tryDoor(builder, room, rs, rf, ax, ay, normal, rdoor, rng) then
               coroutine.yield(builder)
               return true
            end
         end
      end
   end

   return false
end

--- @param rng RNG
---@param w integer
---@param h integer
---@return LevelBuilder
local function accrete(rng, w, h)
   local builder

   while true do
      builder = prism.LevelBuilder()
      builder:addSeed(rng:random())
      builder:rectangle("line", 1, 1, LEVELGENBOUNDSX, LEVELGENBOUNDSY, prism.cells.Wall)

      -- first room
      local first = randomRoom(rng)
      local x = rng:random(10, LEVELGENBOUNDSX - 10)
      local y = rng:random(10, LEVELGENBOUNDSY - 10)
      builder:blit(first, x, y)

      -- accretion loop
      local failures = 0
      while true do
         if not tryAccrete(builder, rng) then
            failures = failures + 1
            if failures > 500 then break end
         else
            --if MAPDEBUG then coroutine.yield(builder) end
         end
      end

      local distanceField = util.buildWallDistanceField(builder)
      local rooms = prism.levelgen.RoomManager(builder, distanceField).rooms
      if #rooms >= 10 then break end
   end

   return builder
end

local function mapdebug(builder, rooms)
   for _, room in ipairs(rooms) do
      if MAPDEBUG then
         for x, y in room.tiles:each() do
            builder:addActor(prism.Actor.fromComponents{
               prism.components.Drawable{
                  index = "!",
                  color = room.color
               },
               prism.components.Position(),
               prism.components.Spawner(),
               prism.components.Name("RoomProxy")
            }, x, y)
         end
      end
   end
   coroutine.yield(builder)

   for _, spawner in ipairs(builder:query(prism.components.Spawner):gather()) do
      builder:removeActor(spawner)
   end
   coroutine.yield(builder)
end

--- @param seed any
---@param w integer
---@param h integer
---@param depth integer
function FirstThird.generate(seed, w, h, depth, player)
   print(seed, w, h, depth, player)
   local rng = prism.RNG(seed)
   local builder = accrete(rng, w, h)

   for _, proxy in pairs(builder:query(prism.components.DoorProxy):gather()) do
      builder:removeActor(proxy)
   end
   coroutine.yield(builder)

   prism.decorators.ErosionDecorator.tryDecorate(rng, builder)
   builder:rectangle("line", 1, 1, LEVELGENBOUNDSX, LEVELGENBOUNDSY, prism.cells.Wall)
   coroutine.yield(builder)

   local distanceField = util.buildWallDistanceField(builder)
   local rooms = prism.levelgen.RoomManager(builder, distanceField).rooms
   mapdebug(builder, rooms)

   local decorators = prism.decorators
   local roomDecorators = {
      decorators.GraveyardDecorator,
      decorators.SunlightDecorator,
      decorators.MeadowDecorator,
      decorators.PitDecorator,
      decorators.WaterPitDecorator,
      decorators.TallGrassClearingDecorator
   }

   -- copy rooms
   local undecoratedRooms = {}
   for _, room in pairs(rooms) do
      table.insert(undecoratedRooms, room)
   end

   -- Fisher–Yates shuffle using rng
   local function shuffle(t, rng)
      for i = #t, 2, -1 do
         local j = rng:random(i)
         t[i], t[j] = t[j], t[i]
      end
   end

   local attempts = rng:random(3, 5)

   for i = 1, attempts do
      if #undecoratedRooms == 0 then break end

      -- pick a decorator type
      local decorator = roomDecorators[rng:random(#roomDecorators)]

      -- try rooms in random order
      shuffle(undecoratedRooms, rng)

      local decorated = false
      for i = 1, #undecoratedRooms do
         local room = undecoratedRooms[i]
         if decorator.tryDecorate(rng, builder, room) then
            coroutine.yield(builder)
            table.remove(undecoratedRooms, i)
            decorated = true
            break
         end
      end

      -- if not decorated, loop continues and picks another decorator type
      if not decorated then i = i - 1 end
   end

   prism.decorators.BridgeToFloorDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   prism.decorators.TallGrassNearWallsDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   prism.decorators.GrassSpreadDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   prism.decorators.GlowStalkDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   prism.decorators.PruneMisalignedDoorsDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   local rm = prism.levelgen.RoomManager(builder, distanceField)
   local rooms = rm.rooms
   mapdebug(builder, rooms)

   local used = {}

   local importantRooms = rm:getImportantRooms(used)
   assert(#importantRooms ==  3)

   local room = table.remove(importantRooms, rng:random(#importantRooms))
   used[room] = true
   builder:addActor(player, room.center:decompose())

   room = table.remove(importantRooms, rng:random(#importantRooms))
   builder:addActor(prism.actors.Prism(), room.center:decompose())

   room = table.remove(importantRooms, rng:random(#importantRooms))
   builder:addActor(prism.actors.Stairs(), room.center:decompose())

   local encounterDecorators = {
      prism.decorators.ThrumbleCampDecorator,
   }

   local encounterRooms = rm:getRemovableRooms()
   local encounterAttempts = depth < 2 and 1 or rng:random(2, 3)

   for _ = 1, encounterAttempts do
      if #encounterRooms == 0 then break end

      local decorator = encounterDecorators[rng:random(#encounterDecorators)]

      shuffle(encounterRooms, rng)

      for i = 1, #encounterRooms do
         local room = encounterRooms[i]
         if decorator.tryDecorate(rng, builder, room) then
            coroutine.yield(builder)
            table.remove(encounterRooms, i)
            used[room] = true
            break
         end
      end
   end

   for _, room in ipairs(rooms) do
      local d = distanceField:get(room.center:decompose())
      for _, oroom in ipairs(rooms) do
         if oroom ~= room and not used[oroom] and not used[room] then
            local od = distanceField:get(room.center:decompose())

            local path = prism.astar(room.center, oroom.center, function (x, y)
               return util.isFloor(builder, x, y)
            end)

            assert(path)
            if path:getTotalCost() < 10 then
               if od > d then
                  used[room] = true
               else
                  used[oroom] = true
               end
            end
         end
      end
   end

   local mediumEncounterDecorators = {
      prism.decorators.FrogDecorator,
   }

   local encounterAttempts = depth < 2 and 1 or rng:random(2, 3)
   for _ = 1, encounterAttempts do
      local deco = mediumEncounterDecorators[rng:random(#mediumEncounterDecorators)]
      for _, room in ipairs(rooms) do
         if not used[room] then
            if deco.tryDecorate(rng, builder, room) then break end
         end
      end
   end

   -- Easy spawns: remaining unused rooms
   for _, room in ipairs(rooms) do
      print("ROOM CHECK", used[room])
      if not used[room] then
         print "TRYING"
         prism.decorators.SqeetoSwarmDecorator.tryDecorate(rng, builder, room)
      end
   end
   coroutine.yield(builder)

   for x = 1, w do
      for y = 1, h do
         if not builder:get(x, y) then builder:set(x, y, prism.cells.Wall()) end
      end
   end

   local weapons = {
      prism.actors.Sling,
      prism.actors.Sword,
      prism.actors.Hammer
   }

   local misc = {
      prism.actors.Torch,
   }
   prism.decorators.FireflyDecorator.tryDecorate(rng, builder)
   coroutine.yield(builder)

   return builder
end

return FirstThird