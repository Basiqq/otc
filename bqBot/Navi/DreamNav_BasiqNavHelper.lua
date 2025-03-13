schedule(200, function()
  setDefaultTab("Nav")
  addSeparator("separator")
  addLabel("", "bqq")
  addLabel("", "Nav Helper:")
  addSeparator("separator")

  -- party reset button
  BotServer.listen("PartyReset", function(sender, data)
    g_game.partyLeave()
  end)

  local resetBtn = UI.Button("Reset Party", function()
    BotServer.send("PartyReset", true)
  end)

  -- fist button
  BotServer.listen("PVP", function(sender, data)
    g_game.setSafeFight(data)
  end)

  local b = false
  local pvpBtn = UI.Button("PVP Fist", function()
    BotServer.send("PVP", b)
    b = not b
    pvpBtn:setColor(b and "red" or "white")
  end)

  pvpBtn:setColor("white")

  -- Pickup items button
  BotServer.listen("PickupItems", function(sender)
    local tile = g_map.getTile(pos())
    if tile then
      for _, item in ipairs(tile:getItems()) do
        g_game.move(item, {x = 65535, y = SlotBackpack, z = 0}, item:getCount())
      end
    end
  end)

  local pickupBtn = UI.Button("Pickup Items", function()
    BotServer.send("PickupItems", true)
  end)
  
  addSeparator("separator")
  function toggleMacro(name, isOn)  
    for key, m in ipairs(_macros) do
      if m.name:lower() == name:lower() then
        m.setOn(isOn)  
        return true
      end
    end
  end
  
  BotServer.listen("ToggleMacro", function(sender, data)
    toggleMacro(data.name, data.isOn)
  end)
  
  local doorScript = false
  local doorButton
  
  doorButton = UI.Button("Toggle Doors", function()
    doorScript = not doorScript
    BotServer.send("ToggleMacro", {name="doors", isOn=doorScript})
  
    -- Change button text color
    if doorScript then
      doorButton:setColor("green")
    else
      doorButton:setColor("red")
    end
  end)
  
  -- Set initial color
  doorButton:setColor("red")
  addSeparator("separator")

  local amuletCounts = {}
  local connectedPlayers = {}

  -- amulet from best to worst
  local amuletTiers = {37299, 37308, 37317, 37263, 37254, 37245, 37199, 37077, 37069, 37087, 
    37096, 37060, 16108, 12542, 9303, 22061, 22082, 16113, 3008, 9302, 9221, 
    3082, 817, 815, 814, 816, 3081, 3014, 3013, 3085, 3024}
  
  -- same as amulets
  local helmetTiers = {37292, 37301, 37310, 37256, 37247, 37238, 37192, 37071, 37061, 37080,
    37089, 37052, 16104, 13995, 19369, 20276, 3393, 16109, 8864, 3407, 3011,
    3574, 3390, 829, 830, 828, 3387, 3391, 3365, 3400, 3385}
  
  local function findBestAmulet()
    for _, id in ipairs(amuletTiers) do
      local item = findItem(id)
      if item then return item end
    end
    return nil
  end

  local function findBestHelmet()
    for _, id in ipairs(helmetTiers) do
      local item = findItem(id)
      if item then return item end
    end
    return nil
  end
  
  local function updateAmuletCount()
    local equippedAmulet = getNeck()
    local equippedCount = equippedAmulet and equippedAmulet:getCount() or 0
    local backpackCount = 0
    for _, id in ipairs(amuletTiers) do
      local item = findItem(id)
      if item then
        backpackCount = backpackCount + item:getCount()
      end
    end
    local totalCount = equippedCount + backpackCount
    BotServer.send("AmuletStatus", totalCount)
  end
  
  BotServer.listen("AmuletStatus", function(sender, data)
    amuletCounts[sender] = data
    local message = "Amulet Status:\n"
    for name, count in pairs(amuletCounts) do
      message = message .. name .. ": " .. count .. "\n"
    end
    modules.game_textmessage.displayGameMessage(message)
  end)

  BotServer.listen("equipAmulet", function(sender)
    local bestAmulet = findBestAmulet()
    if bestAmulet then
      g_game.equipItem(bestAmulet)
    end
    updateAmuletCount()
  end)

  BotServer.listen("unequipAmulet", function(sender)
    local amulet = getNeck()
    if amulet then
      g_game.move(amulet, {x = 65535, y = SlotBackpack, z = 0}, amulet:getCount())
    end
    updateAmuletCount()
  end)

  -- amulet buttons
  local amuletEquipBtn = UI.Button("Equip Amulet", function()
    BotServer.send("equipAmulet", true)
  end)
  amuletEquipBtn:setColor("green")

  local amuletUnequipBtn = UI.Button("Unequip Amulet", function()
    BotServer.send("unequipAmulet", true)
  end)
  amuletUnequipBtn:setColor("red")

  BotServer.listen("equipHelmet", function(sender)
    local bestHelmet = findBestHelmet()
    if bestHelmet then
      g_game.equipItem(bestHelmet)
    end
  end)

  BotServer.listen("unequipHelmet", function(sender)
    local helmet = getHead()
    if helmet then
      g_game.move(helmet, {x = 65535, y = SlotBackpack, z = 0}, helmet:getCount())
    end
  end)

  -- helmet buttons
  local helmetEquipBtn = UI.Button("Equip Helmet", function()
    BotServer.send("equipHelmet", true)
  end)
  helmetEquipBtn:setColor("green")

  local helmetUnequipBtn = UI.Button("Unequip Helmet", function()
    BotServer.send("unequipHelmet", true)
  end)
  helmetUnequipBtn:setColor("red")


end)