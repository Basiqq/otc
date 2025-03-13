setDefaultTab("Target")
-- Store target names and their order
local targetList = {}
local targetOrder = {}
local SMTSPanelName = "SMTargetSelection"

-- Load UI from .otui file
local ui = UI.createWidget("SMTargetSelectionPanel")

local SMTSlist = ui.SMTSlistPanel.SMTSlist
local SMTSaddButton = ui.SMTSbuttons.SMTSadd
local SMTSremoveButton = ui.SMTSbuttons.SMTSremove
local SMTSRange = ui.SMTSRange.Range  -- Get the range UI element

-- Load the stored range value or default to 10
local storedRange = tonumber(storage.range) or 10
SMTSRange:setText(tostring(storedRange))  -- Set the text of the range UI box to the stored value

-- Function to save the range value to storage when it's changed
SMTSRange.onTextChange = function(widget, newText)
    local newRange = tonumber(newText)
    if newRange then
        -- Ensure the range value is within bounds (1 to 10)
        newRange = math.max(1, math.min(newRange, 10))
        storage.range = newRange  -- Save the new range value to storage
    end
end

local function setData()
    if targetOrder then
        for _, name in ipairs(targetOrder) do
            local widget = UI.createWidget("SMTargetSelectionLabel", ui.SMTSlistPanel.SMTSlist)
            widget:setText(name)
        end
    end
end

if type(storage.targetList) == "table" then
    targetList = storage.targetList
end

if type(storage.targetOrder) == "table" then
    targetOrder = storage.targetOrder
else
    storage.targetOrder = {}
end

setData()

-- Function to add a target
SMTSaddButton.onClick = function()
    local options = {}
    options.title = "Add Target"
    modules.client_textedit.show("", options, function(text)
        local newTargets = {}  -- Create a table to hold individual creature names
        
        -- Split the input text by commas, while considering spaces
        for targetName in text:gmatch("([^,]+)") do
            table.insert(newTargets, targetName:match("^%s*(.-)%s*$"))  -- Trim leading and trailing spaces
        end
        
        -- Add each individual creature name to the list
        for _, targetName in ipairs(newTargets) do
            local widget = UI.createWidget("SMTargetSelectionLabel", ui.SMTSlistPanel.SMTSlist)
            widget:setText(targetName)
            table.insert(targetOrder, targetName)
            targetList[targetName] = true
        end
        storage.targetList = targetList
        storage.targetOrder = targetOrder
    end)    
end


-- Function to find index of an element in a table
local function getIndex(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Function to remove a target
SMTSremoveButton.onClick = function()
    local entry = ui.SMTSlistPanel.SMTSlist:getFocusedChild()
    if not entry then return end
    local text = entry:getText()
    targetList[text] = nil
    local index = getIndex(targetOrder, text)  -- Use getIndex function here
    if index then
        table.remove(targetOrder, index)
    end
    entry:destroy()
    storage.targetList = targetList
    storage.targetOrder = targetOrder
end

local escapeTimer = now
-- Attack function
macro(1, "Smarter Targeting", function()
    local battlelist = getSpectators()
    local range = tonumber(ui.SMTSRange.Range:getText()) or 10  -- Default range is 10
    local closest = range  -- Set the closest distance to the range value
    local target = nil
    local foundFromList = false  -- Flag to track if a target from the list is found
    local sameTargets = {}  -- Table to store monsters with the same name in the order list and in the same range
    local lowestHealthTarget = nil  -- Variable to store the target with the lowest health

    -- Check Existing Target:
    local targetedMonster = g_game.getAttackingCreature()
    if targetedMonster and targetedMonster:isMonster() then
        -- Check if the targeted monster is still a valid target from the order list
        if targetOrder[targetedMonster:getName():lower()] then
            -- Check if the target's position or health has changed
            local currentPosition = player:getPosition()
            local targetPosition = targetedMonster:getPosition()
            local currentHealth = targetedMonster:getHealthPercent()
            local previousPosition = targetPositions[targetedMonster:getId()]
            local previousHealth = targetHealths[targetedMonster:getId()]

            if previousPosition and previousHealth then
                if currentPosition ~= previousPosition or currentHealth ~= previousHealth then
                    -- If position or health has changed, reevaluate if it's still the best target
                    -- (You may want to put the reevaluation logic here)
                else
                    return  -- If still a valid target from the order list and no change in position or health, return
                end
            end

            -- Store the current position and health for future checks
            targetPositions[targetedMonster:getId()] = currentPosition
            targetHealths[targetedMonster:getId()] = currentHealth
            return  -- If still a valid target from the order list and position or health not checked, return
        end
    end

    -- Loop through targets in the order list
    for _, name in ipairs(targetOrder) do
        for key, val in pairs(battlelist) do
            if val:isMonster() and val:getName():lower():match("^" .. name:lower():gsub("%*", ".*")) then
                local distance = getDistanceBetween(player:getPosition(), val:getPosition())
                if distance <= range then
                    closest = distance
                    target = val
                    foundFromList = true  -- Set flag to true as target from list is found
                    table.insert(sameTargets, val)  -- Add target to sameTargets table
                end
            end
        end
        -- If a target from the order list is found, break out of the loop
        if foundFromList then
            break
        end
    end

    -- If no target from the order list is found, choose the closest target
    if not foundFromList then
        for key, val in pairs(battlelist) do
            if val:isMonster() then
                local distance = getDistanceBetween(player:getPosition(), val:getPosition())
                if distance <= range then
                    closest = distance
                    target = val
                    table.insert(sameTargets, val)  -- Add target to sameTargets table
                end
            end
        end
    end

    -- If there are multiple targets with the same name and in the same range, find the one with the lowest health
    if #sameTargets > 1 then
        local lowestHealth = 101  -- Initialize with a high value
        for _, sameTarget in ipairs(sameTargets) do
            if sameTarget:getHealthPercent() < lowestHealth then
                lowestHealth = sameTarget:getHealthPercent()
                lowestHealthTarget = sameTarget
            end
        end
        target = lowestHealthTarget  -- Update target to the one with the lowest health
    end

    -- Attack the target if it's not nil, not in a protection zone, and not already being attacked
    if target and not isInPz() then
        local currentTarget = g_game.getAttackingCreature()
        if not currentTarget or currentTarget:getId() ~= target:getId() then
            g_game.attack(target)
        end
    end
end)
UI.Separator()