setDefaultTab("HP")
UI.Separator()
local ui = UI.createWidget("BuffPotPanel")

-- Set a default item ID if storage.buffPotions is not a table or is nil
if type(storage.buffPotions) ~= "table" or not storage.buffPotions[1] then
  storage.buffPotions = {36736} -- Default item ID, modify as needed
end

local buffPotions = ui:recursiveGetChildById("buffPotions")
buffPotions:setItemId(storage.buffPotions[1])  -- Set the item ID from the storage table
buffPotions.onItemChange = function()
  storage.buffPotions[1] = buffPotions:getItemId() -- Update the item ID in the storage table
end

local macroName = "Buff Potions"
local items = storage.buffPotions -- Use the item IDs from the storage table
local wait = 10 -- minutes
-- END CONFIG

macro(100, macroName, function()
  local time = 0
  for i = 1, #items do
    schedule(time, function()
      g_game.useInventoryItem(items[i])
    end)
    time = time + 250
  end
  delay(wait * 60 * 1000)
end)
UI.Separator()