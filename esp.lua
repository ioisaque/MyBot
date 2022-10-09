require 'settings\\gamemode'
require 'settings\\gamestate'
require 'settings\\ffa_help'
require 'settings\\colors'
require 'settings\\bones'
require 'settings\\vk'
require 'wfx_def'

--local declarations for settings
local font = WFXCreateFont(15,10,FW_NORMAL, true, "Arial")
local explosives = {}
local target_time = 0
--- local imgs
local WFX_MENU_IMG_EXPLOSIVE = WFXLoadImage(WFX_ADDONS_PATH .. 'menu\\imgs\\bomb.png')
---- ESP Settings ----
esp_enabled = true
auto_target = false
g_IsLineESP_1_Enabled = true
g_IsLineESP_2_Enabled = false
g_IsNameESP_Enabled = true
g_IsSkeletonESP_Enabled = true
g_IsCircleESP_Enabled = true
g_IsBoxESP_Enabled = false
g_IsDistanceESP_Enabled = true
g_IsExplosivesESP_Enabled = true
--- ESP Name Color ---
esp_name_color = LIME
--- ESP Distance Color ---
esp_distance_color = WHITE
--- ESP Line Colors ---
line_color_inFOV = LIME
line_color_outFOV = GREY
--- ESP Skeleton Colors ---
skeleton_color_inFOV = ICE
skeleton_color_outFOV = RED
--- ESP Explosives Color ---
esp_explosives_color = ARGB(255,153,193,0)
--- ESP Box Color ---
esp_box_color = YELLOW
--- ESP Circle Color ---
esp_circle_color = ICE
----- End Settings -----

local function validate_worldpos(pos)
  return (pos.x + pos.y + pos.z) > 0.0
end
	
local function boneLine(player, id_start, id_end, color)

  local start_pos = GetPlayerBonePosByID(player, id_start) 
  if not validate_worldpos(start_pos) then
    WFXPrint("ESP - Invalid world pos 1\n")
    return
  end
  
  local end_pos = GetPlayerBonePosByID(player, id_end)  
  if not validate_worldpos(end_pos) then  
    WFXPrint("ESP - Invalid world pos 2\n")
    return
  end
  
  start_pos = WorldToScreen(start_pos)
  end_pos   = WorldToScreen(end_pos)
  
  local screen = GetScreenResolution()
  
  if start_pos.x == 0.0 or start_pos.y == 0.0 then 
    --WFXPrint(string.format("STARTPOS - invalid screen position - 1 (%f %f)", start_pos.x, start_pos.y))
    return
  end
  
  if start_pos.x > screen.x or start_pos.y > screen.y then
    --WFXPrint(string.format("STARTPOS - invalid screen position - 2 (%f %f - %f %f)", start_pos.x, start_pos.y, screen.x, screen.y))
    return
  end
  
  if end_pos.x == 0.0 or end_pos.y == 0.0 then 
    --WFXPrint(string.format("ENDPOS - invalid screen position - 1 (%f %f)", end_pos.x, end_pos.y))
    return
  end
  
  if end_pos.x > screen.x or end_pos.y > screen.y then
    --WFXPrint(string.format("ENDPOS - invalid screen position - 2 (%f %f - %f %f)", end_pos.x, end_pos.y, screen.x, screen.y))
    return
  end
  
  FDrawLine(start_pos.x, start_pos.y, end_pos.x, end_pos.y, 2, color)
end
	
local function getDistanceSqr(p1,p2)
  return (p1.x - p2.x) ^ 2 + ((p1.y) - (p2.y)) ^ 2 + (p1.z - p2.z) ^ 2
end
 
function esp_name(player)
  local head = GetPlayerBonePosByID(player, THROAT)
  head.z = head.z + 0.5
  head.y = head.y + 0.2
  local screen = WorldToScreen(head)  
  if validate_worldpos(screen) and g_IsNameESP_Enabled then
    FDrawString(screen.x, screen.y, 1, 0, esp_name_color, string.format(GetPlayerName(player)))
  end
end

function esp_line(player)

  local bone = AimBone
  if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end

  local screen = GetScreenResolution()
  local PosE = GetPlayerBonePosByID(player, bone)

   if bone == 10 or bone == R_EYE then
    PosE.z = PosE.z + 0.1
  end 

  local EnemyPos = WorldToScreen(PosE)
  
  if g_IsLineESP_1_Enabled and CheckInSightFromActorView(PosE) then
	FDrawLine(screen.x/2, screen.y/2, EnemyPos.x, EnemyPos.y, 2, line_color_inFOV)
  elseif g_IsLineESP_2_Enabled and not CheckInSightFromActorView(PosE) then
	FDrawLine(screen.x/2, screen.y/2, EnemyPos.x, EnemyPos.y, 2, line_color_outFOV)
  else
	return
  end
