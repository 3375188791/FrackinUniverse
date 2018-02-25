require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
  setPortraits()
  setStage(1)
end

function questStart()

end

function questComplete()
  player.radioMessage("vinjComplete2", 1)
  player.setIntroComplete(true)
  questutil.questCompleteActions()
end

function update(dt)
  updateStage(dt)
end

function uninit()

end

function setStage(newStage)
  if newStage ~= self.missionStage then
    if newStage == 1 then    -- has a Matter Assembler
	  player.radioMessage("fu_start_greetings0", 1)
	  player.radioMessage("fu_start_greetings1", 1)
	  player.radioMessage("fu_start_greetings2", 1)    
          quest.setObjectiveList({{config.getParameter("descriptions.makeTable"), false}})
    elseif newStage == 2 then  -- has Wires
       player.radioMessage("fu_start_makeTable", 1)
      quest.setObjectiveList({{config.getParameter("descriptions.makeWire"), false}})
    elseif newStage == 3 then
      player.radioMessage("fu_start_makeWire", 1)
    elseif newStage == 4 then
      player.radioMessage("fu_start_makeElectromagnet", 1)
      player.radioMessage("fu_start_Complete", 1)  
      player.radioMessage("fu_start_Complete2", 1)  
    end
    self.missionStage = newStage
  end
end

function updateStage(dt)
  if self.missionStage == 1 then
    if hasAssembler() then
      setStage(2)
    end
  elseif self.missionStage == 2 then
    if hasWire() then
      player.giveItem("glass")
      player.giveItem("glass")      
      setStage(3)
    end
  elseif self.missionStage == 3 then
    if hasElectromagnet() then
      player.giveItem("statustablet")
      setStage(4)
    end
  elseif self.missionStage == 4 then
     player.enableMission("scienceoutpost")
     quest.complete()     
  end
end

function hasAssembler()
  return player.hasItem("prototyper")
end

function hasElectromagnet()
  return player.hasItem("electromagnet")
end

function hasWire()
  pparams = { amount = 9 }
  return player.hasItem("wire",pparams)
end

