setDefaultTab("HP")

addSeparator("separator")
macro(50, "Fast Healer",  function()
  if (hppercent() <= tonumber(storage.belowhp)) then
    say(storage.healspell) 
  end
end)

addLabel("", "Healing Spell:")

addTextEdit("", storage.healspell or "Healing Spell", function(widget, text)
  storage.healspell = text
end)

addLabel("", "Heal at %:")

addTextEdit("", storage.belowhp or "99", function(widget, text)
  storage.belowhp = text
end)

addSeparator("separator2")

local ui = UI.createWidget("ManaItemPanel")

-- setting default id incase storage is empty
if type(storage.manaItems) ~= "table" or not storage.manaItems[1] then
  storage.manaItems = {3157} -- default id
end

local manaItems = ui:recursiveGetChildById("manaItems")
manaItems:setItemId(storage.manaItems[1])  -- get id from storage and set as active
manaItems.onItemChange = function()
  storage.manaItems[1] = manaItems:getItemId() -- update item in storage
end

local macroName = "Fast Mana"

addLabel("", "Mana at %:")

addTextEdit("", storage.belowmana or "95", function(widget, text)
  storage.belowmana = text
end)

macro(1000, macroName, function()
  local itemID = storage.manaItems[1] -- get id from storage again incase it changed lmao
  if (manapercent() <= tonumber(storage.belowmana)) then
    g_game.useInventoryItemWith(itemID, player)
    --delay(500) -- delay if u dont want to spam
  end
end)






UI.Separator()