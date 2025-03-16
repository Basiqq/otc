local doorIds = {137, 1629, 1632, 1642, 1646, 1648, 1669, 1672, 1678, 1680, 1683, 1692, 1696, 1723, 17701, 17710, 1948, 2179, 4912, 5006, 5007, 5102, 5107, 5111, 5115, 5116, 5120, 5122, 5124, 5125, 5129, 5291, 5542, 5732, 5735, 5736, 5739, 6205, 6207, 6248, 6249, 6251, 6252, 6256, 6260, 6264, 7038, 7047, 7131, 7712, 7714, 7715, 7719, 7725, 7727, 7771, 8265, 8367, 9352, 9357, 11705, 16692, 16693, 17565, 17574, 23873, 30042, 30049, 30772, 30774, 6207, 7725}

local moveTime = 1    -- Wait time between Move, 2000 milliseconds = 2 seconds
local moveDist = 2        -- How far to Walk
local useTime = 4000    -- Wait time between Use, 2000 milliseconds = 2 seconds
local useDistance = 1     -- How far to Use
local waitTime = 1

local function properTable(t)
    local r = {}
    for _, entry in pairs(t) do
        table.insert(r, entry.id)
    end
    return r
end

clickDoor = macro(1000, "Doors", function()
    for i, tile in ipairs(g_map.getTiles(posz())) do
        local item = tile:getTopUseThing()
        if item and table.find(doorIds, item:getId()) then
            local tPos = tile:getPosition()
            local distance = getDistanceBetween(pos(), tPos)
            if (distance <= useDistance) then
                use(item)
                return delay(useTime)
            end

            if (distance <= moveDist and distance > useDistance) then
                if findPath(pos(), tPos, moveDist, { ignoreNonPathable = true, precision = 1 }) then
                    autoWalk(tPos, moveTime, { ignoreNonPathable = true, precision = 1 })
                    return delay(waitTime)
                end
            end
        end
    end
end)
UI.Separator()