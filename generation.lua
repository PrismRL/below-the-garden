local boundsx = 60 -- 1..60
local boundsy = 30 -- 1..30

--- Finds valid door positions and spawns DoorProxy actors.
--- Works for any carved room shape.
--- @param builder LevelBuilder
--- @param rng RNG
---    opts.minDoors integer?
---    opts.maxDoors integer?
local function addDoors(builder, rng)
   print "ADDING DOORS"

   local candidates = {}

   local tl, br = builder:getBounds()
   for x = tl.x - 1, br.x + 1 do
      for y = tl.y - 1, br.y + 1 do
         local cell = builder:getCell(x, y)
         if not cell then
            local count = 0

            for _, d in ipairs(prism.Vector2.neighborhood4) do
               local nx, ny = x + d.x, y + d.y
               local ncell = builder:get(nx, ny)
               if ncell then
                  count = count + 1
               end
            end

            if count == 1 then
               table.insert(candidates, {
                  x = x,
                  y = y,
               })
            end
         end    
      end
   end

   print(#candidates)

   if #candidates == 0 then return end

   for _ = 1, 5 do
      local idx = rng:random(1, #candidates)
      local d = table.remove(candidates, idx)

      builder:addActor(
         prism.actors.DoorProxy(),
         d.x,
         d.y
      )
   end
end

local function makeRoom(rng)
   local b = prism.LevelBuilder()

   local w = rng:random(5, 9)
   local h = rng:random(5, 9)

   b:rectangle("fill", 2, 2, w - 1, h - 1, prism.cells.Floor)

   addDoors(b, rng, {
      minDoors = 5,
      maxDoors = 5
   })

   print("ROOM DOOR COUNT", #b:query(prism.components.DoorProxy):gather())

   return b
end

--- Creates an L-shaped hallway room.
--- The hallway has two legs with configurable thickness.
--- @param rng RNG
--- @return LevelBuilder
local function makeHallwayL(rng)
   local b = prism.LevelBuilder()

   -- hallway thickness (width)
   local t = rng:random(2, 3)

   -- leg lengths
   local lenA = rng:random(4, 8)
   local lenB = rng:random(4, 8)

   -- orientation
   -- true = horizontal first, false = vertical first
   local horizFirst = rng:random() < 0.5

   -- base origin (leave margin so doors don't clip)
   local ox, oy = 2, 2

   if horizFirst then
      -- horizontal leg
      b:rectangle(
         "fill",
         ox,
         oy,
         ox + lenA,
         oy + t - 1,
         prism.cells.Floor
      )

      -- vertical leg
      b:rectangle(
         "fill",
         ox + lenA - (t - 1),
         oy,
         ox + lenA,
         oy + lenB,
         prism.cells.Floor
      )
   else
      -- vertical leg
      b:rectangle(
         "fill",
         ox,
         oy,
         ox + t - 1,
         oy + lenA,
         prism.cells.Floor
      )

      -- horizontal leg
      b:rectangle(
         "fill",
         ox,
         oy + lenA - (t - 1),
         ox + lenB,
         oy + lenA,
         prism.cells.Floor
      )
   end

   addDoors(b, rng)

   return b
end

--- Creates a circular room using LevelBuilder:ellipse.
--- @param rng RNG
--- @return LevelBuilder
local function makeCircleRoom(rng)
   local b = prism.LevelBuilder()

   -- radius
   local r = rng:random(3, 6)

   -- center (leave margin so doors form cleanly)
   local cx = r + 2
   local cy = r + 2

   b:ellipse(
      "fill",
      cx,
      cy,
      r,
      r,
      prism.cells.Floor
   )

   addDoors(b, rng)

   return b
end

--- Creates an elliptical room (non-uniform radii).
local function makeEllipseRoom(rng)
   local b = prism.LevelBuilder()

   local rx = rng:random(3, 7)
   local ry = rng:random(3, 6)

   local cx = rx + 2
   local cy = ry + 2

   b:ellipse(
      "fill",
      cx,
      cy,
      rx,
      ry,
      prism.cells.Floor
   )

   addDoors(b, rng)

   return b
end


local function makeRandomRoom(rng)
   local roll = rng:random()

   if roll < 0.25 then
      return makeHallwayL(rng)
   elseif roll < 0.45 then
      return makeCircleRoom(rng)
   elseif roll < 0.60 then
      return makeEllipseRoom(rng)
   else
      return makeRoom(rng)
   end
end

local function doorNormal(builder, x, y)
   for _, d in ipairs(prism.Vector2.neighborhood4) do
      if builder:get(x + d.x, y + d.y) then
         return prism.Vector2(-d.x, -d.y) -- outward
      end
   end
end

--- @param builder LevelBuilder
--- @param rng RNG
local function tryAccrete(builder, rng)
   local anchors = builder:query(prism.components.DoorProxy):gather()
   if #anchors == 0 then return false end

   local anchor = anchors[rng:random(1, #anchors)]
   local ax, ay = anchor:expectPosition():decompose()

   local normal = doorNormal(builder, ax, ay)
   if not normal then return false end

   local room = makeRandomRoom(rng)
   local rs, rf = room:getBounds()

   assert(#room:query(prism.components.DoorProxy):gather() > 0)

   for rdoor in room:query(prism.components.DoorProxy):iter() do
      local rx, ry = rdoor:expectPosition():decompose()

      -- hallway length (0 = direct attach)
      local hallLen = (rng:random() < 0.35) and rng:random(2, 4) or 0

      -- align room door to anchor + hallway offset
      local ox = ax + normal.x * hallLen - (rx - rs.x)
      local oy = ay + normal.y * hallLen - (ry - rs.y)

      ----------------------------------------------------------------
      -- validate hallway space
      ----------------------------------------------------------------
      local hx, hy = ax, ay
      for i = 1, hallLen do
         hx = hx + normal.x
         hy = hy + normal.y

         if hx < 1 or hx > boundsx or hy < 1 or hy > boundsy then
            goto continue
         end

         for dx = -1, 1 do
            for dy = -1, 1 do
               if dx ~= 0 or dy ~= 0 then
                  if builder:get(hx + dx, hy + dy) then
                     goto continue
                  end
               end
            end
         end
      end

      ----------------------------------------------------------------
      -- validate room placement
      ----------------------------------------------------------------
      for x = rs.x, rf.x do
         for y = rs.y, rf.y do
            local cell = room:get(x, y)
            if cell then
               local gx = ox + (x - rs.x)
               local gy = oy + (y - rs.y)

               if gx < 1 or gx > boundsx or gy < 1 or gy > boundsy then
                  goto continue
               end

               for dx = -1, 1 do
                  for dy = -1, 1 do
                     if dx ~= 0 or dy ~= 0 then
                        if builder:get(gx + dx, gy + dy) then
                           goto continue
                        end
                     end
                  end
               end
            end
         end
      end

      ----------------------------------------------------------------
      -- commit placement
      ----------------------------------------------------------------
      builder:blit(room, ox, oy)

      -- carve hallway
      hx, hy = ax, ay
      for i = 1, hallLen do
         hx = hx + normal.x
         hy = hy + normal.y
         builder:set(hx, hy, prism.cells.Floor())
      end

      -- open the anchor tile
      builder:set(ax, ay, prism.cells.Floor())

      -- consume doors
      builder:removeActor(anchor)
      builder:removeActor(rdoor)

      return true
   end

   ::continue::
   return false
end

--- @param builder LevelBuilder
--- @param rng RNG
local function randomFloor(builder, rng)
   local floors = {}

   for x = 1, boundsx do
      for y = 1, boundsy do
         if builder:get(x, y) then
            table.insert(floors, { x = x, y = y })
         end
      end
   end

   if #floors == 0 then
      error("No floor tiles to place player")
   end

   return floors[rng:random(1, #floors)]
end

--- @param seed any
--- @return LevelBuilder
return function(seed, player)
   local builder = prism.LevelBuilder()
   builder:addSeed(seed)

   local rng = prism.RNG(seed)

   local boundsx, boundsy = 60, 30
   builder:rectangle("line", 1, 1, boundsx, boundsy, prism.cells.Wall)

   -- first room
   local first = makeRoom(rng)

   print("FIRST DOOR COUNT", #first:query(prism.components.DoorProxy):gather())
   local x = rng:random(5, boundsx - 10)
   local y = rng:random(5, boundsy - 10)
   builder:blit(first, x, y)

   print("LEVEL DOOR COUNT", #builder:query(prism.components.DoorProxy):gather())

   -- accrete
   for i = 1, 10000 do
      tryAccrete(builder, rng) 
   end

      -- place player
   local p = randomFloor(builder, rng)
   builder:addActor(player, p.x, p.y)

   for x = 1, boundsx do
      for y = 1, boundsy do
         if not builder:get(x, y) then
            builder:set(x, y, prism.cells.Wall())
         end
      end
   end

   local doorCandidates = builder:query(prism.components.DoorProxy):gather()
   for _, doorCandidate in ipairs(doorCandidates) do
      builder:removeActor(doorCandidate)
   end
   
   return builder
end
