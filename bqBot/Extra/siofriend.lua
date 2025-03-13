setDefaultTab("HP")
macro(100, "Sio", function()
  for _, creature in pairs(getSpectators(posz())) do
      if creature:isPlayer() and (creature:getHealthPercent() < 60) then
          if (creature:getEmblem() == player:getEmblem()) or creature:isPartyMember() then
              say("exura sio \"" .. creature:getName())
              
              return
          end
      end
  end
end)