setDefaultTab("HP")

addSeparator("separator")
macro(500, "Buff", nil, function()
    if not hasPartyBuff() and storage.autoBuffText:len() > 0 then
        if saySpell(storage.autoBuffText) then
            delay(5000)
        end
    end
end)

addTextEdit("autoBuffText", storage.autoBuffText or "SpellName", function(widget, newtext)
    storage.autoBuffText = newtext
end)
addSeparator("separator")