end

function esp_skeleton(player)
local color = esp_skeleton_color
	if g_IsSkeletonESP_Enabled then
	  if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then 
		boneLine(player, 4,37, color)
		boneLine(player, 36,37,color)
		boneLine(player, 37,39,color)
		boneLine(player, 39,38,color)
		
		boneLine(player, 5,40, color)
		boneLine(player, 40,41,color)
		boneLine(player, 41,43,color)
		boneLine(player, 43,42,color)
		
		boneLine(player, 14,15,color)
		boneLine(player, 15,17,color)
		boneLine(player, 17,18,color)
		boneLine(player, 18,19,color)
		
		boneLine(player, 25,26,color)
		boneLine(player, 26,28,color)
		boneLine(player, 28,29,color)
		boneLine(player, 29,30,color)
		
		boneLine(player, 10,8,color)
		boneLine(player, 8,7,color)
		boneLine(player, 7,6,color)
		boneLine(player, 6,3,color)
		boneLine(player, 3,1,color)
		
		boneLine(player, 12,14,color)
		boneLine(player, 13,25,color)
		boneLine(player, 1,4,color)
		boneLine(player, 1,5,color)
	  else
		boneLine(player, 77,78, color)
		boneLine(player, 71,72, color)
		boneLine(player, 70,71, color)
		boneLine(player, 01,04, color)
		boneLine(player, 04,70, color)
		boneLine(player, 01,05, color)
		boneLine(player, 05,77, color)
		boneLine(player, 01,13, color)
		boneLine(player, 13,24, color)
		boneLine(player, 13,47, color)
		boneLine(player, 47,50, color)
		boneLine(player, 24,27, color)
		boneLine(player, 27,28, color)
		boneLine(player, 50,51, color)
	  end
	end
end

function MarkPlayer(player)

  local bone = AimBone
  if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end
  
  local pos = GetPlayerBonePosByID(player, bone)
  
  if (pos.x + pos.y + pos.z) == 0.0 then
    --WFXPrint(string.format("1 - invalid screen post in aim (MarkPlayer)\n"))
    return
  end
  
  if bone == 10 or bone == R_EYE then
    pos.z = pos.z + 0.1
  end
	
  pos = WorldToScreen(pos) 
    
  if pos.x == 0.0 or pos.y == 0.0 then
    --WFXPrint(string.format("2 - invalid screen post in aim (MarkPlayer)\n"))
    return
  end
  
  local screen = GetScreenResolution()
  
  if (pos.x > screen.x or pos.y > screen.y) then
    --WFXPrint(string.format("3 - invalid screen post in aim (MarkPlayer)\n"))
    return
  end
  
  if g_IsSkeletonESP_Enabled then
	FDrawCircle(pos.x, pos.y, 4, 8, aim_target_color)
  end
end

local function DrawBorder(x,y,w,h,px,color)
  FFillRGB(x, (y + h - px), w, px, color)
  FFillRGB(x, y, px, h, color)
  FFillRGB(x, y, w, px, color)
  FFillRGB((x + w - px), y, px, h, color)
end

function esp_box(player)
  if not g_IsBoxESP_Enabled then
    return
  end
  
  if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then  
    HEAD = 10
	L_FOOT = 38
	R_FOOT = 42
  else
    HEAD = 13
	L_FOOT = 71
	R_FOOT = 78
  end

  local head = WorldToScreen(GetPlayerBonePosByID(player, HEAD))
  if not validate_worldpos(head) then
    return
  end
  local lfoot = WorldToScreen(GetPlayerBonePosByID(player, L_FOOT))
  if not validate_worldpos(lfoot) then
    return
  end
  local rfoot = WorldToScreen(GetPlayerBonePosByID(player, R_FOOT))
  if not validate_worldpos(rfoot) then
    return
  end
  
  local x = rfoot.x
  
  if x > lfoot.x then 
    x = lfoot.x
  end	
  
  local y = rfoot.y
  
  if y < lfoot.y then
    y = rfoot.y
  end	
  
  DrawBorder(x, head.y, math.abs(lfoot.x-rfoot.x) ,  y - head.y , 1, esp_box_color)
end

function esp_circle(player)
  local CENTER = GetPlayerBonePosByID(player, PELVIS)
  local screen = WorldToScreen(CENTER) 
   if validate_worldpos(screen) and g_IsCircleESP_Enabled then
	FDrawCircle(screen.x, screen.y, 25, 50, esp_circle_color)
   end
end

