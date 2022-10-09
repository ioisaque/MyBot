--private settings
local aim_ffa_check_delay = 500 -- in milliseconds
--private declarations
local is_ffa = false
local is_ffa_timecheck = 0

--[[
     --- exported functions ---
 
 1: is_free_for_all_mode()
 2: GetDistanceFromCrosshair

--]]

---- code begin ----
function enum_callback_ffa(player)
  if GetPlayerTeam(GetPlayerActor()) ~= GetPlayerTeam(player) then
    is_ffa = false
  end
end

function is_free_for_all_mode()
  if IsCooperativeMode() then
    return false
  end
  if (GetTickCount() - is_ffa_timecheck) > aim_ffa_check_delay then
    is_ffa = true
	EnumPlayers("enum_callback_ffa")
	is_ffa_timecheck = GetTickCount()
  end
  return is_ffa
end

function GetDistanceFromCrosshair(pos)
  local out = WorldToScreen(pos)
  if (out.x + out.y + out.z) > 0 then
    local screen = GetScreenResolution()
	screen.x = screen.x/2
	screen.y = screen.y/2
	out.x = out.x - screen.x
	out.y = out.y - screen.y	
	return math.sqrt(out.x*out.x+out.y*out.y)
  end
  return 99999.0
end