setDefaultTab("Tools")
UI.Separator()
Panels.AttackLeaderTarget()

local target
local targetList = {}  


local function isInTargetList(playerName)
    for name, _ in pairs(storage.player_targetlist) do
        if name == playerName then
            return true
        end
    end
    return false
end


local function addTarget(playerName)
    table.insert(targetList, playerName)
end


local function removeTarget(playerName)
    for i, name in ipairs(targetList) do
        if name == playerName then
            table.remove(targetList, i)
            break
        end
    end
end


local attackMacro = macro(1, "PvP Targets", function()
    for _, spec in ipairs(getSpectators()) do
        if spec:isPlayer() then
            if spec:getName() ~= name() then
                if isInTargetList(spec:getName()) then
                    repeat
                        if not g_game.isAttacking() then
                            g_game.attack(spec)
                        end
                        delay(1)
                    until g_game.isAttacking() or not isInTargetList(spec:getName())
                    if g_game.isAttacking() then
                        target = spec
                        return
                    end
                end
            end
        end
    end
end)






onCreatureDisappear(function(creature)
    if not target then return end
    if attackMacro.isOff() then return end
    if creature:getName() ~= target:getName() then return end
  
    target = nil
end)



local ui = UI.createWidget("targetListPanel")

local function setData()
    for name, _ in pairs(storage.player_targetlist) do
        local widget = UI.createWidget("targetListLabel", ui.listPanel.list)
        widget:setText(name)
    end
end


if type(storage.player_targetlist) ~= "table" then
    storage.player_targetlist = {}
else
    setData()
end


ui.buttons.add.onClick = function()
	local options = {}
	options.title = "Add Target"
	modules.client_textedit.show("", options, function(text)
		local widget = UI.createWidget("targetListLabel", ui.listPanel.list)
		widget:setText(text)
		storage.player_targetlist[text] = true
	end)	
end


ui.buttons.remove.onClick = function()
	local entry = ui.listPanel.list:getFocusedChild()
	if not entry then return end
	storage.player_targetlist[entry:getText()] = nil
	entry:destroy()
end


modules.game_interface.gameRootPanel.onMouseRelease = function(widget, mousePos, mouseButton)
    if mouseButton == 2 then
        local child = rootWidget:recursiveGetChildByPos(mousePos)
        if child == widget then
            local menu = g_ui.createWidget('PopupMenu')
            menu:setId("blzMenu")
            menu:setGameMenu(true)
            --menu:addOption('AttackBot', AttackBot.show, "OTCv8")
            --menu:addOption('HealBot', HealBot.show, "OTCv8")
            --menu:addOption('Conditions', Conditions.show, "OTCv8")
            menu:addOption('PvP Targets', function() 
                if attackMacro.isOn() then 
                    attackMacro.setOff() 
                else 
                    attackMacro.setOn() 
                end 
            end, attackMacro.isOn() and "ON " or "OFF ")
            menu:addSeparator()
            menu:addOption('CaveBot', function() 
                if CaveBot.isOn() then 
                    CaveBot.setOff() 
                else 
                    CaveBot.setOn() 
                end 
            end, CaveBot.isOn() and "ON " or "OFF ")
            menu:addOption('TargetBot', function() 
                if TargetBot.isOn() then 
                    TargetBot.setOff() 
                else 
                    TargetBot.setOn() 
                end 
            end, TargetBot.isOn() and "ON " or "OFF ")
            menu:display(mousePos)
            return true
        end
    end
end
addSeparator("separator")