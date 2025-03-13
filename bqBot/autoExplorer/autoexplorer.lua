setDefaultTab("Cave")

addSeparator("separator")
local ui = UI.createWidget("AutoExplorerTitle")

local procedDist = 1
local maxWalkDist = 20
local pathMaxDist = 20
local maxStandTime = 2000

local nextPos = nil
local currentPos = nil
local lastPos = nil
local furdestDist = 0

-- Function to get walkable tiles
local getOkTiles = function()
    local tiles = {}
    for _, tile in ipairs(g_map.getTiles(posz())) do
        if tile:isWalkable() and findPath(pos(), tile:getPosition(), pathMaxDist) then
            table.insert(tiles, tile)
        end
    end
    return tiles
end

-- Function to get the first walkable position
local getFirstPos = function()
    local tiles = getOkTiles()
    if #tiles > 0 then
        return tiles[1]:getPosition()
    end
    return nil
end

local reset = function()
    nextPos = nil
    currentPos = nil
    lastPos = nil
    furdestDist = 0
end

local start = function()
    currentPos = getFirstPos()
    lastPos = table.copy(currentPos)
end

local restart = function()
    reset()
    start()
end

-- Reset if standing idle for too long
local function onMacroExecution()
    if not m_main.isOn() then return end
    if standTime() > maxStandTime then
        restart()
    end
end

macro(2000, onMacroExecution)

-- UI for Avoid Item
addLabel("", "Avoid")
if type(storage.avoidItemID) ~= "table" or not storage.avoidItemID[1] then
    storage.avoidItemID = {1387}  -- default item ID (example)
end

local avoidItemUI = UI.createWidget("AutoExplorerAvoid")
local avoidItem = avoidItemUI:recursiveGetChildById("avoiditemid")
avoidItem:setItemId(storage.avoidItemID[1])
avoidItem.onItemChange = function()
    storage.avoidItemID[1] = avoidItem:getItemId()  -- Update the stored item ID
end

-- Lure Text Box
addLabel("", "Lure")
addTextEdit("", storage.lureCount or "3", function(widget, text)
    storage.lureCount = tonumber(text) or 3
end)

-- Function to count monsters around
local countMonstersAround = function()
    local monsters = 0
    for _, creature in ipairs(getSpectators()) do
        if creature:isMonster() then
            monsters = monsters + 1
        end
    end
    return monsters
end

-- Avoid pathing on tiles with specified item ID
local isAvoidingItem = function(tile)
    if tile then
        local topItem = tile:getTopThing()
        if topItem and topItem:getId() == storage.avoidItemID[1] then
            return true  -- Tile contains the avoid item
        end
    end
    return false
end

-- Function to attempt a new path when avoiding a tile
local findNewPath = function()
    local tiles = getOkTiles()
    for _, tile in ipairs(tiles) do
        if not isAvoidingItem(tile) then
            return tile:getPosition()  -- Return a valid position not containing the avoid item
        end
    end
    return nil  -- No valid path found
end

-- Main macro loop for auto exploration
local function onMainMacroExecution()
    if not m_main.isOn() then return end  -- Ensure the script only runs if the macro is enabled

    if g_game.isAttacking() and (countMonstersAround() >= storage.lureCount) then return end

    if not currentPos then
        start()
    end

    if currentPos then
        -- Check if the next position is an avoidable tile
        local nextTile = g_map.getTile(currentPos)
        if nextTile and isAvoidingItem(nextTile) then
            nextTile:setText("Avoiding", "red")
            print("Avoiding tile with item ID: " .. storage.avoidItemID[1])

            -- Reset and find a new position
            reset()
            nextPos = findNewPath()
            if nextPos then
                currentPos = table.copy(nextPos)
            else
                print("No valid path found. Restarting exploration.")
                restart()
            end
            return  -- Exit the macro function to prevent moving onto the avoidable tile
        end

        -- Move to the current position if it's not avoidable
        autoWalk(currentPos)
    end

    -- Set the next position when close enough
    if nextPos and currentPos and distanceFromPlayer(currentPos) <= procedDist then
        local nextTile = g_map.getTile(nextPos)
        if nextTile then
            nextTile:setText("Pathing", "green")
        end
        lastPos = table.copy(currentPos)
        currentPos = table.copy(nextPos)
        furdestDist = 0
    end

    schedule(500, function()
        if not m_main.isOn() then
            reset()
        end
    end)
end

m_main = macro(500, "Auto Explorer", onMainMacroExecution)

-- Handling new things added to a tile
onAddThing(function(tile, thing)
    if not m_main.isOn() then return end
    if not currentPos then return end
    if not tile or not tile:isWalkable() then return end  -- Skip non-walkable tiles

    -- Avoid tile with the avoid item
    if isAvoidingItem(tile) then
        tile:setText("Avoiding", "red")
        print("Avoiding tile with item ID: " .. storage.avoidItemID[1])
        return
    end

    -- Find a valid path if the tile is okay
    local tPos = tile:getPosition()
    if tPos.z ~= posz() then return end

    schedule(100, function()
        if not findPath(pos(), tPos, pathMaxDist, {ignoreCreatures = true}) then return end
        if lastPos and tPos then
            local auxDist = getDistanceBetween(lastPos, tPos)
            if auxDist <= maxWalkDist and auxDist > furdestDist then
                nextPos = table.copy(tPos)
                furdestDist = auxDist
            end
        end
    end)
end)
