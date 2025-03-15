setDefaultTab("Tools")
local bossNames = {"Gorgons", "Harpies", "Echidna", "Chimera", "Talos", "Scylla", "Charredon", "Azureon"}
local storageKey = "BossTimers"
storage[storageKey] = storage[storageKey] or { enabled = false }
for _, boss in ipairs(bossNames) do
    storage[storageKey][boss] = storage[storageKey][boss] or false
end

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
    !text: tr('Boss Timers')
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
BossBox < CheckBox
  font: verdana-11px-rounded
  margin-top: 5
  margin-left: 5
  anchors.top: prev.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  color: lightGray

Panel
  height: 130

  BossBox
    id: gorgons
    anchors.top: parent.top
    text: Gorgons 

  BossBox
    id: harpies
    text: Harpies

  BossBox
    id: echidna
    text: Echidna

  BossBox
    id: chimera
    text: Chimera

  BossBox
    id: talos
    text: Talos

  BossBox
    id: scylla
    text: Scylla

  BossBox
    id: charredon
    text: Charredon

  BossBox
    id: azureon
    text: Azureon
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

ui.title:setOn(storage[storageKey].enabled)  
ui.title.onClick = function(widget)  
    storage[storageKey].enabled = not storage[storageKey].enabled  
    widget:setOn(storage[storageKey].enabled)  
end  

for _, boss in ipairs(bossNames) do  
    local checkbox = edit[boss:lower()]
    if checkbox then  
        checkbox:setChecked(storage[storageKey][boss])  
        checkbox.onClick = function(widget)  
            storage[storageKey][boss] = not storage[storageKey][boss]  
            widget:setChecked(storage[storageKey][boss])  
            widget:setImageColor(storage[storageKey][boss] and "green" or "red")
        end  
        checkbox:setImageColor(storage[storageKey][boss] and "green" or "red")
    end  
end 

macro(150000, function()  
    if storage[storageKey].enabled then  
        say("!bossestimers")  
    end  
end)  

onTextMessage(function(mode, text)  
    if storage[storageKey].enabled then  
        for _, boss in ipairs(bossNames) do  
            if storage[storageKey][boss] and text:match(boss .. ": Boss is accessible now") then  
                playSound("/sounds/alarm.ogg")  
            end  
        end  
    end  
end)
