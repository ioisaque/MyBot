require 'wfx_def'

--- Local Settings ---
local can_run = true
local running = false
local can_walk = true
local walking = false
local prone = false
local slide = false
local AmmoFull = false
local AmmoBOX = false
local old_tick = 0
local tick_wait = 0
local reload_wait = 0
---- End Settings ----

function MyBot_lookAt()
	LookAt(point)
end

function MyBot_walk()
  if MyBot_start and can_walk then
	if not walking then
	  WFXPrint("\n MyBot esta andando...")
		PlayAction("moveforward", 4, 1.0)
		walking = true
	end
  elseif not MyBot_start or not can_walk then
	if walking then
	  WFXPrint("\n MyBot parou de andar...")
		PlayAction("moveforward", 2, 0.0)
		walking = false
	end
  end
end

function MyBot_run()
  if MyBot_start and can_run then
	if not running then
	  WFXPrint("\n MyBot esta correndo...")
		PlayAction("haste", 1, 1.0)
		running = true
	end
  elseif not MyBot_start or not can_run then
	if running then
	  WFXPrint("\n MyBot parou de correr...")	
		PlayAction("haste", 1, 0.0)
		running = false
	end
  end
end

function MyBot_crouch(C)
local dist = getDistance(GetCharPos(), point)
  if p == C then
	if dist < 3 then
		PlayAction("crouch", 1, 1.0)
		WFXPrint("\n MyBot esta agachado... \n")
	end
  elseif p == C + 2 then
	if dist > 1then
		PlayAction("crouch", 2, 0.0)
		WFXPrint("\n MyBot esta de pe novamente... \n")
	end
  end
end

function MyBot_interact(E)
  if p == E then
	if (GetTickCount() - old_tick) > 2500 then
		PlayAction("seizure", 1, 1.0)
		WFXPrint("  Opening a Door!\n")
		old_tick = GetTickCount()
	end
  end
end

function MyBot_jump(J)
local dist = getDistance(GetCharPos(), point)
 if p == J and dist < 3 then
	PlayAction("jump", 1, 1.0)
	WFXPrint("\n MyBot pulou...")
  end
end

function MyBot_push(U)
 dist = getDistance(GetCharPos(), point)
  if p == U then
		can_run = false
	if dist > 1 then
		PlayAction("use", 1, 1.0)
		WFXPrint("\n MyBot esta empurrando... \n")
	end
  end
  if p == U + 1 then
	if dist > 1 then
		PlayAction("use", 2, 0.0)
		WFXPrint("\n MyBot parou de empurrar... \n")
	end
	can_run = true
  end
end

function MyBot_slide(S, D1, D2)
local dist = getDistance(GetCharPos(), point)
 local D0 = D1 - 5
 if p == S then
	if slide == false then
	  if dist < D1 and dist > D0 then
		PlayAction("slide", 1, 1.0)
	  WFXPrint("\n MyBot esta deslizando... \n")
		slide = true
	  end
	elseif slide == true then
	  if dist < D2 then
		PlayAction("slide", 1, 1.0)
		PlayAction("slide", 2, 0.0)
	  WFXPrint("\n MyBot parou de deslizar... \n")
		slide = false
	  end
	end
  end
end

function MyBot_Wait(H, SG)
local dist = getDistance(GetCharPos(), point)
 if p == H then
  if (dist > 1) or (tick_wait == 0) then
   tick_wait = GetTickCount()
  end
 end
 if p == H+1 then
   if ((GetTickCount() - tick_wait) > SG*1000) then
    can_walk = true
   else
    can_walk = false
   end
  end
end

function MyBot_reload() -- XXXXXX
	if Reload then
		WFXPrint("\n\n ATTENTION, LOW AMMO!!!\n\n")
		PlayAction("class_specific", 1, 1.0)
		WFXPrint("  Grabbing Ammunition box...\n")
		AmmoBOX = true
		if AmmoBOX and (GetTickCount() - reload_tick) > 10 then
			WFXPrint("  Reloading Ammunition...\n")
			PlayAction("zoom", 1, 1.0)
			PlayAction("zoom", 2, 0.0)
			reload_tick = GetTickCount()
			AmmoFull = true
			WFXPrint("  Ammunition successfully reloaded!\n\n")
		end
		if AmmoFull then
			PlayAction("heavy", 1, 1.0)
			AmmoBOX = false
			Reload = false
			WFXPrint("  Grabbing primary weapon...\n")
		end
	end
end

function WritePoints(ponto)
 file = io.open (WFX_ADDONS_PATH..'mybot\\pontos.txt','a')
 io.output(file)
 io.write('D3DXVECTOR3('..ponto.x..','..ponto.y..','..ponto.z..'),\n')
 io.close(file)
end

function MyBot_Action_Filter(actionId, actiovationMode, value)
 --[[if actionId == "attack1" then
   if actiovationMode == 1 and value == 1 then
	  can_run = false
   elseif actiovationMode == 2 and value == 0 then
	  can_run = true  
   end
 end]]--

 if actionId == "moveforward" and saveP == true then
  if (GetTickCount() - LastTick) > 2000 then
   local clientActor = GetPlayerActor()
   WritePoints(GetPlayerPos(clientActor)) 
   LastTick = GetTickCount()
  end
 end
 
  WFXPrint(string.format("%s %s %s", actionId, actiovationMode, value))
end

WFXRegisterEvent(WFX_EVENTID_ACTION, "MyBot_Action_Filter")