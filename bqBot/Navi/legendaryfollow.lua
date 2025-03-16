setDefaultTab("bq")
followName = "autofollow"
if not storage[followName] then storage[followName] = { player = 'name'} end
local toFollowPos = {}

leaderPositions = {}
local leaderDirections = {}
local leader
local lastLeaderFloor
local ropeId = 646
local standTime = now
BotServerFollow = 0

FloorChangers = {
  RopeSpots = {
    Up = {386},
    Down = {}
  },
  Use = {
    Up = {1948, 5542, 16693, 16692, 1723, 7771},
    Down = {435}
  }
}

local Objects = {435, 1948, 5111, 5102, 17574, 17565}
local Doors = {7727, 8265, 1629, 1632, 5129, 5120, 8266, 7728, 17574, 17565, 137, 1629, 1632, 1642, 1646, 1648, 1669, 1672, 1678, 1680, 1683, 1692, 1696, 1723, 17701, 17710, 1948, 2179, 4912, 5006, 5007, 5102, 5107, 5111, 5115, 5116, 5120, 5122, 5124, 5125, 5129, 5291, 5542, 5732, 5735, 5736, 5739, 6205, 6207, 6248, 6249, 6251, 6252, 6256, 6260, 6264, 7038, 7047, 7131, 7712, 7714, 7715, 7719, 7725, 7727, 7771, 8265, 8367, 9352, 9357, 11705, 16692, 16693, 17565, 17574, 23873, 30042, 30049, 30772, 30774, 6207, 7725}

local function handleUse(pos)
  local lastZ = posz()
  if posz() == lastZ then
    local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
    if newTile then
      g_game.use(newTile:getTopUseThing())
    end
  end
end

local function handleRope(pos)
  local lastZ = posz()
  if posz() == lastZ then
    local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
    if newTile then
      useWith(ropeId, newTile:getTopUseThing())
    end
  end
end

local floorChangeSelector = {
  RopeSpots = {Up = handleRope, Down = handleRope},
  Use = {Up = handleUse, Down = handleUse}
}

local function distance(pos1, pos2)
  local pos2 = pos2 or player:getPosition()
  return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

if not getDistanceBetween then
  getDistanceBetween = function(pos1, pos2)
    pos2 = pos2 or player:getPosition()
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
  end
end

local function executeClosest(possibilities)
  local closest
  local closestDistance = 99
  for _, data in ipairs(possibilities) do
    local dist = distance(data.pos)
    if dist < closestDistance then
      closest = data
      closestDistance = dist
    end
  end
  if closest then
    closest.changer(closest.pos)
    return true
  end
  return false
end

local function handleFloorChange()
  local range = 1
  local p = player:getPosition()
  local possibleChangers = {}
  for _, dir in ipairs({"Down", "Up"}) do
    for changer, data in pairs(FloorChangers) do
      for x = -range, range do
        for y = -range, range do
          local tile = g_map.getTile({x = p.x + x, y = p.y + y, z = p.z})
          if tile and tile:getTopUseThing() then
            if table.find(data[dir], tile:getTopUseThing():getId()) then
              table.insert(possibleChangers, {changer = floorChangeSelector[changer][dir], pos = {x = p.x + x, y = p.y + y, z = p.z}})
            end
          end
        end
      end
    end
  end
  if #possibleChangers > 0 then
    return executeClosest(possibleChangers)
  end
  return false
end

local function levitate(dir)
  turn(dir)
  schedule(200, function()
    say('exani hur "down')
    say('exani hur "up')
  end)
end

local function matchPos(p1, p2)
  return (p1.x == p2.x and p1.y == p2.y)
end

local function handleUsing()
  if BotServerFollow == 0 then
    handleFloorChange()
  else
    local usePos = leaderUsePositions and leaderUsePositions[posz()]
    if usePos then
      local useTile = g_map.getOrCreateTile(usePos)
      if useTile then
        use(useTile:getTopUseThing())
      end
    end
  end
end

local function useRope(pos)
  if not pos then
    pos = player:getPosition()
  end
  local dirs = {{0, 0}, {-1, 0}, {1, 0}, {0, -1}, {0, 1}, {1, -1}, {1, 1}, {-1, 1}, {-1, -1}}
  for i = 1, #dirs do
    local tpos = {x = pos.x + dirs[i][1], y = pos.y + dirs[i][2], z = posz()}
    local tile = g_map.getTile(tpos)
    if tile and tile:getGround() then
      local ropeSpots = FloorChangers.RopeSpots.Up
      if table.contains(ropeSpots, tile:getGround():getId()) then
        local waitTime = getDistanceBetween(player:getPosition(), tpos) * 60
        handleRope(tpos)
        delay(waitTime)
        return true
      end
    end
  end
  return false
