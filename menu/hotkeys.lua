require 'settings\\colors'
require 'settings\\vk'
require 'menu\\warbot'

local isControlPressed = false
local canShowHint      = false
local hint_t           = GetTickCount()
local font = WFXCreateFont(0,7,FW_EXTRABOLD, false, "Arial")

PTA = false

function hotkeys_activateapp(activated)
  if activated == 0 then
    isControlPressed = false
  end
end

function hotkeys_onkeydown(Key)
  if Key == VK_CONTROL then
    isControlPressed = true
  end
  if Key == KEY_CAPS then
	--ExecuteGameCommand("gameroom_close_auto")
	--ExecuteGameCommand("private_mission_click")	
  end  
end

function openMenuSubItems(menuItemId)
  local openObject = Warbot.menu:getItem(menuItemId)
  if openObject.checkbox.is_checked then    
    openObject.canShowSubItems = false
    return
  end
  for i = 1, #Warbot.menu.items do
    local item = Warbot.menu.items[i]
	if openObject.id ~= item.id then
	  item.canShowSubItems = false
	end
  end
  openObject.canShowSubItems = true  
end

function hotkeys_onkeyup(Key)  
  --habilita/desabilita magnetic
  if Key == VK_DEL then
    local newState = WFXGetStatus(WFX_FUNCTION_ID_VAC)
	if newState then 
	  if not mag_fixed then
	    mag_fixed = true
		g_vacPos = GetPlayerPos(GetPlayerActor())
		g_vacPos.y = g_vacPos.y + 1.5
	  elseif mag_fixed then
        mag_fixed = false
        WFXToggle(WFX_FUNCTION_ID_VAC, false)
		mag_enabled = false
      end
	else
	  mag_fixed = false
	  WFXToggle(WFX_FUNCTION_ID_VAC, true)
	  mag_enabled = true
	end
  end
  
  if Key == VK_F5 then    	
    openMenuSubItems(Warbot.menuItem_aimbot)
	local cb = Warbot.menu:getItem(Warbot.menuItem_aimbot).checkbox 
	local subItem = Warbot.menu:getItem(Warbot.menuItem_aimbot):getSubItem(Warbot.menuSubItem_aim_mode)
	
	if not cb.is_checked then
	  aim_enabled = true
	  cb.is_checked = true
	  aim_mode = 1
	  --Warbot.menu:getItem(Warbot.menuItem_aimbot).text = "Aimbot I"
	  subItem.text = "Modo: 1"
	else
	  if aim_mode == 1 then
	    aim_mode = 2
		--Warbot.menu:getItem(Warbot.menuItem_aimbot).text = "Aimbot II"
		subItem.text = "Modo: 2"
	  elseif aim_mode == 2 then
	    aim_mode = 3
		--Warbot.menu:getItem(Warbot.menuItem_aimbot).text = "Aimbot III"
		subItem.text = "Modo: 3"
	  elseif aim_mode == 3 then
	    aim_mode = 1
		cb.is_checked = false
		--Warbot.menu:getItem(Warbot.menuItem_aimbot).text = "Aimbot I"
		subItem.text = "Modo: 1"
		aim_enabled = false
	  end
	end	
    Warbot.menu.disabled = false  
    return
  end

  if Key == VK_CONTROL then
    isControlPressed = false
  end

  if Key == KEY_CAPS then
    PTA = false
  end
  
  if Key == VK_END then
    Warbot.menu:toggle()
  end
  
  if Key == VK_ESC then
    Warbot.menu.disabled = false
  end
  
  if Key == KEY_PGDN then   
    local subItem = Warbot.menu:getItem(Warbot.menuItem_aimbot):getSubItem(Warbot.menuSubItem_aim_bone)
	
	canShowHint = true
		
	if subItem.text == "Alvo: Cabeca" then
	  AimBone = SPINE2
	  subItem.text = "Alvo: Corpo"
	else
	  AimBone = R_EYE
	  subItem.text = "Alvo: Cabeca"
	end
	Warbot:updateSettings()
  end  
  
  --WFXPrint(string.format("%d", Key))
end

function hotkeys_draw()
  if canShowHint then
    local s = "????"
	
	if AimBone == SPINE2 then
	  s = "CORPO"
	else
	  s = "CABECA"
	end

	if notfications_enabled then myDrawText(font, NOT_COLOR, 190, 35, 20, 10, string.format("Mira do aimbot modificada para %s!", s)) end
		
	if (GetTickCount() - hint_t) > 3000 then
	  canShowHint = false
	end
	return
  end
  hint_t = GetTickCount()
end

WFXRegisterEvent(WFX_EVENTID_DRAW, "hotkeys_draw")
WFXRegisterEvent(WFX_EVENTID_KEYDOWN, "hotkeys_onkeydown")
WFXRegisterEvent(WFX_EVENTID_KEYUP, "hotkeys_onkeyup")
WFXRegisterEvent(WFX_EVENTID_ACTIVATEAPP, "hotkeys_activateapp")