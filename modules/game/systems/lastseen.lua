--- @class LastSeenSystem : System
local LastSeenSystem = prism.System:extend "LastSeenSystem"

function LastSeenSystem:onTurn(level, actor)
   if not actor:has(prism.components.PlayerController) then
      return
   end

   for actor, lastseen, senses in level:query(prism.components.LastSeen, prism.components.Senses):iter() do
      --- @cast lastseen LastSeen
      lastseen.duration = (lastseen.duration or 0) - 1
      if lastseen.duration <= 0 then
         print "REMOVING LAST SEEN"
         lastseen.position = nil
         lastseen.duration = nil
      end

      --- @cast senses Senses
      local seenActor = senses:query(level, unpack(lastseen.components)):first()
      if seenActor then
         print "APPLYING LAST SEEN"
         lastseen.position = seenActor:expectPosition()
         lastseen.duration = 20

         local friends = senses:query(level, actor:get(prism.components.Faction).super):gather()
         for _, friend in ipairs(friends) do
            local olast = friend:get(prism.components.LastSeen)
            if olast then
               olast.position = seenActor:expectPosition()
               olast.duration = 20
            end
         end
      end
   end
end


return LastSeenSystem