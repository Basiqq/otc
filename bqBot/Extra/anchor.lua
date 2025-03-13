setDefaultTab("Cave")
addSeparator("separator")
local anchorPos = nil

macro(500, "Anchor Position", function()
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

UI.Button("Set Anchor", function()
  local player = g_game.getLocalPlayer()
  if not player then return end

  local playerPos = player:getPosition()
  if not playerPos then return end

  anchorPos = playerPos
  modules.game_textmessage.displayGameMessage("Anchor set at: [" .. anchorPos.x .. ", " .. anchorPos.y .. ", " .. anchorPos.z .. "]")
end)

UI.Button("Remove Anchor", function()
  anchorPos = nil
  modules.game_textmessage.displayGameMessage("Anchor removed.")
end)





addSeparator("separator")