function esp_distance(player)
    
	local clientActor = GetPlayerActor()
	if not clientActor then
	  return
	end
    
	local actorPos = GetPlayerPos(clientActor)
	if (actorPos.x + actorPos.y + actorPos.z) == 0.0 then
	  WFXPrint(string.format("warbot_esp >> Actor pos is invalid\n"))
	  return
	end
	
	local enemyPos = GetPlayerPos(player)
	if (enemyPos.x + enemyPos.y + enemyPos.z) == 0.0 then
	  WFXPrint(string.format("warbot_esp >> enemyPos pos is invalid\n"))
	  return
	end
		
	local distance = math.sqrt(getDistanceSqr(actorPos, enemyPos))
	
	local headPos = GetPlayerBonePosByID(player, THROAT)
	
	if (headPos.x + headPos.y + headPos.z) == 0.0 then
	  WFXPrint(string.format("warbot_esp >> headPos pos is invalid\n"))
	  return
	end
	
	headPos.z = headPos.z - 1.0
	headPos.y = headPos.y + 0.2
	
	local headPos = WorldToScreen(headPos)
	local screen = GetScreenResolution()
	
	if headPos.x == 0.0 or headPos.y == 0.0 then 
	  return
    end
	
	if headPos.x > screen.x or headPos.y > screen.y then
      return
    end
	
	if g_IsDistanceESP_Enabled then
	  LDrawString(headPos.x, headPos.y, 20, 20, esp_distance_color, string.format("Distancia: %1.0f m", distance))
	end
end

function enum_callback_esp(player)
  
  local actor = GetPlayerActor() 
   
  if player == actor then
	return
  end  
    
  if not IsPlayerAlive(player) then
	return
  end
  
  if GetPlayerTeam(actor) == GetPlayerTeam(player) then
    if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then
		return
	else 
	  if not is_free_for_all_mode() then
		return
	  end
	end
  end
  
  esp_skeleton_color = skeleton_color_outFOV

	local bone = AimBone
	
  if getGameMode() == GAME_MODE_PVE or IsCooperativeMode() then
    if bone == R_EYE then
	  bone = 10
	elseif bone == SPINE2 then
	  bone = 7
	end
  end

	local pos = GetPlayerBonePosByID(player, bone)

	if (0.0 == (pos.x + pos.y + pos.z)) then
	  WFXPrint("invalid bone position\n")
	  return
	end
	
	if bone == 10 or bone == R_EYE  then
	  pos.z = pos.z + 0.1
    end		
	
  if CheckInSightFromActorView(pos) then
	if auto_target and aim_enabled then
	  if (GetTickCount() - target_time) > 500 then
		LookAt(pos)
		target_time = GetTickCount()
	  end
	end
	esp_skeleton_color = skeleton_color_inFOV
  else
	esp_skeleton_color = skeleton_color_outFOV
  end
  
  esp_name(player)
  esp_skeleton(player)
  MarkPlayer(player)
  esp_distance(player)
  esp_circle(player)
  esp_box(player)
  esp_line(player)
end

local function drawExplosive(pos,dist)
  WFXDrawImage(WFX_MENU_IMG_EXPLOSIVE, D3DXVECTOR3(pos.x-40, pos.y, pos.z), 255)
  myDrawText(font, BLACK, pos.x+36, pos.y+31, 0, 0, string.format("%1.0fm",dist))
  myDrawText(font, esp_explosives_color, pos.x+35, pos.y+30, 0, 0, string.format("%1.0fm",dist))
end

function enum_callback_explosives(pos)
  if (pos.x + pos.y + pos.z) > 0.0 then
    local actorPlayer = GetPlayerActor()
	if actorPlayer ~= 0 then
	  actorPos = GetPlayerPos(actorPlayer)
	  if (actorPos.x + actorPos.y + actorPos.z) > 0.0 then
		local distance = math.sqrt(getDistanceSqr(actorPos, pos))
		if distance > 0.0 then
		  pos = WorldToScreen(pos)
		  local screen = GetScreenResolution()			  
		  if (pos.x > 0.0 and pos.y > 0.0) and (pos.x < screen.x and pos.y < screen.y) then
		    drawExplosive(pos,distance)
		  end
		end
	  end
	end
  end
end

local function explosives_esp()
  if g_IsExplosivesESP_Enabled then
	explosives = {}
	EnumExplosives("enum_callback_explosives")	
  end
end

function esp_draw()
  if esp_enabled and GetPlayerActor() then
    EnumPlayers("enum_callback_esp")
	explosives_esp()
  end
end

WFXRegisterEvent(WFX_EVENTID_DRAW, "esp_draw")