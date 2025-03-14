setDefaultTab("bq")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Navi/follow.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);
schedule(200, function()
  setDefaultTab("bq")
  -- UI text box for hotkey assignment
  UI.Label("Follow Hotkey:")
  UI.TextEdit(storage.followHotkey or "F12", function(widget, text)
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
  BotServer.send("ToggleMacro", {name="doors", isOn=doorScript})

  doorButton:setColor(doorScript and "green" or "red")
end)

doorButton:setColor("red")
addSeparator("separator")

-- Follow script toggle via icon with built-in hotkey
addIcon("followIcon", { 
  item = { id = 23686 }, 
  text = "Follow", 
  hotkey = storage.followHotkey or "F12"  -- Store hotkey for persistence
}, function(icon, isOn)
  followScript = isOn
  BotServer.send("ToggleMacro", {name="FLW", isOn=followScript})
  storage.followScript = followScript
end)


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
  addSeparator("separator")


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

setDefaultTab("Cave")
addSeparator("separator")
local anchorPos = nil

macro(500, "Hold Position", function()
  if not anchorPos then return end

  local player = g_game.getLocalPlayer()
  if not player then return end

  local playerPos = player:getPosition()
  if not playerPos then return end

  
  if playerPos.x ~= anchorPos.x or playerPos.y ~= anchorPos.y or playerPos.z ~= anchorPos.z then
    g_game.stop()
    schedule(200, function()
      local path = g_map.findPath(playerPos, anchorPos, 100, 0)
      if path and #path > 0 then
        for _, dir in ipairs(path) do
          g_game.walk(dir)
        end
      end
    end)
  end
end)

UI.Button("Set Position", function()
  local player = g_game.getLocalPlayer()
  if not player then return end

  local playerPos = player:getPosition()
  if not playerPos then return end

  anchorPos = playerPos
  modules.game_textmessage.displayGameMessage("Anchor set at: [" .. anchorPos.x .. ", " .. anchorPos.y .. ", " .. anchorPos.z .. "]")
end)

addSeparator("separator")

-- AUTO REVIDE / FIGHT BACK / ATTACK PLAYER PK
setDefaultTab("Tools")

-- ATTENTION:
-- Don't edit below this line unless you know what you're doing.

local ignoreEmblems = {1,4} -- Guild Emblems (Allies)

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 3
    text-align: center
    width: 130
    !text: tr('Fight Back (Revide)')
    font: verdana-11px-rounded

  Button
    id: edit
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded
]])

local edit = setupUI([[
RevideBox < CheckBox
  font: verdana-11px-rounded
  margin-top: 5
  margin-left: 5
  anchors.top: prev.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  color: lightGray

Panel
  height: 123

  RevideBox
    id: pauseTarget
    anchors.top: parent.top
    text: Pause TargetBot 
    !tooltip: tr('Pause TargetBot While fighting back.')

  RevideBox
    id: pauseCave
    text: Pause CaveBot 
    !tooltip: tr('Pause CaveBot While fighting back.')

  RevideBox
    id: ignoreParty
    text: Ignore Party Members

  RevideBox
    id: ignoreGuild
    text: Ignore Guild Members

  RevideBox
    id: attackAll
    text: Attack All Skulled
    !tooltip: tr("Attack every skulled player, even if he didn't attacked you.")

  BotTextEdit
    id: esc
    width: 83
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    text: Escape
    color: red
    font: verdana-11px-rounded

  Label
    text: Cancel Attack:
    font: verdana-11px-rounded
    anchors.left: parent.left
    margin-left: 5
    anchors.verticalCenter: esc.verticalCenter
]])
edit:hide()

local showEdit = false
ui.edit.onClick = function(widget)
  showEdit = not showEdit
  if showEdit then
    edit:show()
  else
    edit:hide()
  end
end
-- End Basic UI

