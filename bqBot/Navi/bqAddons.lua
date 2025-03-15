setDefaultTab("bq")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Navi/followOld.lua'
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
  BotServer.send("ToggleMacro", {name="doors", isOn=doorScript})

  doorButton:setColor(doorScript and "green" or "red")
end)

doorButton:setColor("red")

setDefaultTab("bq")
addIcon("followIcon", { 
  item = { id = 23686 }, 
  text = "Follow", 
  hotkey = storage.followHotkey or "End"
}, function(icon, isOn)
  followScript = isOn
  BotServer.send("ToggleMacro", {name="FLW", isOn=followScript})
  storage.followScript = followScript
end)
end)

addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Navi/amulethelmet.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);
addSeparator("separator")
local link = 'https://raw.githubusercontent.com/Basiqq/otc/refs/heads/main/bqBot/Extra/bosstimers.lua'
modules.corelib.HTTP.get(link, function(script) assert(loadstring(script))() end);

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
