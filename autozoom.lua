require 'wfx_def'
require 'aim'

autozoom_in_enabled      = false
autozoom_out_enabled     = false
autozoom_zoom_out_delay  = 2000 -- 2 segundo
autozoom_in_min_distance = 7.0  -- 12 metros

local hud_select = "hud_select1"
canZoomOut =  false
local zoomed    =  IsZoomed()
local autozoom_zoom_out_t = GetTickCount()
local autozoom_zoom_in_t  = GetTickCount()
user_zoomed = false

local function onZoomChangeState(state)
  --WFXPrint(string.format("zoom changed state to: %s", tostring(state)))  
  
  if state == true then
    autozoom_zoom_in_t  = GetTickCount()
  else  
    autozoom_zoom_out_t = GetTickCount()
  end
end

local function onHudSelect(hudId)
  if hud_select ~= hudId then
    hud_select = hudId
  end
end

local function zoomToggle()
  PlayAction("zoom", 1, 1.0)
  if IsZoomed() then
    canZoomOut = false
	user_zoomed = false
  end
end

function warbot_autozoom_draw()
  
  --WFXPrint(string.format("%s %s", tostring(autozoom_in_enabled), tostring(autozoom_out_enabled)))


  if zoomed ~= IsZoomed() then
    zoomed = IsZoomed()
	onZoomChangeState(zoomed)
  end    
  
  if user_zoomed then
    return
  end
  
  if autozoom_out_enabled then
    if IsZoomed() and canZoomOut then	  
	  if (GetTickCount() - autozoom_zoom_in_t) > autozoom_zoom_out_delay then
	    zoomToggle()
	  else
	    local t = (autozoom_zoom_out_delay - (GetTickCount() - autozoom_zoom_in_t))/1000
	    
	    FDraw2dLabel(
		  30, -- x
		  400, -- y
		  1.8, -- tamanho da fonte
		  ARGB(255,0,255,0), -- cor
		  string.format("Warbot: zoom out in: %1.1fs", t)
		)
	  end
	end
  end
end

function warbot_autozoom_onaction(actionId, actiovationMode, value)
  --WFXPrint(string.format("%s %d %f", actionId, actiovationMode, value))
  
  if string.find(actionId, "hud_select") ~= nil then
    onHudSelect(actionId)
	return
  end
  
  if actionId == "zoom" then
    user_zoomed = true
    return
  end
  
  if actionId == "attack1" then
    if actiovationMode == 1 then  
	   
	  -- verifica primeiro se está usando arma pesada ou pistola (leve)
	
	  if autozoom_in_enabled and ((GetCurrentActorWeaponType() == WEAPON_HEAVY) or (GetCurrentActorWeaponType() == WEAPON_SMALL)) then
	  	  	  
	    if not IsZoomed() then
		  
		  -- se o aimbot não estiver habilitado ele ativa o zoom mesmo quando não tiver um alvo na mira
		  if not aim_enabled then
		    zoomToggle()			
			return
		  end
		
		  -- se o aim estiver habilitado ele verifica se existe um alvo na mira e se este alvo pode ser mirado
		  if g_player then
		    if can_targetnext(g_player) then
			  local dist = math.sqrt(getDistSqr(GetPlayerPos(GetPlayerActor()), GetPlayerPos(g_player))) -- a função getDistSqr vem do script "warbot_aim.lua"
			  if dist > autozoom_in_min_distance then
				zoomToggle()
			  end
			end
		  end
		end
	  end
	else	  
	  -- verifica primeiro se está usando arma pesada ou pistola (leve)	  
	  if (GetCurrentActorWeaponType() == WEAPON_HEAVY) or (GetCurrentActorWeaponType() == WEAPON_SMALL) then
	    if IsZoomed() then
		  canZoomOut = true
		end
	  end
	end	
	return
  end	  
end

WFXRegisterEvent(WFX_EVENTID_ACTION, "warbot_autozoom_onaction")
WFXRegisterEvent(WFX_EVENTID_DRAW, "warbot_autozoom_draw")