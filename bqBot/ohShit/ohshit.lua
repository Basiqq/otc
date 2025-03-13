setDefaultTab("Cave")
local ohshit = 5892
local ohshitshit
-- TP rock 5892
-- NOPVP scroll 31433
local pk = macro(1, "Oh Shit", function() end)
local whitelist = {} 

local function isInWhitelist(playerName)
    for name, _ in pairs(storage.ohshit_whitelist) do
        if name == playerName then
            return true
        end
    end
    return false
end

local function addToWhitelist(playerName)
    table.insert(whitelist, playerName)
end

local function removeFromWhitelist(playerName)
    for i, name in ipairs(whitelist) do
        if name == playerName then
            table.remove(whitelist, i)
            break
        end
    end
end

onTextMessage(function(mode, text)
    if pk.isOff() then return end
    if not text:lower():find("you lose") then return end

    if not g_game.isAttacking() or not g_game.getAttackingCreature():isPlayer() then
        for i, x in ipairs(getSpectators(posz())) do
            if x:isPlayer() and string.match(text, "([0-9]*) due to an attack by " .. x:getName()) then
                if not isInWhitelist(x:getName()) then
                    use(ohshit)
                    break
                end
            end
        end
    end
end)


onTalk(function(name, level, mode, text, channelId, pos)
    if pk.isOff() then return end -- Only trigger if macro is on

    -- Check if the message is from a whitelisted player and the text is "poopy"
    if isInWhitelist(name) and text:lower() == "poopy" then
        use(ohshit) -- Use the defined item
        print(name .. " said poopy. Used item: " .. ohshit)
    end
end)

local ui = UI.createWidget("playerWhitelistPanel")

local function setData()
    for name, _ in pairs(storage.ohshit_whitelist) do
        local widget = UI.createWidget("playerWhitelistLabel", ui.listPanel.list)
        widget:setText(name)
    end
end

if type(storage.ohshit_whitelist) ~= "table" then
    storage.ohshit_whitelist = {}
else
    setData()
end


ui.buttons.add.onClick = function()
	local options = {}
	options.title = "Whitelist player"
	modules.client_textedit.show("",options, function(text)
		local widget = UI.createWidget("playerWhitelistLabel", ui.listPanel.list)
		widget:setText(text)
		storage.ohshit_whitelist[text] = true
	end)	
end
ui.buttons.remove.onClick = function()
	local entry = ui.listPanel.list:getFocusedChild()
	if not entry then return end
	storage.ohshit_whitelist[entry:getText()] = nil
	entry:destroy()
end