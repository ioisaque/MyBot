require 'settings\\colors'
require 'settings\\bones'
require 'wfx_def'
require 'esp'

--public settings
aim_enabled  = true
aim_interval = 500
aim_radius   = 0 -- 0 = off
AimBone = R_EYE
only_insight = true
aim_mode = 1 -- reserved feature
aim_can_show_radius = true
aim_melee_radius = 2.0
aim_can_show_melee_radius = true
automations_enabled = false
aim_melee_radius_color = ARGB(50,255,255,0)
aim_target_color = ARGB(255,255,255,102)
aim_radius_color = ARGB(50,255,255,255)
--private settings
local aim_canfire = false
local aim_last_target = nil
local aim_last_target_time = 0
--renamed functions
local _print = WFXPrint
local _fmt   = string.format

--local declarations
local enum_callback_closest_player  = 0
local enum_callback_targets = {}

------------------ code begin -----------------

function enum_callback_find_target(player)  
  local clientActor = GetPlayerActor()

  if not clientActor or clientActor == player then
    return
  end  
  
  if not IsPlayerAlive(player) then
    return
  end
  
  if GetPlayerTeam(clientActor) == GetPlayerTeam(player) then
    if IsCooperativeMode() then
	  return
	else  
	  if GetPlayerTeam(clientActor) + GetPlayerTeam(player) > 0 then 
	    return
	  end
	end
  end
  
  local bone = AimBone
  
  if IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end
  
  local bonePos = GetPlayerBonePosByID(player, bone)   

  if (bonePos.x + bonePos.y + bonePos.z) == 0.0 then
    return
  end
  
  if bone == 10 or bone == R_EYE then
	bonePos.z = bonePos.z + 0.1
  end
  
  if not CheckInSightFromActorView(bonePos) then
    if only_insight then 
	  return
	end
  end
  
  enum_callback_targets[#enum_callback_targets+1] = player
end
 
local function GetDistanceFromCrosshair(pos)
  local out = WorldToScreen(pos)
  local screen = GetScreenResolution()
    
  if out.x == 0 or out.y == 0.0 then
    return
  end
  
  if (out.x > screen.x or out.y > screen.y) then
    return
  end
  
  screen.x = screen.x/2
  screen.y = screen.y/2
  
  out.x = out.x - screen.x
  out.y = out.y - screen.y	
  
  return math.sqrt(out.x*out.x+out.y*out.y)
end

local function find_closest_player_from_screen()
  
  enum_callback_targets = {}
    
  EnumPlayers("enum_callback_find_target")  
  
  local old_distance = 99999.0
  local current_distance = 0
  local target = nil    
  local bone = AimBone
  
  if IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end
  
  for i = 1, #enum_callback_targets do
    local player = enum_callback_targets[i]
	local bonePos = GetPlayerBonePosByID(player, bone)
	
	if (bonePos.x + bonePos.y + bonePos.z) == 0.0 then
	  goto continue
	end
	
	if bone == 10 or bone == R_EYE then
	  bonePos.z = bonePos.z + 0.1
	end
	
	local current_distance = GetDistanceFromCrosshair(bonePos)	
	
	local radius = aim_radius
	
	if radius == 0 then
	  radius = 99999.0
	end
	
	if GetCurrentActorWeaponType() == WEAPON_ID_3RD then
	  radius = 99999.0
	end
	
	if aim_mode == 3 then
	  return player
	end
	
	if current_distance == nil then
	  goto continue
	end
	
	if (current_distance < old_distance) and (current_distance < radius) then
      old_distance = current_distance
	  target = player
    end
	::continue::
  end
  if target ~= nil then
    --local screen = WorldToScreen(GetPlayerBonePosByID(target, AimBone))
    --FDrawString(screen.x, screen.y, 30, 10, WHITE, string.format("dist: %f", GetDistanceFromCrosshair(GetPlayerBonePosByID(target, AimBone))))
  end    
  
  enum_callback_targets = {}
  
  return target
end

function aim_player(player)
  if player ~= nil then
    local bone = AimBone
    
  if IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end

    local pos = GetPlayerBonePosByID(player, bone)
	if (pos.x + pos.y + pos.z) == 0.0 then
	  return
	end
	
	if bone == 10 or bone == R_EYE then
	  pos.z = pos.z + 0.1
	end

	LookAt(pos)  
	aim_last_target_time = GetTickCount()
	aim_last_target = player
  end
end

local function show_aim_radius()
  if aim_radius > 0 then
    local screen = GetScreenResolution()
	FDrawCircle(screen.x/2, screen.y/2, aim_radius, 50, aim_radius_color)
  end
end

local function show_aim_melee_radius(player)

  if not g_IsMeleeRadius_Enabled then
    return
  end

  local pos = GetPlayerPos(player)
  
  if (pos.x + pos.y + pos.z) == 0.0 then
    WFXPrint(string.format("invalid player pos in aim (show_aim_melee_radius)\n"))
    return
  end
    
  local range = aim_melee_radius
  local pi = 3.14159265
  local step = (pi * 2.0)/60

  local a = 0  
  local oldpos = D3DXVECTOR3(range * math.cos(a) + pos.x, range * math.sin(a) + pos.y, pos.z)
  local newpos = D3DXVECTOR3(0,0,0)
  
  repeat     
    newpos.x = range * math.cos(a) + pos.x
	newpos.y = range * math.sin(a) + pos.y
	newpos.z = pos.z
	
	local sp = WorldToScreen(newpos)
	local ep = WorldToScreen(oldpos)
	
	if (sp.x + sp.y + sp.z) >  0 then
	  if (ep.x + ep.y + ep.z) > 0 then
	    FDrawLine(sp.x, sp.y, ep.x, ep.y, 2, aim_melee_radius_color)
	  end
	end
		
	a = a + step
	
	oldpos.x = newpos.x
	oldpos.y = newpos.y
	oldpos.z = newpos.z
	
  until a >= pi*2.0
end

function can_targetnext(player) 
  
  if GetPlayerName(player):len() < 1 then
    WFXPrint("INVALID PLAYER NAME\n")
    return false
  end
  
  --WFXPrint("PLAYER NAME IS VALID\n")
  
  if aim_last_target ~= player then
    local t = GetTickCount() - aim_last_target_time;
    if t < aim_interval then
	  --_print(_fmt("new target: %s (%d ms).", GetPlayerName(player), t))
	  return false
	end
  end
  return true
end

function getDistSqr(p1,p2)
  return (p1.x - p2.x) ^ 2 + ((p1.y) - (p2.y)) ^ 2 + (p1.z - p2.z) ^ 2
end

function aim_draw()

  if not aim_enabled then
    return
  end
  
  local clientActor = GetPlayerActor()

  if clientActor == 0 then
    return
  end
      
  if not IsPlayerAlive(clientActor) then
    return
  end
  
  if GetCurrentActorWeaponType() == 3 then
    return
  end
     
  if aim_can_show_radius then  
    show_aim_radius()
  end
    
  local player = find_closest_player_from_screen()

  g_player = player

  if player == nil then
    return
  end
  
  if can_targetnext(player) then    
	show_aim_melee_radius(player)

	if aim_mode == 1 then
	  if GetCurrentActorWeaponType() == WEAPON_ID_3RD then	  
	    local actorPos = GetPlayerPos(clientActor)
	    if (actorPos.x + actorPos.y + actorPos.z) == 0.0 then
		  WFXPrint(string.format("1 - invalid pos in aim (aim_draw)\n"))
		  return
		end
		
		local enemyPos = GetPlayerPos(player)
		if (enemyPos.x + enemyPos.y + enemyPos.z) == 0.0 then
		  WFXPrint(string.format("2 - invalid pos in _aim (aim_draw)\n"))
		  return
	    end
	  	  
	    local dist = math.sqrt(getDistSqr(actorPos, enemyPos))
        if dist > aim_melee_radius then
	      return
	    end
	  end
    end
	
	if aim_canfire or PTA then
	  aim_player(player)
	end
	
  end
end

function projectile_direction()
  
  if not aim_enabled then
    return
  end

  if aim_mode == 1 then
    return
  end  
  
  if g_player == nil then
    return
  end

  if can_targetnext(g_player) then   
    local bone = AimBone
    
  if IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end
  
    local pos = GetPlayerBonePosByID(g_player, bone)
	
	if (pos.x + pos.y + pos.z) == 0.0 then
	  WFXPrint("Aim II invalid bone pos\n")
	  return
	end
	
	if bone == 10 or bone == R_EYE then
	  pos.z = pos.z + 0.1
	end
	  
    SetProjectileDir(pos)
  end
end

function aim_onaction(actionId, actiovationMode, value)
  
  if aim_mode ~= 1 then
	return
  end

  if actionId == "attack1" then
    if actiovationMode == 1 then
	  aim_canfire = true
	else
	  aim_canfire = false
	end
  end
end

function ChangeAimBone()
	if AimBone == R_EYE then
		AimBone = SPINE2
	else
		AimBone = R_EYE
	end
end

function aim_keys(Key)
 if not block then
 --muda aimbot pra corpo ou cabeca
  if Key == KEY_PGDN then
    ChangeAimBone()
  end 
 end
end

WFXRegisterEvent(WFX_EVENTID_KEYUP, "aim_keys")
WFXRegisterEvent(WFX_EVENTID_DRAW, "aim_draw")
WFXRegisterEvent(WFX_EVENTID_PROJECTILEDIR, "projectile_direction")
WFXRegisterEvent(WFX_EVENTID_ACTION, "aim_onaction")