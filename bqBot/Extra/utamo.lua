setDefaultTab("HP")
addSeparator("")
local exuraHp = 99 --- above this % hp will cast utamo vita again to turn it off
local safeMana = 20
macro(100, "Auto Utamo", function()
    if hppercent() <= storage.utamoHp and not hasManaShield() and manapercent() > safeMana then
        say("utamo vita")
    elseif hasManaShield() and (hppercent() >= exuraHp or manapercent() < safeMana) then
        say("utamo vita")
    end
end)

addTextEdit("", storage.utamoHp or "50", function(widget, text)
    storage.utamoHp = tonumber(text) or 50
end)
