setDefaultTab("bq")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Navi/legendaryfollow.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);
schedule(200, function()
  setDefaultTab("bq")
  -- UI text box for hotkey assignment
  UI.Label("Follow Hotkey:")
  UI.TextEdit(storage.followHotkey or "End", function(widget, text)
    storage.followHotkey = text -- Save hotkey setting
  end)


  addSeparator("separator")
  addLabel("", "bq")
  addLabel("", "Nav Helper:")
  addSeparator("separator")


  BotServer.listen("CaveOff", function(sender, data)
    CaveBot.setOff()
  end)

  local caveOffBtn = UI.Button("Cavebot Off", function()
    BotServer.send("CaveOff", true)
  end)
  caveOffBtn:setColor("red")

  BotServer.listen("TargetOff", function(sender, data)
    TargetBot.setOff()
  end)

  local targetOffBtn = UI.Button("Target Off", function()
    BotServer.send("TargetOff", true)
  end)
  targetOffBtn:setColor("red")


  BotServer.listen("CaveOn", function(sender, data)
    CaveBot.setOn()
  end)

  local caveOnBtn = UI.Button("Cavebot On", function()
    BotServer.send("CaveOn", true)
  end)
  caveOnBtn:setColor("green")

  BotServer.listen("TargetOn", function(sender, data)
    TargetBot.setOn()
  end)

  local targetOnBtn = UI.Button("Target On", function()
    BotServer.send("TargetOn", true)
  end)
  targetOnBtn:setColor("green")


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

doorButton = UI.Button("Doors", function()
  doorScript = not doorScript
  BotServer.send("ToggleMacro", {name="Doors", isOn=doorScript})

  doorButton:setColor(doorScript and "green" or "red")
end)

doorButton:setColor("red")

setDefaultTab("bq")
addIcon("followIcon", { 
  item = { id = 23686 }, 
  text = "Follow", 
  hotkey = storage.followHotkey or "End"
}, function(icon, isOn)
  storage.flwScript = isOn
  BotServer.send("ToggleMacro", {name="FLW", isOn=flwScript})
end)
end)
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Navi/amulethelmet.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/bosstimers.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/dungeon.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/anchor.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/retaliate.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

setDefaultTab("Tools")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/exiva.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------