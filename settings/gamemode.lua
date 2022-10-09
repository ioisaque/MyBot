require 'wfx_def'

GAME_MODE_UNDEFINED = 0
GAME_MODE_PVP       = 1
GAME_MODE_PVE       = 2

local isPvE = false
local isPvP = false

function getGameMode()
  if isPvE then
    return GAME_MODE_PVE
  elseif isPvP then
    return GAME_MODE_PVP
  end
  return GAME_MODE_UNDEFINED
end

function gamemode_cmdfilter(cmd)
  if string.find(cmd, "switch_browser_pvp") then
  	isPvP = true
    isPvE = false
    return
  end    
  
  if string.find(cmd, "switch_browser_pve") then
  	isPvE = true
    isPvP = false
    return
  end    

  if string.find(cmd, "landing_open_pvp") then
  	isPvP = true
    isPvE = false
    return
  end    
  
  if string.find(cmd, "landing_open_pve") then
  	isPvE = true
    isPvP = false
    return
  end      
end
  
WFXRegisterEvent(WFX_EVENTID_EXECUTE_GAMECOMMAND, "gamemode_cmdfilter") 