end

local function getStandTime()
  return now - standTime
end

local function handleDoorsFromFollow2()
  local position = pos()
  if not player:isWalking() then
    for i, interact in ipairs(Doors) do
      if (player:getDirection() == 1 or player:getDirection() == 3) then
        for x = -1, 2, 2 do
          position["x"] = posx() + x
          position["y"] = posy()
          for y = -1, 3, 2 do
            local tile = g_map.getTile(position)
            if tile then
              for u, item in ipairs(tile:getItems()) do
                if item:getId() == interact then
                  g_game.use(item)
                  return true
                end
              end
            end
            position["y"] = posy() + y
          end
        end
      end
      position = pos()
      if (player:getDirection() == 0 or player:getDirection() == 2) then
        for y = -1, 2, 2 do
          position["x"] = posx()
          position["y"] = posy() + y
          for x = -1, 3, 2 do
            local tile = g_map.getTile(position)
            if tile then
              for u, item in ipairs(tile:getItems()) do
                if item:getId() == interact then
                  g_game.use(item)
                  return true
                end
              end
            end
            position["x"] = posx() + x
          end
        end
      end
      position = pos()
    end
  end
  return false
end


ultimateFollow = macro(50, "FLW", function()
  if not player:isWalking() and handleDoorsFromFollow2() then
    return
  end

  if not leader then
    local leaderPos = leaderPositions[posz()]
    if leaderPos and getDistanceBetween(player:getPosition(), leaderPos) > 0 then
      autoWalk(leaderPos, 70, {ignoreNonPathable=true, precision=0})
      delay(200)
      return
    end
    if BotServerFollow == 0 then
      if handleFloorChange() then return end
      local dir = leaderDirections[posz()]
      if dir then
        levitate(dir)
      end
    else
      local levitatePos = listenedLeaderPosDir
      if levitatePos and matchPos(player:getPosition(), levitatePos) then 
        levitate(listenedLeaderDir)
        return
      end
      if useRope(leaderPos) then return end
      handleUsing()
    end
  else
    listenedLeaderPosDir = nil
    listenedLeaderDir = nil
    local lpos = leader:getPosition()
    local parameters = {ignoreNonPathable=true, precision=1, ignoreCreatures=true}
    local path = findPath(player:getPosition(), lpos, 40, parameters)
    local dist = getDistanceBetween(player:getPosition(), lpos)
    if dist > 1 and not path then
      handleUsing()
    elseif dist > 2 then
      if getStandTime() > 500 then
        autoWalk(lpos, 40, parameters)
        delay(200)
      end
    end
  end
end)

UI.Label("Follows:")
UI.TextEdit(storage.followLeader or "Basiq", function(widget, text)
  storage.followLeader = text
  leader = getCreatureByName(text)
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if ultimateFollow.isOff() then return end
  if creature:getName() == player:getName() then
    standTime = now
    return
  end
  if creature:getName():lower() ~= storage.followLeader:lower() then return end
  if newPos then
    leaderPositions[newPos.z] = newPos
    lastLeaderFloor = newPos.z
    if newPos.z == posz() then
      leader = creature
    else
      leader = nil
    end
  else
    leader = nil
  end
  if oldPos then
    if newPos and oldPos.z ~= newPos.z then
      leaderDirections[oldPos.z] = creature:getDirection()
    end
    local oldTile = g_map.getTile(oldPos)
    local walkPrecision = 1
    if oldTile then
      if not oldTile:hasCreature() then
        walkPrecision = 0
      end
    end    
    autoWalk(oldPos, 40, {ignoreNonPathable=1, precision=walkPrecision})
  end
end)

onCreatureAppear(function(creature)
  if ultimateFollow.isOff() then return end
  if creature:getPosition().z ~= posz() then return end
  if creature:getName():lower() == storage.followLeader:lower() then
    leader = creature
  elseif creature:getName() == player:getName() then
    if lastLeaderFloor and lastLeaderFloor == posz() then
      leader = getCreatureByName(storage.followLeader)
    end
  end
end)

onCreatureDisappear(function(creature)
  if ultimateFollow.isOff() then return end
  if creature:getPosition().z == posz() then return end
  if creature:getName():lower() == storage.followLeader:lower() then
    leader = nil
  elseif creature:getName() == player:getName() and posz() ~= lastLeaderFloor then
    leader = nil
  end
end)

leader = getCreatureByName(storage.followLeader)

---------------------------
commandLeader = "Void"
---------------------------
commandLeader = commandLeader:lower()
leaderUsePositions = {}
listenedLeaderPosDir = nil
listenedLeaderDir = nil