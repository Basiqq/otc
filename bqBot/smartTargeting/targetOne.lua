setDefaultTab("Target")
addSeparator("Separator")
local lastTarget = nil

-- escape when attacking will reset hold target
onKeyPress(function(keys)
    if keys == "Escape" and lastTarget then
        lastTarget = nil
    end
end)

macro(100, "Hold Target", function()
    -- if attacking then save it as target, but check pos z in case of marking by mistake on other floor

    local target = g_game.getAttackingCreature()
    if(target) then
        lastTarget = target
    elseif(lastTarget and lastTarget:getHealthPercent() > 0 and ((target and target:getId()) or 0) ~= lastTarget:getId()) then
        g_game.attack(lastTarget)
    end
end) 