require 'settings\\gamestate'
require 'mybot\\mybot_mission'
require 'mybot\\mybot_funct'
require 'settings\\settings'
require 'mybot\\mybot_esp'
require 'settings\\colors'
require 'wfx_def'
---\\ Global Settings //---
p = 1
att = true
att_tick = false
MyBot_start = false
MyBot_enabled = false
--- Local Settings ---
local Tick = 0
local master = 0
local profile_id = 0
--- Virtual clients Settings ---
local protected_profiles = {}
local vClientMgr = WFXGetVClientMgr()
local settings_vc = CSettings(WFX_ADDONS_PATH.."mybot\\vclients.ini")
----\\ End Settings //----
--- Virtual clients exported functions ---
function addvClientsException(username, password)
	protected_profiles[#protected_profiles+1] = username
end
settings_vc:enumSections(addvClientsException)
function enumHandler(username, password)
	local cli = vClientMgr:create(username,password)
	cli:registerListener("vclient_vclientlistener")
	cli:init()
end
----\\ End exported functions //----

function canKick(n) 
	if #n < 14 then
		return false
	end

	for j = 1, #n do
		if (n[j].n == "nickname") then
			local nickname = n[j].val
			if GetPlayerName(GetPlayerActor()) == n[j].val then
				return false
			end
		end

		if (n[j].n == "online_id") then
			for k = 1, #protected_profiles do
				if string.find(n[j].val, protected_profiles[k]) then
					return false
				end
			end
		end
	end
	return true
end

function GetCharPos()
	local clientActor = GetPlayerActor()

	if clientActor ~= 0 then
		return GetPlayerPos(clientActor)
	end
end

function MyBot_points()
	MyBot_DefineMission()
	local dist = getDistance(GetCharPos(), point)
	
	if att == true then
		if (MyBot_start == true) and (dist < 1) then
	   --WFXPrint(string.format('     MyBot - Reached point %s\n', p))
	   p = p + 1
	end
end
end

function MyBot_functions()	
	MyBot_Esp(point)
	MyBot_lookAt()
	MyBot_walk()
	MyBot_run()
end

function MyBot_Draw()
 MyBot_StartGame()
  if getGameStateStr() == "GAME_STATE_PLAYING" then
	GetCharPos()
	MyBot_points()
	MyBot_functions()
  end
end

function MyBot_StartGame()
local CanExecuteStep1 = true
local CanExecuteStep2 = false
local CanExecuteStep3 = false

  if MyBot_enabled then
	if (((GetTickCount() - Tick) > 100) and CanExecuteStep1) then	
		PvESetRoomPrivateStatus(false)
		WFXPrint(">>>>>>> Room Open")
		CanExecuteStep1 = false
		CanExecuteStep2 = true
	end

	if (((GetTickCount() - Tick) > 2000) and CanExecuteStep2) then
		WFXPrint(">>>>>>> Connecting Virtual Clients...")
		settings_vc:enumSections(enumHandler)
		WFXPrint(">>>>>>> All Virtual Clients connected.")
		CanExecuteStep2 = false
		CanExecuteStep3 = true
	end

	if (((GetTickCount() - Tick) > 5000) and CanExecuteStep3) then
		PvESetRoomPrivateStatus(true) 
		WFXPrint(">>>>>>> Room Close")
		PvEStartClick()
		WFXPrint(">>>>>>> GAME START")
		MyBot_start = true
		CanExecuteStep3 = false
	end
  end
	if att_tick then Tick = GetTickCount() end
end

function MyBot_KickIntruders(t)
	if MyBot_enabled then
		for i = 1, #t do	
			if (t[i].n == "player") then
				local n = t[i].t
				if n then
					if canKick(n) then
						for j = 1, #n do
							if (n[j].n == "profile_id") then
								kickPlayer(tonumber(n[j].val))
								WFXPrint(string.format("player '%s' kicked", n[j].val))
							end
						end
					end
				end
			end
		end
	end
end

function MyBot_GameCommandFilter(cmdText)
 --WFXPrint(string.format("%s", cmdText))

  if cmdText == "start_game" then
	--
  end  
  
  if cmdText == "loading_complete" then
	ExecuteGameCommand("close_reward")
	RewardClosed = true
  end
end

WFXRegisterEvent(WFX_EVENTID_DRAW, "MyBot_Draw")
WFXRegisterEvent(WFX_EVENTID_RECV_DATA, "MyBot_KickIntruders")
WFXRegisterEvent(WFX_EVENTID_EXECUTE_GAMECOMMAND, "MyBot_GameCommandFilter")