-- Storage
local st = "RevideFight"
storage[st] = storage[st] or {
  enabled = false,
  pauseTarget = true,
  pauseCave = true,
  ignoreParty = false,
  ignoreGuild = false,
  attackAll = false,
  esc = "Escape",
}
local config = storage[st]

-- UI Functions
-- Main Button
ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

-- Checkboxes
do
  edit.pauseTarget:setChecked(config.pauseTarget)
  edit.pauseTarget.onClick = function(widget)
    config.pauseTarget = not config.pauseTarget
    widget:setChecked(config.pauseTarget)
    widget:setImageColor(config.pauseTarget and "green" or "red")
  end
  edit.pauseTarget:setImageColor(config.pauseTarget and "green" or "red")
  
  edit.pauseCave:setChecked(config.pauseCave)
  edit.pauseCave.onClick = function(widget)
    config.pauseCave = not config.pauseCave
    widget:setChecked(config.pauseCave)
    widget:setImageColor(config.pauseCave and "green" or "red")
  end
  edit.pauseCave:setImageColor(config.pauseCave and "green" or "red")

  edit.ignoreParty:setChecked(config.ignoreParty)
  edit.ignoreParty.onClick = function(widget)
    config.ignoreParty = not config.ignoreParty
    widget:setChecked(config.ignoreParty)
    widget:setImageColor(config.ignoreParty and "green" or "red")
  end
  edit.ignoreParty:setImageColor(config.ignoreParty and "green" or "red")

  edit.ignoreGuild:setChecked(config.ignoreGuild)
  edit.ignoreGuild.onClick = function(widget)
    config.ignoreGuild = not config.ignoreGuild
    widget:setChecked(config.ignoreGuild)
    widget:setImageColor(config.ignoreGuild and "green" or "red")
  end
  edit.ignoreGuild:setImageColor(config.ignoreGuild and "green" or "red")

  edit.attackAll:setChecked(config.attackAll)
  edit.attackAll.onClick = function(widget)
    config.attackAll = not config.attackAll
    widget:setChecked(config.attackAll)
    widget:setImageColor(config.attackAll and "green" or "red")
  end
  edit.attackAll:setImageColor(config.attackAll and "green" or "red")
end

-- TextEdit
edit.esc:setText(config.esc)
edit.esc.onTextChange = function(widget, text)
  config.esc = text
end
edit.esc:setTooltip("Hotkey to cancel attack.")

-- End of setup.

local target = nil
local c = config

-- Main Loop
macro(250, function()
  if not c.enabled then return end
  if not target then
    if c.pausedTarget then
      c.pausedTarget = false
      TargetBot.setOn()
    end
    if c.pausedCave then
      c.pausedCave = false
      CaveBot.setOn()
    end
    -- Search for attackers
    local creatures = getSpectators(false)
    for s, spec in ipairs(creatures) do
      if spec ~= player and spec:isPlayer() then
        if (c.attackAll and spec:getSkull() > 2) or spec:isTimedSquareVisible() then
          if c.ignoreParty or spec:getShield() < 3 then
            if c.ignoreGuild or not table.find(ignoreEmblems, spec:getEmblem()) then
              target = spec:getName()
              break
            end
          end
        end
      end
    end
    return
  end

  local creature = getPlayerByName(target)
  if not creature then target = nil return end
  if c.pauseTargetBot then
    c.pausedTarget = true
    TargetBot.setOff()
  end
  if c.pauseTarget then
    c.pausedTarget = true
    TargetBot.setOff()
  end
  if c.pauseCave then
    c.pausedCave = true
    CaveBot.setOff()
  end

  if g_game.isAttacking() then
    if g_game.getAttackingCreature():getName() == target then
      return
    end
  end
  g_game.attack(creature)
end)

onKeyDown(function(keys)
  if not c.enabled then return end
  if keys == config.esc then
    target = nil
  end
end)

UI.Separator()



addSeparator("Separator")
--setDefaultTab("bq")
setDefaultTab("bq")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/bosstimers.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);