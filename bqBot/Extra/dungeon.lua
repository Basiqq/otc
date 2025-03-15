
setDefaultTab("Cave")
-- Load UI
local Dungeons = setupUI([[
Panel
  id: dungeonPanel
  parent: GameBotPanel
  size: 380 150

  MainWindow
    id: mainWindow
    !text: tr('Dungeons')
    size: 175 150
    anchors.centerIn: parent

    Label
      id: dungeonLabel
      text: "Dungeon:"
      anchors.top: parent.top    
      anchors.horizontalCenter: parent.horizontalCenter
      margin-top: 5

    ComboBox
      id: dungeonDropdown
      anchors.top: dungeonLabel.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      margin-top: 2
      width: 160
      height: 22

    Label
      id: difficultyLabel
      text: "Difficulty:"
      anchors.top: dungeonDropdown.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      margin-top: 5

    ComboBox
      id: difficultyDropdown
      anchors.top: difficultyLabel.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      margin-top: 2
      width: 160
      height: 22

    Button
      id: startButton
      text: "Start"
      anchors.top: difficultyDropdown.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      margin-top: 8
      width: 120
      height: 25

]])

UI.Separator()

-- Ensure UI Loaded Correctly
if not Dungeons then return end

-- Get mainWindow first
local mainWindow = Dungeons:getChildById('mainWindow')
if not mainWindow then return end

-- Now fetch elements from mainWindow
local dungeonDropdown = mainWindow:getChildById('dungeonDropdown')
local difficultyDropdown = mainWindow:getChildById('difficultyDropdown')
local startButton = mainWindow:getChildById('startButton')

-- Ensure all UI elements exist
if not dungeonDropdown or not difficultyDropdown or not startButton then return end

-- Dungeon Mapping Table
local dungeonMap = {
  ["Insects"] = 1,
  ["Magical Forest"] = 2,
  ["Ice Age"] = 3,
  ["Demonic"] = 4,
  ["Aquatic"] = 5,
  ["Dark Void"] = 6
}

-- Dungeon List
local dungeonList = {"Insects", "Magical Forest", "Ice Age", "Demonic", "Aquatic", "Dark Void"}
for _, dungeon in ipairs(dungeonList) do
  dungeonDropdown:addOption(dungeon)
end

-- Difficulty List
local difficultyList = {"1", "2", "3", "4", "5", "6"}
for _, difficulty in ipairs(difficultyList) do
  difficultyDropdown:addOption(difficulty)
end

-- Default Selections
local selectedDungeon = dungeonList[1]
local selectedDifficulty = difficultyList[1]

-- Update Selection on Change
dungeonDropdown.onOptionChange = function(widget, text, index)
  selectedDungeon = text
end

difficultyDropdown.onOptionChange = function(widget, text, index)
  selectedDifficulty = text
end

-- Send JSON via Extended Opcode 109 on Button Click
startButton.onClick = function()
  local dungeonID = dungeonMap[selectedDungeon] or 1
  local difficultyLevel = tonumber(selectedDifficulty) or 1

  local jsonData = [[{"action":"queue","data":{"difficulty":]] .. difficultyLevel .. [[,"id":]] .. dungeonID .. [[}}]]
  
  g_game.getProtocolGame():sendExtendedOpcode(109, jsonData)
end