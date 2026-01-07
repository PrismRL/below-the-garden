local util = prism.levelgen.util

--- @class RoomManager : Object
--- @field builder LevelBuilder
--- @field wallDistanceField SparseGrid
--- @field rooms table
--- @overload fun(builder: LevelBuilder, wallDistanceField: SparseGrid) : RoomManager
local RoomManager = prism.Object:extend "RoomManager"

function RoomManager:__new(builder, wallDistanceField)
   self.builder = builder
   self.wallDistanceField = wallDistanceField

   self.rooms = self:findRooms(12)
   self:buildRoomGraph()
   self.rooms = self:mergeSmallRooms(self.rooms, 12)
end

function RoomManager:isRoomTile(x, y)
   local d = self.wallDistanceField:get(x, y)
   return d and d > 1 and util.isFloor(self.builder, x, y)
end

function RoomManager:findRoomCenter(tiles)
   local bestX, bestY
   local bestDist = -math.huge

   for x, y in tiles:each() do
      local d = self.wallDistanceField:get(x, y) or 0
      if d > bestDist then
         bestDist = d
         bestX, bestY = x, y
      end
   end

   return bestX and prism.Vector2(bestX, bestY) or nil
end

function RoomManager:findRooms(minRoomSize)
   minRoomSize = minRoomSize or 12

   local claimed = prism.SparseGrid()
   local rooms = {}

   local tl, br = self.builder:getBounds()

   for x = tl.x, br.x do
      for y = tl.y, br.y do
         if not claimed:get(x, y) and self:isRoomTile(x, y) then
            local tiles = prism.SparseGrid()
            local count = 0

            prism.bfs(prism.Vector2(x, y), function(bx, by)
               return self:isRoomTile(bx, by) and not claimed:get(bx, by)
            end, function(bx, by)
               tiles:set(bx, by, true)
               claimed:set(bx, by, true)
               count = count + 1
            end)

            rooms[#rooms + 1] = {
               tiles = tiles,
               size = count,
               isHallway = false,
               color = prism.Color4(math.random(), math.random(), math.random()),
               neighbors = {},
            }
         end
      end
   end

   local tileToRoom = prism.SparseGrid()
   for _, room in ipairs(rooms) do
      for x, y in room.tiles:each() do
         tileToRoom:set(x, y, room)
      end
   end

   for i = 1, 1 do
      for x = tl.x, br.x do
         for y = tl.y, br.y do
            -- Only consider unclaimed floor tiles
            if util.isFloor(self.builder, x, y) and not claimed:get(x, y) then
               local foundRoom

               for _, d in ipairs(prism.Vector2.neighborhood8) do
                  local r = tileToRoom:get(x + d.x, y + d.y)
                  if r then
                     if not foundRoom then foundRoom = r end
                  end
               end

               if foundRoom then
                  foundRoom.tiles:set(x, y, true)
                  foundRoom.size = foundRoom.size + 1
                  claimed:set(x, y, true)
               end
            end
         end
      end
   end

   for x = tl.x, br.x do
      for y = tl.y, br.y do
         if not claimed:get(x, y) and util.isFloor(self.builder, x, y) then
            local tiles = prism.SparseGrid()
            local count = 0

            prism.bfs(prism.Vector2(x, y), function(bx, by)
               return util.isFloor(self.builder, bx, by) and not claimed:get(bx, by)
            end, function(bx, by)
               tiles:set(bx, by, true)
               claimed:set(bx, by, true)
               count = count + 1
            end)

            rooms[#rooms + 1] = {
               tiles = tiles,
               size = count,
               isHallway = true,
               color = prism.Color4(math.random(), math.random(), math.random()),
               neighbors = {},
            }
         end
      end
   end

   -- after all room growth is complete
   for _, room in ipairs(rooms) do
      room.center = self:findRoomCenter(room.tiles)
   end

   return rooms
end

function RoomManager:buildRoomGraph()
   local tileToRoom = prism.SparseGrid()

   for _, room in ipairs(self.rooms) do
      for x, y in room.tiles:each() do
         tileToRoom:set(x, y, room)
      end
   end

   for x, y, room in tileToRoom:each() do
      for _, d in ipairs(prism.Vector2.neighborhood4) do
         local other = tileToRoom:get(x + d.x, y + d.y)
         if other and other ~= room then
            room.neighbors[other] = true
            other.neighbors[room] = true
         end
      end
   end
end

