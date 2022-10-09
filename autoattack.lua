require 'wfx_def'
require 'aim'

autoattack_enabled  = false

local autoattack_wait_interval =  500
local autoattack_interval      = 1500
local old_t  = GetTickCount()
local old_bullet_interval_t = old_t
local old_user_cancel_t = old_t

local user_cancel = false
local attacking = false
local user_attacking = false
local timeout = false
local timeout_player = nil
local hud_select = "hud_select1"

local function attack_stop()
  if attacking then
    PlayAction("attack1", 2, 0.0)
	warbot_autozoom_onaction("attack1", 2, 0.0)
    attacking = false	 
	--WFXPrint("attack_stop()")
  end  
end

local function onWeaponChange()
  timeout = false
  old_t = GetTickCount()
  --WFXPrint(string.format("weapon changed (%s), timeout system reseted", hud_select))
end

local function onHudSelect(hudId)
  if hud_select ~= hudId then
    hud_select = hudId
	onWeaponChange()
  end
end

local function attack(bullet_interval)
   
   if user_cancel then
    if (GetTickCount() - old_user_cancel_t) > 2000 then	  
	  WFXPrint("user cancel timeout")
	  user_cancel = false
	else
	  return
	end
   end

  if timeout then
    
	if timeout_player ~= g_player then
	  old_t = GetTickCount()
	  timeout = false
	  --WFXPrint("time out player different than target player")
	  return
	end
    
	if (GetTickCount() - old_t) > autoattack_wait_interval then
	  --WFXPrint("attack timing reseted")
	  old_t = GetTickCount()
	  timeout = false
	  return
	end
	--WFXPrint(string.format("attack request failed cause the last attack has timed out (%d)", GetTickCount() - old_t))	
	return
  end

  if not attacking then
    --WFXPrint(string.format("auto attack interval: %d", bullet_interval))
    warbot_autozoom_onaction("attack1", 1, 1.0)
    PlayAction("attack1", 1, 1.0)
    canZoomOut = true
	--WFXPrint("attack start request")
	attacking = true
	old_t = GetTickCount()
	if bullet_interval > 0 then
      PlayAction("attack1", 2, 0.0)
	  old_bullet_interval_t = old_t
	end
	return
  end

  if (GetTickCount() - old_t) > autoattack_interval then    
	attack_stop()
	old_t = GetTickCount()
	timeout = true
	timeout_player = g_player
	--WFXPrint("attack timeout")
  else
    --WFXPrint(string.format("attacking (%d)...", GetTickCount() - old_t))
	
	if bullet_interval > 0 then
	
	  if (GetTickCount() - old_bullet_interval_t) > bullet_interval then
	    PlayAction("attack1", 1, 1.0)
		PlayAction("attack1", 2, 0.0)
		old_bullet_interval_t = GetTickCount()
	  end
	end	
  end
end

function warbot_autoattack_draw()

  if not autoattack_enabled then
    return
  end

  local t = (2000 - (GetTickCount() - old_user_cancel_t))/1000
  
  if user_cancel and t > 0 then  
    FDraw2dLabel(
      30, -- x
  	  420, -- y
	  1.8, -- tamanho da fonte
	  ARGB(255,0,255,0), -- cor
	  string.format("Warbot: auto ataque cancelado por: %1.1fs", t)
    )
  end
  
  if user_attacking then    
    return
  end
  
  -- cancela o auto ataque se usando faca,bomba etc...
  
  if (GetCurrentActorWeaponType() > WEAPON_MEDIUM) then
    --WFXPrint(string.format("%s %d", tostring(WEAPON_SMALL), GetCurrentActorWeaponType()))
	return
  end

  if g_player == nil then
    attack_stop()
    return
  end

  if not can_targetnext(g_player) then
    attack_stop()
    return
  end

  if not IsPlayerAlive(GetPlayerActor()) then
    attack_stop()
    return
  end
  
  local bone = AimBone
  
  if IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	end
  end
  
  local pos = GetPlayerBonePosByID(g_player, bone)
  
  if bone == 10 then
	pos.z = pos.z + 0.1 
  end
 
  if CheckInSightFromActorView(pos) then
    if aim_mode == 1 then
	  if attacking then
	    aim_player(g_player)
	  end
	end
	
	if GetCurrentActorWeaponType() == WEAPON_MEDIUM then
	  attack(100)
	  return
	else
	  --WFXPrint(string.format("%s %d", tostring(WEAPON_SMALL), GetCurrentActorWeaponType()))
	end
	
	--local dist = math.sqrt(getDistSqr(GetPlayerPos(GetPlayerActor()), GetPlayerPos(g_player))) -- a função getDistSqr vem do script "warbot_aim.lua"
	--if dist < 12 then
	  attack(0)
	--[[elseif dist < 20 then
	  attack(100)
	elseif dist > 25 then
	  attack(180)
	end
	--]]
  else
    attack_stop()
  end
end

function warbot_autoattack_onaction(actionId, actiovationMode, value)
  
  --WFXPrint(string.format("%s %d %f", actionId, actiovationMode, value))
  
  if string.find(actionId, "hud_select") ~= nil then
    onHudSelect(actionId)
	return
  end
  
  if actionId == "zoom" and IsZoomed() then
    if attacking then
	  old_user_cancel_t = GetTickCount()
	  user_cancel = true
	  attacking = false	  
	end	
	return
  end

  if actionId == "attack1" then
    
	old_user_cancel_t = GetTickCount()
  
    if attacking then	  
	  user_cancel = true
	  attacking = false	  
	end
  
    --[[
    if actiovationMode == 1 then
	  attacking = true
	  user_attacking = true	  
	  --WFXPrint("attacking flag set")
	else
	  attacking = false
	  user_attacking = false
	  --WFXPrint("attacking flag unset")
	end
	--]]
	
	return
  end
end

WFXRegisterEvent(WFX_EVENTID_ACTION, "warbot_autoattack_onaction")
WFXRegisterEvent(WFX_EVENTID_DRAW, "warbot_autoattack_draw")