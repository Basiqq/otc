setDefaultTab("Cave")
UI.Separator()
local modalClick = macro(2000, "Auto click WP", function() end)

onModalDialog(function(id, title, message, buttons, enterButton, escapeButton, choices, priority)
	if modalClick:isOff() then return end

	local goDialog = 0

	if title == "Waypoints" then
		for i = 1, #choices do
            local choiceId = choices[i][1]
            local choiceName = choices[i][2]

            if choiceName == storage.autoWaypointText then
                goDialog = choiceId
            end
        end
	end

	if goDialog > 0 then
		g_game.answerModalDialog(id, enterButton, goDialog)
		modules.game_modaldialog:destroyDialog()
	end
end)

UI.TextEdit(storage.autoWaypointText or "Squirrel Spawn", function(widget, text)    
  storage.autoWaypointText = text
end)

UI.Separator()