function RoomManager:mergeSmallRooms(rooms, minRoomSize)
   minRoomSize = minRoomSize or 9

   local alive = {}
   for _, r in ipairs(rooms) do
      alive[r] = true
   end

   local merged = true
   while merged do
      merged = false

      for _, room in ipairs(rooms) do
         if alive[room] and room.size < minRoomSize then
            local bestNeighbor
            local bestSize = math.huge

            for n in pairs(room.neighbors) do
               if alive[n] and n.size < bestSize then
                  bestNeighbor = n
                  bestSize = n.size
               end
            end

            if bestNeighbor then
               for x, y in room.tiles:each() do
                  if not bestNeighbor.tiles:get(x, y) then
                     bestNeighbor.tiles:set(x, y, true)
                     bestNeighbor.size = bestNeighbor.size + 1
                  end
               end

               for n in pairs(room.neighbors) do
                  if n ~= bestNeighbor and alive[n] then
                     n.neighbors[room] = nil
                     n.neighbors[bestNeighbor] = true
                     bestNeighbor.neighbors[n] = true
                  end
               end

               bestNeighbor.neighbors[room] = nil
               alive[room] = false
               merged = true
            end
         end
      end
   end

   local out = {}
   for _, r in ipairs(rooms) do
      if alive[r] then out[#out + 1] = r end
   end

   return out
end

--- Selects up to 4 rooms whose centers are maximally separated
--- using A* path distance between room centers.
--- @param blacklist table<table, boolean>? Rooms to exclude
--- @return table Array of 1–4 room tables
function RoomManager:getImportantRooms(blacklist)
   blacklist = blacklist or {}

   local nodes = {}

   for _, room in ipairs(self.rooms) do
      if room.center and not blacklist[room] then
         nodes[#nodes + 1] = {
            room = room,
            pos = room.center,
         }
      end
   end

   if #nodes == 0 then return {} end

   if #nodes <= 4 then
      local out = {}
      for _, n in ipairs(nodes) do
         out[#out + 1] = n.room
      end
      return out
   end

   local dist = {}

   local function pathDistance(a, b)
      local path = prism.astar(a.pos, b.pos, function(x, y)
         return util.isWalkable(self.builder, x, y)
      end)
      if not path then return math.huge end
      return #path:getPath()
   end

   for i = 1, #nodes do
      dist[i] = {}
   end

   for i = 1, #nodes do
      for j = i + 1, #nodes do
         local d = pathDistance(nodes[i], nodes[j])
         dist[i][j] = d
         dist[j][i] = d
      end
   end

   local a, b
   local best = -1

   for i = 1, #nodes do
      for j = i + 1, #nodes do
         local d = dist[i][j]
         if d < math.huge and d > best then
            best = d
            a, b = i, j
         end
      end
   end

   if not a then return { nodes[1].room } end

   local c
   local bestScore3 = -1

   for i = 1, #nodes do
      if i ~= a and i ~= b then
         local d1 = dist[i][a] or math.huge
         local d2 = dist[i][b] or math.huge

         if d1 < math.huge and d2 < math.huge then
            local score = (d1 * d1) * (d2 * d2)
            if score > bestScore3 then
               bestScore3 = score
               c = i
            end
         end
      end
   end

   local d
   local bestScore4 = -1

   if c then
      for i = 1, #nodes do
         if i ~= a and i ~= b and i ~= c then
            local d1 = dist[i][a] or math.huge
            local d2 = dist[i][b] or math.huge
            local d3 = dist[i][c] or math.huge

            if d1 < math.huge and d2 < math.huge and d3 < math.huge then
               local score = (d1 * d1) * (d2 * d2) * (d3 * d3)
               if score > bestScore4 then
                  bestScore4 = score
                  d = i
               end
            end
         end
      end
   end

   local result = {
      nodes[a].room,
      nodes[b].room,
   }

   if c then result[#result + 1] = nodes[c].room end

   if d then result[#result + 1] = nodes[d].room end

   return result
end

--- Identifies rooms whose removal would NOT disconnect the room graph.
--- Uses articulation-point detection on the room adjacency graph.
--- @return table Array of rooms safe to delete
function RoomManager:getRemovableRooms()
   local rooms = self.rooms
   if #rooms <= 1 then return {} end

   local index = 0
   local indices = {}
   local lowlink = {}
   local parent = {}
   local visited = {}
   local isArticulation = {}

   local function dfs(u)
      visited[u] = true
      index = index + 1
      indices[u] = index
      lowlink[u] = index

      local childCount = 0
      local isRoot = parent[u] == nil

      for v in pairs(u.neighbors) do
         if not visited[v] then
            parent[v] = u
            childCount = childCount + 1
            dfs(v)

            lowlink[u] = math.min(lowlink[u], lowlink[v])

            -- Articulation condition (non-root)
            if not isRoot and lowlink[v] >= indices[u] then isArticulation[u] = true end
         elseif v ~= parent[u] then
            lowlink[u] = math.min(lowlink[u], indices[v])
         end
      end

      -- Root articulation rule
      if isRoot and childCount > 1 then isArticulation[u] = true end
   end

   dfs(rooms[1])

   local removable = {}

   for _, room in ipairs(rooms) do
      if not isArticulation[room] then removable[#removable + 1] = room end
   end

   return removable
end

--- Finds rooms that are leaf nodes in the room graph (exactly one neighbor).
--- These are ideal candidates for locks, keys, dead-ends, or gated rewards.
--- @param opts table? { includeHallways: boolean }
--- @return table Array of room tables
function RoomManager:findLockableRooms(opts)
   opts = opts or {}
   local includeHallways = opts.includeHallways or true

   local lockable = {}

   for _, room in ipairs(self.rooms) do
      if room.center and (includeHallways or not room.isHallway) then
         local degree = 0
         for _ in pairs(room.neighbors) do
            degree = degree + 1
            if degree > 1 then break end
         end

         if degree == 1 then lockable[#lockable + 1] = room end
      end
   end

   return lockable
end

--- Creates a short loop between two rooms.
--- Selects the top-scoring room pairs based on
--- path distance divided by Euclidean distance,
--- then attempts to connect them with a short 4-way A* corridor.
--- @param maxTries integer? Number of top pairs to try
--- @return boolean success
function RoomManager:createLoop(generationInfo, maxTries)
   print("[createLoop] start")

   maxTries = maxTries or 5

   local rooms = self.rooms
   if #rooms < 2 then
      print("[createLoop] not enough rooms")
      return false
   end

   local function euclidSq(a, b)
      local dx = a.x - b.x
      local dy = a.y - b.y
      return dx * dx + dy * dy
   end

   local function findPath(a, b)
      local path = prism.astar(a, b, function(x, y)
         return util.isWalkable(self.builder, x, y)
      end, nil, nil, nil, prism.Vector2.neighborhood4)
      if not path then return nil end
      return path, #path:getPath()
   end

   print("[createLoop] evaluating room pairs")

   local candidates = {}

   for i = 1, #rooms do
      local a = rooms[i]
      if a.center then
         for j = i + 1, #rooms do
            local b = rooms[j]
            if b.center then
               local _, plen = findPath(a.center, b.center)
               if plen then
                  local d2 = euclidSq(a.center, b.center)
                  if d2 > 0 then
                     local score = plen / math.sqrt(d2)
                     candidates[#candidates + 1] = {
                        a = a,
                        b = b,
                        score = score,
                        plen = plen,
                        dist = math.sqrt(d2),
                        i = i,
                        j = j,
                     }

                     print(
                        string.format(
                           "[createLoop] pair %d-%d plen=%d dist=%.2f score=%.3f",
                           i,
                           j,
                           plen,
                           math.sqrt(d2),
                           score
                        )
                     )
                  end
               end
            end
         end
      end
   end

   if #candidates == 0 then
      print("[createLoop] no valid room pairs")
      return false
   end

   table.sort(candidates, function(a, b)
      return a.score > b.score
   end)

   print(string.format("[createLoop] trying top %d candidates", math.min(maxTries, #candidates)))

   for idx = 1, math.min(maxTries, #candidates) do
      local c = candidates[idx]
      local bestA, bestB = c.a, c.b

      print(string.format("[createLoop] attempt %d: rooms %d-%d score=%.3f", idx, c.i, c.j, c.score))

      local function passable(x, y)
         local isWall = util.isWall(self.builder, x, y)
         local isRoom = bestA.tiles:get(x, y) or bestB.tiles:get(x, y)
         local isBoundsX = x > 1 and x < generationInfo.w
         local isBoundsY = y > 1 and y < generationInfo.h

         for _, vec in ipairs(prism.Vector2.neighborhood8) do
            local dx, dy = x + vec.x, y + vec.y
            local isFloor = util.isWalkable(self.builder, dx, dy)
            if isFloor and not (bestA.tiles:get(dx, dy) or bestB.tiles:get(dx, dy)) then return false end
         end

         return (isWall or isRoom) and isBoundsX and isBoundsY
      end

      local path = prism.astar(bestA.center, bestB.center, passable, nil, nil, nil, prism.Vector2.neighborhood4)

      if path then
         local cost = path:getTotalCost()
         print("[createLoop] path cost:", cost)

         if cost <= math.huge then
            for _, p in ipairs(path:getPath()) do
               print(string.format("[createLoop] carving tile (%d,%d)", p.x, p.y))

               if not util.isFloor(self.builder, p.x, p.y) then self.builder:set(p.x, p.y, prism.cells.Floor()) end

               if not bestA.tiles:get(p.x, p.y) then
                  bestA.tiles:set(p.x, p.y, true)
                  bestA.size = bestA.size + 1
               end
            end

            bestA.neighbors[bestB] = true
            bestB.neighbors[bestA] = true

            print("[createLoop] loop created successfully")
            -- coroutine.yield(self.builder)
            return true
         else
            print("[createLoop] path too long, skipping")
         end
      else
         print("[createLoop] A* failed for this pair")
      end
   end

   print("[createLoop] all candidates failed")
   return false
end

return RoomManager
