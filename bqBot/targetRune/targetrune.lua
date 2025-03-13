setDefaultTab("Target")
addSeparator("separator")

-- attack with spell
macro(50, "Attack Spell", function()
  if g_game.isAttacking() then
    say(storage.attackSpell)  -- cast if attacking
  end
end)

addTextEdit("", storage.attackSpell or "Attack Spell", function(widget, text)
  storage.attackSpell = text
end)

-- UI for Rune
local ui = UI.createWidget("TargetRunePanel")

-- default ID in case storage is empty
if type(storage.targetRuneItems) ~= "table" or not storage.targetRuneItems[1] then
  storage.targetRuneItems = {3185} -- default rune ID
end

local targetRuneItems = ui:recursiveGetChildById("targetRuneItems")
targetRuneItems:setItemId(storage.targetRuneItems[1])  -- set rune from storage as active
targetRuneItems.onItemChange = function()
  storage.targetRuneItems[1] = targetRuneItems:getItemId()  -- update rune ID in storage
end

-- using rune on target
macro(50, "Target Rune", function()
  local runeID = storage.targetRuneItems[1]  -- rune id from storage
  if g_game.isAttacking() then
    local target = g_game.getAttackingCreature()  -- getting current target
    if target then
      g_game.useInventoryItemWith(runeID, target)
      delay(300)  -- Use rune on target
    end
  end
end)

UI.Separator()