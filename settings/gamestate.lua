require 'wfx_def'

GAME_STATE_UNKNOWN = 0
GAME_STATE_PLAYING       = 1
GAME_STATE_GAME_ROOM     = 2
GAME_STATE_MATCH_LOADING = 3

local GameState = GAME_STATE_UNKNOWN

local debugging_mode = true

if debugging_mode then  
  --WFXPrint(" >> warbot warning: warbot_gamestate running in debugging mode\n") 
end

function getGameState()
  if debugging_mode then
    return GAME_STATE_PLAYING
  end
  return GameState
end

local flag_start_game = false

function gamestate_cmdfilter(cmd)
  --WFXPrint(string.format("%s", cmd))
  
  if string.find(cmd, "start_game") then
    flag_start_game = true
	if GameState == GAME_STATE_GAME_ROOM then
	  GameState = GAME_STATE_MATCH_LOADING
	end
	return
  end
  
  if string.find(cmd, "loading_complete") then
    if flag_start_game then
	  GameState = GAME_STATE_PLAYING
	  flag_start_game = false
	else
	  GameState = GAME_STATE_UNKNOWN	  
	end
	return
  end
  
  if string.find(cmd, "gameroom_ready_status_changed") then
    GameState = GAME_STATE_GAME_ROOM
	return
  end
end

function getGameStateStr()
  if GameState == GAME_STATE_UNKNOWN then    
    return "GAME_STATE_UNKNOWN"
  end  
  
  if GameState == GAME_STATE_PLAYING then    
    return "GAME_STATE_PLAYING"
  end    
  
  if GameState == GAME_STATE_GAME_ROOM then
    return "GAME_STATE_GAME_ROOM"
  end
  
  if GameState == GAME_STATE_MATCH_LOADING then
    return "GAME_STATE_MATCH_LOADING"
  end
  
  return "INVALID"
end
  
WFXRegisterEvent(WFX_EVENTID_EXECUTE_GAMECOMMAND, "gamestate_cmdfilter")