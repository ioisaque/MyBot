require 'settings\\bones'
require 'settings\\settings'
require 'autoattack'
require 'autozoom'
require 'menu\\menu'
require 'mybot\\mybot'
require 'wfx_def'
require 'aim'
require 'esp'

local _print = WFXPrint
local _fmt   = string.format
Warbot       = nil

class 'CWarbot'
function CWarbot:__init()
  --- debugging options ---
  self.debugging_mouse_position = false
  self.debugging = true
  --  debugging end --
  
  -- personalization --
  self.menuTransparency = 200
  
  self.settings = CSettings(WFX_ADDONS_PATH..'last_state.ini')
 
  -- initialize objects --
  self.font  = WFXCreateFont(0,7, FW_EXTRABOLD, false, "Arial")
  self.mouse = D3DXVECTOR3(0,0,0)
  self.menu  = CMenu(5,30)
  self:createMenuComponents()
  
  self:loadSettings()
end

function CWarbot:print(txt)
  if self.debugging then _print(_fmt("Warbot >> %s\n", txt)) end
end

function CWarbot:createMenuComponents()
  self.menuItem_aimbot = self.menu:addItem("Aimbot")
    
  -- subitems do menu aimbot --
  self.menuSubItem_auto_target = self.menu:addSubItem(self.menuItem_aimbot, "Auto-Target [E]")
  self.menuSubItem_aim_mode = self.menu:addSubItem(self.menuItem_aimbot, "Modo: "..aim_mode)
  self.menuSubItem_aim_mode_r = self.menu:addButton_Right(self.menuItem_aimbot, self.menuSubItem_aim_mode)
  self.menuSubItem_aim_mode_l = self.menu:addButton_Left(self.menuItem_aimbot, self.menuSubItem_aim_mode)

  self.menuSubItem_aim_only_insight = self.menu:addSubItem(self.menuItem_aimbot, "Nao mirar fora do FOV")
  
  self.menuSubItem_aim_radius = self.menu:addSubItem(self.menuItem_aimbot, "Alcance: 150")
  self.menuSubItem_aim_radius_r = self.menu:addButton_Right(self.menuItem_aimbot, self.menuSubItem_aim_radius)
  self.menuSubItem_aim_radius_l = self.menu:addButton_Left(self.menuItem_aimbot, self.menuSubItem_aim_radius)
  
  self.menuSubItem_aim_showradius = self.menu:addSubItem(self.menuItem_aimbot, "Mostrar alcance")
  
  self.menuSubItem_aim_interval = self.menu:addSubItem(self.menuItem_aimbot, string.format("Intervalo: %1.1f ms", aim_interval/1000))
  self.menuSubItem_aim_interval_r = self.menu:addButton_Right(self.menuItem_aimbot, self.menuSubItem_aim_interval)
  self.menuSubItem_aim_interval_l = self.menu:addButton_Left(self.menuItem_aimbot, self.menuSubItem_aim_interval)
    
  self.menuSubItem_aim_bone = self.menu:addSubItem(self.menuItem_aimbot, "Alvo: Corpo")
  self.menuSubItem_aim_bone_r = self.menu:addButton_Right(self.menuItem_aimbot, self.menuSubItem_aim_bone)
  self.menuSubItem_aim_bone_l = self.menu:addButton_Left(self.menuItem_aimbot, self.menuSubItem_aim_bone)
  
  self.menuSubItem_aim_melee = self.menu:addSubItem(self.menuItem_aimbot, "Mirar faca: 2 metros")
  self.menuSubItem_aim_melee_r = self.menu:addButton_Right(self.menuItem_aimbot, self.menuSubItem_aim_melee)
  self.menuSubItem_aim_melee_l = self.menu:addButton_Left(self.menuItem_aimbot, self.menuSubItem_aim_melee)
  
  self.menuSubItem_aim_melee_showradius = self.menu:addSubItem(self.menuItem_aimbot, "Mostrar alcance da faca")

  self.menuItem_esp = self.menu:addItem("Radar")
  -- subitems do menu esp --
  self.menuSubItem_esp_name = self.menu:addSubItem(self.menuItem_esp, "Nick dos inimigos")
  self.menuSubItem_esp_skeleton = self.menu:addSubItem(self.menuItem_esp, "Esqueleto dos inimigos")
  self.menuSubItem_esp_line1 = self.menu:addSubItem(self.menuItem_esp, "Linha ao alvo atual")
  self.menuSubItem_esp_line2 = self.menu:addSubItem(self.menuItem_esp, "Linha ao demais alvos")
  self.menuSubItem_esp_distance = self.menu:addSubItem(self.menuItem_esp, "Distancia dos inimigos")
  self.menuSubItem_esp_explosives = self.menu:addSubItem(self.menuItem_esp, "Explosivos")
  self.menuSubItem_esp_circle = self.menu:addSubItem(self.menuItem_esp, "2D Circulo")
  self.menuSubItem_esp_box = self.menu:addSubItem(self.menuItem_esp, "2D Box")
  --self.menuSubItem_esp_class = self.menu:addSubItem(self.menuItem_esp, "Classe dos inimigos")

  self.menuItem_hacks = self.menu:addItem("Hacks")
  --self.menu:getItem(self.menuItem_hacks).checkbox.is_checked = false
  self.menuSubItem_hacks_norecoil = self.menu:addSubItem(self.menuItem_hacks, "Sem recuo")
  --self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_norecoil).checkbox.is_checked = false
  self.menuSubItem_hacks_nospread = self.menu:addSubItem(self.menuItem_hacks, "Sem espalhar")
  --self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_nospread).checkbox.is_checked = false
  self.menuSubItem_hacks_unlimited_run = self.menu:addSubItem(self.menuItem_hacks, "Corrida infinita")
  --self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_unlimited_run).checkbox.is_checked = false
  self.menuSubItem_hacks_unlimited_slide = self.menu:addSubItem(self.menuItem_hacks, "Deslize infinito")
  --self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_unlimited_slide).checkbox.is_checked = false
  self.menuSubItem_hacks_antiflash = self.menu:addSubItem(self.menuItem_hacks, "Anti-flash")
  --self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_antiflash).checkbox.is_checked = false

  self.menuItem_automations = self.menu:addItem("Automations")
  self.menuSubItem_automations_autoattack = self.menu:addSubItem(self.menuItem_automations, "Auto Atacar")  
  self.menuSubItem_automations_autozoom_in = self.menu:addSubItem(self.menuItem_automations, "Auto Zoom In") 
  self.menuSubItem_automations_autozoom_out = self.menu:addSubItem(self.menuItem_automations, "Auto Zoom Out")
  
  self.menuItem_bot = self.menu:addItem("MyBot")
  --self.menuSubItem_bot_esp = self.menu:addSubItem(self.menuItem_bot, "MyBot ESP")
  
  self.menuItem_outros = self.menu:addItem("Outros")
  self.menuSubItem_outros_not = self.menu:addSubItem(self.menuItem_outros, "Ativar Notificacoes")
  self.menuSubItem_outros_menu = self.menu:addSubItem(self.menuItem_outros, "Auto desativar menu")
  self.menuSubItem_outros_fps = self.menu:addSubItem(self.menuItem_outros, "Mostrar FPS")
  self.menuSubItem_outros_mode = self.menu:addSubItem(self.menuItem_outros, "Mostrar Modo atual de jogo")
  self.menuSubItem_outros_watch = self.menu:addSubItem(self.menuItem_outros, "Mostrar Relogio")
end

local function getCheckBoxStatus(cb)
  return cb.is_checked;
end

function CWarbot:updateMenuStatus(menuId,status)
  self.menu:getItem(menuId).checkbox.is_checked = status
end

function CWarbot:updateMenuText(menuId,text)
  self.menu:getItem(menuId).text = text
end

function CWarbot:updateSubItemStatus(menuId,subItemId,status)
  self.menu:getItem(menuId):getSubItem(subItemId).checkbox.is_checked = status
end

function CWarbot:updateSubItemText(menuId,subItemId,text)
  self.menu:getItem(menuId):getSubItem(subItemId).text = text
end

function CWarbot:updateComponents()
  -- aimbot
  self:updateMenuStatus(self.menuItem_aimbot, aim_enabled)  
  self:updateSubItemStatus(self.menuItem_aimbot, self.menuSubItem_auto_target, auto_target)
  self:updateSubItemText(self.menuItem_aimbot, self.menuSubItem_aim_mode, "Modo: "..aim_mode)
  
  local alcance = tostring(aim_radius)
  if aim_radius == 0 then
    alcance = "OFF"
  end
  
  self:updateSubItemStatus(self.menuItem_aimbot, self.menuSubItem_aim_only_insight, aim_only_insight)
  self:updateSubItemText(self.menuItem_aimbot, self.menuSubItem_aim_radius, "Alcance: "..alcance)
  self:updateSubItemStatus(self.menuItem_aimbot, self.menuSubItem_aim_showradius, aim_can_show_radius)
  self:updateSubItemText(self.menuItem_aimbot, self.menuSubItem_aim_interval, string.format("Intervalo: %1.1f ms", aim_interval/1000))
  
  local boneName = "Cabeca"
  if AimBone == SPINE2 then
    boneName = "Corpo"
  end
  
  self:updateSubItemText(self.menuItem_aimbot, self.menuSubItem_aim_bone, "Alvo: "..boneName)
  self:updateSubItemText(self.menuItem_aimbot, self.menuSubItem_aim_melee, string.format("Mirar faca: %1.1f metros", aim_melee_radius))
  self:updateSubItemStatus(self.menuItem_aimbot, self.menuSubItem_aim_melee_showradius, g_IsMeleeRadius_Enabled)
 
  -- radar  
  self:updateMenuStatus(self.menuItem_esp, esp_enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_skeleton, g_IsSkeletonESP_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_box, g_IsBoxESP_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_circle, g_IsCircleESP_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_distance, g_IsDistanceESP_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_line1, g_IsLineESP_1_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_line2, g_IsLineESP_2_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_name, g_IsNameESP_Enabled)
  self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_explosives, g_IsExplosivesESP_Enabled)
  --self:updateSubItemStatus(self.menuItem_esp, self.menuSubItem_esp_class, g_IsClassESP_Enabled)

  -- hacks
  self:updateMenuStatus(self.menuItem_hacks, hacks_enabled)
  self:updateSubItemStatus(self.menuItem_hacks, self.menuSubItem_hacks_norecoil, WFXGetStatus(WFX_FUNCTION_ID_NORECOIL))
  self:updateSubItemStatus(self.menuItem_hacks, self.menuSubItem_hacks_nospread, WFXGetStatus(WFX_FUNCTION_ID_NOSPREAD))
  self:updateSubItemStatus(self.menuItem_hacks, self.menuSubItem_hacks_unlimited_run, WFXGetStatus(WFX_FUNCTION_ID_UNLIMITED_RUN))
  self:updateSubItemStatus(self.menuItem_hacks, self.menuSubItem_hacks_unlimited_slide, WFXGetStatus(WFX_FUNCTION_ID_UNLIMITED_SLIDE))
  self:updateSubItemStatus(self.menuItem_hacks, self.menuSubItem_hacks_antiflash, WFXGetStatus(WFX_FUNCTION_ID_ANTI_FLASH_GRENADE))
  
  -- automations
  self:updateMenuStatus(self.menuItem_automations, automations_enabled)
  self:updateSubItemStatus(self.menuItem_automations, self.menuSubItem_automations_autoattack, autoattack_enabled)
  self:updateSubItemStatus(self.menuItem_automations, self.menuSubItem_automations_autozoom_in, autozoom_in_enabled)
  self:updateSubItemStatus(self.menuItem_automations, self.menuSubItem_automations_autozoom_out, autozoom_out_enabled)
  
  -- mybot
  self:updateMenuStatus(self.menuItem_bot, MyBot_enabled)
  --self:updateSubItemStatus(self.menuItem_bot, self.menuSubItem_bot_esp, MyBot_ESP)
  
  -- outros
  self:updateMenuStatus(self.menuItem_outros, outros_enabled)
  self:updateSubItemStatus(self.menuItem_outros, self.menuSubItem_outros_not, notfications_enabled)
  self:updateSubItemStatus(self.menuItem_outros, self.menuSubItem_outros_menu, canDisableMenu_ok)
  self:updateSubItemStatus(self.menuItem_outros, self.menuSubItem_outros_fps, show_fps)
  self:updateSubItemStatus(self.menuItem_outros, self.menuSubItem_outros_mode, show_mode)
  self:updateSubItemStatus(self.menuItem_outros, self.menuSubItem_outros_watch, show_watch)  
end

function CWarbot:getSecKeyValue(section,key,default_var)
  local val = self.settings:loadKey(section, key)
  if val == nil then 
    val = tostring(default_var)
    self.settings:saveKey(section, key, val)
  end
  return val
end

function CWarbot:loadSettings()     
  local section = "aimbot"  
  
  self:print(string.format("loading %s settings...", section))
  aim_enabled      = self:getSecKeyValue(section,"enabled",aim_enabled) == "true"
  auto_target      = self:getSecKeyValue(section,"autotarget",auto_target) == "true"
  aim_mode         = tonumber(self:getSecKeyValue(section,"mode",aim_mode))
  aim_only_insight = self:getSecKeyValue(section,"onlyinsight",aim_only_insight) == "true"
  aim_radius       = tonumber(self:getSecKeyValue(section,"radius",aim_radius))
  aim_can_show_radius = self:getSecKeyValue(section,"canshowradius",aim_can_show_radius) == "true"
  aim_interval       = tonumber(self:getSecKeyValue(section,"interval",aim_interval))
  aim_bone = tonumber(self:getSecKeyValue(section,"bone",aim_bone))
  aim_can_show_melee_radius = self:getSecKeyValue(section,"canshowmeleeradius",aim_can_show_radius) == "true"
  aim_melee_radius = tonumber(self:getSecKeyValue(section,"meleeradius",aim_melee_radius))
    
  section = "radar"	

  self:print(string.format("loading %s settings...", section))  
  esp_enabled = self:getSecKeyValue(section,"enabled",esp_enabled) == "true"
  g_IsLineESP_1_Enabled = self:getSecKeyValue(section,"showline1",g_IsLineESP_1_Enabled) == "true"
  g_IsLineESP_2_Enabled = self:getSecKeyValue(section,"showline2",g_IsLineESP_2_Enabled) == "true"
  g_IsSkeletonESP_Enabled = self:getSecKeyValue(section,"showskeleton",g_IsSkeletonESP_Enabled) == "true"
  g_IsBoxESP_Enabled = self:getSecKeyValue(section,"show2dbox",g_IsBoxESP_Enabled) == "true"
  g_IsCircleESP_Enabled = self:getSecKeyValue(section,"show2dcircle",g_IsCircleESP_Enabled) == "true"
  g_IsDistanceESP_Enabled = self:getSecKeyValue(section,"showdistance",g_IsDistanceESP_Enabled) == "true"
  g_IsNameESP_Enabled = self:getSecKeyValue(section,"shownames",g_IsNameESP_Enabled) == "true" 
  g_IsExplosivesESP_Enabled = self:getSecKeyValue(section,"showexplosives",g_IsExplosivesESP_Enabled) == "true"
  
  section = "hacks"	

  self:print(string.format("loading %s settings...", section))
  hacks_enabled = self:getSecKeyValue(section,"enabled",hacks_enabled) == "true"
  WFXToggle(WFX_FUNCTION_ID_NORECOIL, self:getSecKeyValue(section,"norecoil",false) == "true")
  WFXToggle(WFX_FUNCTION_ID_NOSPREAD, self:getSecKeyValue(section,"nospread",false) == "true")
  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_RUN, self:getSecKeyValue(section,"unlimitedrun",false) == "true")
  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_SLIDE, self:getSecKeyValue(section,"unlimitedslide",false) == "true")
  WFXToggle(WFX_FUNCTION_ID_ANTI_FLASH_GRENADE, self:getSecKeyValue(section,"antiflash",false) == "true")

  section = "automations"	

  self:print(string.format("loading %s settings...", section))
  automations_enabled = self:getSecKeyValue(section,"enabled",automations_enabled) == "true"
  autoattack_enabled = self:getSecKeyValue(section,"autoattack",autoattack_enabled) == "true"  
  autozoom_in_enabled = self:getSecKeyValue(section,"in",autozoom_in_enabled) == "true"  
  autozoom_out_enabled = self:getSecKeyValue(section,"out",autozoom_out_enabled) == "true"  
  
  section = "outros"	

  self:print(string.format("loading %s settings...", section))  
  outros_enabled = self:getSecKeyValue(section,"enabled",outros_enabled) == "true"
  notfications_enabled = self:getSecKeyValue(section,"not",notfications_enabled) == "true"
  canDisableMenu_ok = self:getSecKeyValue(section,"autodisabledmenu",canDisableMenu_ok) == "true"
  show_fps = self:getSecKeyValue(section,"showfps",show_fps) == "true"
  show_mode = self:getSecKeyValue(section,"showmode",show_mode) == "true"
  show_watch = self:getSecKeyValue(section,"showwatch",show_watch) == "true"
  
  self:print("all settings loaded")
end

function CWarbot:updateSettings()

  local section = "aimbot"
  
  self:print(_fmt("updating %s settings...", section))
  self.settings:saveKey(section, "enabled", tostring(aim_enabled))
  self.settings:saveKey(section, "autotarget", tostring(auto_target))
  self.settings:saveKey(section, "mode", tostring(aim_mode)) 
  self.settings:saveKey(section, "onlyinsight", tostring(aim_only_insight))
  self.settings:saveKey(section, "radius", tostring(aim_radius))
  self.settings:saveKey(section, "canshowradius", tostring(aim_can_show_radius))
  self.settings:saveKey(section, "interval", tostring(aim_interval))
  self.settings:saveKey(section, "bone", tostring(aim_bone))
  self.settings:saveKey(section, "meleeradius", tostring(aim_melee_radius))
  self.settings:saveKey(section, "canshowmeleeradius", tostring(aim_can_show_melee_radius))
  
  section = "radar"
  
  self:print(_fmt("updating %s settings...", section))
  self.settings:saveKey(section,"enabled",tostring(esp_enabled))
  self.settings:saveKey(section,"showline1",tostring(g_IsLineESP_1_Enabled))
  self.settings:saveKey(section,"showline2",tostring(g_IsLineESP_2_Enabled))
  self.settings:saveKey(section,"showskeleton",tostring(g_IsSkeletonESP_Enabled))
  self.settings:saveKey(section,"show2dbox",tostring(g_IsBoxESP_Enabled))
  self.settings:saveKey(section,"show2dcircle",tostring(g_IsCircleESP_Enabled))
  self.settings:saveKey(section,"showdistance",tostring(g_IsDistanceESP_Enabled))
  self.settings:saveKey(section,"shownames",tostring(g_IsNameESP_Enabled))
  self.settings:saveKey(section,"showexplosives",tostring(g_IsExplosivesESP_Enabled))
  
  section = "hacks"

  self:print(_fmt("updating %s settings...", section))
  self.settings:saveKey(section,"enabled",tostring(hacks_enabled))
  self.settings:saveKey(section,"norecoil", tostring(WFXGetStatus(WFX_FUNCTION_ID_NORECOIL)))
  self.settings:saveKey(section,"nospread", tostring(WFXGetStatus(WFX_FUNCTION_ID_NOSPREAD)))
  self.settings:saveKey(section,"unlimitedrun", tostring(WFXGetStatus(WFX_FUNCTION_ID_UNLIMITED_RUN)))
  self.settings:saveKey(section,"unlimitedslide", tostring(WFXGetStatus(WFX_FUNCTION_ID_UNLIMITED_SLIDE)))
  self.settings:saveKey(section,"antiflash", tostring(WFXGetStatus(WFX_FUNCTION_ID_ANTI_FLASH_GRENADE)))

  section = "automations"
  self:print(_fmt("updating %s settings...", section))
  self.settings:saveKey(section,"enabled", tostring(automations_enabled))
  self.settings:saveKey(section,"autoattack", tostring(autoattack_enabled))
  self.settings:saveKey(section,"in", tostring(autozoom_in_enabled))
  self.settings:saveKey(section,"out", tostring(autozoom_out_enabled))
  
  section = "outros"
  
  self:print(_fmt("updating %s settings...", section))
  self.settings:saveKey(section,"enabled",tostring(outros_enabled))
  self.settings:saveKey(section,"not",tostring(notfications_enabled))
  self.settings:saveKey(section,"autodisabledmenu",tostring(canDisableMenu_ok))
  self.settings:saveKey(section,"showfps",tostring(show_fps))
  self.settings:saveKey(section,"showmode",tostring(show_mode))
  self.settings:saveKey(section,"showwatch",tostring(show_watch))
  
  self:print("settings updated")
end

notfications_enabled = true

function CWarbot:onDraw()
  self.menu:show(self.menuTransparency)
  
  if self.menu.disabled then
    return
  end
  
  self:updateComponents()
end

function CWarbot:onLButtonUp()
  --self.menu:onLButtonDown(self.mouse)
    
  if self.menu.disabled then
    return
  end
  
  -- primeiro verifica se o objeto "aimbot" foi clicado
  local object = self.menu:getItem(self.menuItem_aimbot)
  if object.checkbox:onClick(self.mouse) then
    --self:onAimClick(checkbox.object.is_checked)
	aim_enabled = object.checkbox.is_checked
	
	if not aim_enabled then
	  object.canShowSubItems = false
	end
	
	self:updateSettings()
	return 1
  end  
  
  -- primeiramente vamos verificar se os itens estão sendo exibidos na tela  
  if object.canShowSubItems then  
    -- verifica todos os subitems do aimbot   
    for i = 1, #object.subItems do
      -- verifica se o botão direito do modo foi clicado
	  local subItem = object.subItems[i]
	  if subItem.id == self.menuSubItem_aim_mode then	
	    local btn = subItem:getButton(self.menuSubItem_aim_mode_r)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  
		  aim_mode = aim_mode + 1
		  if aim_mode > 3 then
		    aim_mode = 1
		  end
		  subItem.text = "Modo: "..aim_mode
		  
		  if aim_mode == 3 then
		    aim_radius = 0
			object:getSubItem(self.menuSubItem_aim_radius).text = "Alcance: OFF"
		  else
		    aim_radius = 150
			object:getSubItem(self.menuSubItem_aim_radius).text = "Alcance: "..aim_radius
		  end
		  
		  self:updateSettings()
		  return
	    end
		-- verifica se o botão esquerdo foi clicado
		btn = subItem:getButton(self.menuSubItem_aim_mode_l)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  
		  aim_mode = aim_mode - 1
		  if aim_mode < 1 then
		    aim_mode = 3
		  end		  
		  subItem.text = "Modo: "..aim_mode
		  
		  if aim_mode == 3 then
		    aim_radius = 0
			object:getSubItem(self.menuSubItem_aim_radius).text = "Alcance: OFF"
		  else
		    aim_radius = 150
			object:getSubItem(self.menuSubItem_aim_radius).text = "Alcance: "..aim_radius
		  end
		  
		  self:updateSettings()
		  return
	    end
	  end
	  
	  if subItem.id == self.menuSubItem_aim_radius then 
	    local btn = subItem:getButton(self.menuSubItem_aim_radius_r)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_radius = aim_radius + 50
		  if aim_radius > 1000 then
		    aim_radius = 1000
		  end
		  --subItem.text = "Alcance: "..aim_radius
		  self:updateSettings()
		  return
	    end
		-- verifica se o botão esquerdo foi clicado
		btn = subItem:getButton(self.menuSubItem_aim_radius_l)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_radius = aim_radius - 50
		  --subItem.text = "Alcance: "..aim_radius
		  if aim_radius <= 0 then
		    aim_radius = 0
			--subItem.text = "Alcance: OFF"
		  end		  
		  self:updateSettings()
		  return
	    end
	  end

	  if subItem.id == self.menuSubItem_auto_target then
	    if subItem.checkbox:onClick(self.mouse) then
		  auto_target = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_aim_showradius then
	    if subItem.checkbox:onClick(self.mouse) then
		  aim_can_show_radius = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_aim_only_insight then
	    if subItem.checkbox:onClick(self.mouse) then
		  aim_only_insight = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end	  
	  
	  if subItem.id == self.menuSubItem_aim_interval then 
	    local btn = subItem:getButton(self.menuSubItem_aim_interval_r)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_interval = aim_interval + 100
		  if aim_interval > 3000 then
		    aim_interval = 3000
		  end
		  subItem.text = string.format("Intervalo: %1.1f ms", aim_interval/1000)
		  self:updateSettings()
		  return
	    end
		-- verifica se o botão esquerdo foi clicado
		btn = subItem:getButton(self.menuSubItem_aim_interval_l)
    	if btn:onClick(self.mouse) then
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_interval = aim_interval - 100
		  subItem.text = string.format("Intervalo: %1.1f ms", aim_interval/1000)
		  if aim_interval <= 0 then
		    aim_interval = 0
			subItem.text = "Intervalo: OFF"
		  end
		  self:updateSettings()
		  return
	    end
	  end
	  
	  if subItem.id == self.menuSubItem_aim_bone then 
	    local btn = subItem:getButton(self.menuSubItem_aim_bone_r)
    	if btn:onClick(self.mouse) then  
		  --if subItem.text == "Alvo:: Cabeca [PGDOWN]" then
		    --subItem.text = "Alvo:: Corpo [PGDOWN]"
			--AimBone = SPINE2
		  --else
		    --AimBone = R_EYE
		    --subItem.text = "Alvo:: Cabeca [PGDOWN]"
		  --end
		  
		  if AimBone == R_EYE then
		    AimBone = SPINE2
		  else 
		    AimBone = R_EYE
		  end
		  
		  self:updateSettings()
		  return 1
	    end
		btn = subItem:getButton(self.menuSubItem_aim_bone_l)
    	if btn:onClick(self.mouse) then		
		  --if subItem.text == "Alvo:: Cabeca [PGDOWN]" then
		    --subItem.text = "Alvo:: Corpo [PGDOWN]"
			--AimBone = SPINE2
		  --else
		    --AimBone = R_EYE
		    --subItem.text = "Alvo:: Cabeca [PGDOWN]"
		  --end
		  
		  if AimBone == R_EYE then
		    AimBone = SPINE2
		  else 
		    AimBone = R_EYE
		  end
		  
		  self:updateSettings()
		  return 1
	    end
	  end	  	  

	  if subItem.id == self.menuSubItem_aim_melee then 
	  
	    local btn = subItem:getButton(self.menuSubItem_aim_melee_r)
	    if btn:onClick(self.mouse) then  
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_melee_radius = aim_melee_radius + 0.5
		  if aim_melee_radius > 3.0 then
		    aim_melee_radius = 0.5
		  end
		  subItem.text = string.format("Mirar faca: %1.1f metros", aim_melee_radius)
		  self:updateSettings()
	      return
	    end

	    btn = subItem:getButton(self.menuSubItem_aim_melee_l)
		if btn:onClick(self.mouse) then  		  
		  -- clicou em cima do objeto então muda o valor do modo
		  aim_melee_radius = aim_melee_radius - 0.5		  
		  if aim_melee_radius <= 0 then
		    aim_melee_radius = 3.0
		  end
		  subItem.text = string.format("Mirar faca: %1.1f metros", aim_melee_radius)
		  self:updateSettings()
		  return
		end
	  end
		
	  if subItem.id == self.menuSubItem_aim_melee_showradius then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsMeleeRadius_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	
	end
	--só uma lista de subitems é exibida por menu, portanto se este já está sendo exibido o próximo não estará
	return 1
  end

  -- esp     
  object = self.menu:getItem(self.menuItem_esp)
  if object.checkbox:onClick(self.mouse) then
    --self:onAimClick(checkbox.object.is_checked)
	esp_enabled = object.checkbox.is_checked
	
	if not esp_enabled then
	  object.canShowSubItems   = false
	end
	
	self:updateSettings()
	return 1
  end  

  if object.canShowSubItems then
    -- verifica todos os subitems do aimbot   
    for i = 1, #object.subItems do
      -- verifica se o botão direito do modo foi clicado
	  local subItem = object.subItems[i]
	  
	  if subItem.id == self.menuSubItem_esp_skeleton then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsSkeletonESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end		
	  end

	  --if subItem.id == self.menuSubItem_esp_class then
	    --if subItem.checkbox:onClick(self.mouse) then
		  --g_IsClassESP_Enabled = subItem.checkbox.is_checked
		  --self:updateSettings()
		  --return
		--end		
	  --end
	  
	  if subItem.id == self.menuSubItem_esp_box then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsBoxESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end		
	  end

	  if subItem.id == self.menuSubItem_esp_line1 then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsLineESP_1_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end

	  if subItem.id == self.menuSubItem_esp_line2 then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsLineESP_2_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_esp_circle then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsCircleESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_esp_distance then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsDistanceESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_esp_name then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsNameESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end    	  	  
	  
	  if subItem.id == self.menuSubItem_esp_explosives then
	    if subItem.checkbox:onClick(self.mouse) then
		  g_IsExplosivesESP_Enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end	    	  
	end
	
	--....
	return 1
  end
 
  -- hacks
  object = self.menu:getItem(self.menuItem_hacks)
  if object.checkbox:onClick(self.mouse) then
	hacks_enabled = object.checkbox.is_checked
	
	if not hacks_enabled then
	  WFXToggle(WFX_FUNCTION_ID_NORECOIL, false)
	  WFXToggle(WFX_FUNCTION_ID_NOSPREAD, false)
	  WFXToggle(WFX_FUNCTION_ID_ANTI_FLASH_GRENADE, false)
	  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_RUN, false)
	  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_SLIDE, false)
	  
	  self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_norecoil).checkbox.is_checked = false
	  self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_nospread).checkbox.is_checked = false
	  self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_antiflash).checkbox.is_checked = false
	  self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_unlimited_run).checkbox.is_checked = false
	  self.menu:getItem(self.menuItem_hacks):getSubItem(self.menuSubItem_hacks_unlimited_slide).checkbox.is_checked = false
	  
	  object.canShowSubItems   = false
	end	
	self:updateSettings()
	return 1
  end  
  
  if object.canShowSubItems then
    for i = 1, #object.subItems do     
	  local subItem = object.subItems[i]
	  
	  if subItem.id == self.menuSubItem_hacks_unlimited_run then
	    if subItem.checkbox:onClick(self.mouse) then
		  --subItem.checkbox.is_checked = not subItem.checkbox.is_checked
		  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_RUN, subItem.checkbox.is_checked)		
          self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_hacks_unlimited_slide then
	    if subItem.checkbox:onClick(self.mouse) then
		  --subItem.checkbox.is_checked = not subItem.checkbox.is_checked
		  WFXToggle(WFX_FUNCTION_ID_UNLIMITED_SLIDE, subItem.checkbox.is_checked)
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_hacks_norecoil then
	    if subItem.checkbox:onClick(self.mouse) then
		  WFXToggle(WFX_FUNCTION_ID_NORECOIL, subItem.checkbox.is_checked)
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_hacks_nospread then
	    if subItem.checkbox:onClick(self.mouse) then
		  WFXToggle(WFX_FUNCTION_ID_NOSPREAD, subItem.checkbox.is_checked)
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_hacks_antiflash then
	    if subItem.checkbox:onClick(self.mouse) then
		  WFXToggle(WFX_FUNCTION_ID_ANTI_FLASH_GRENADE, subItem.checkbox.is_checked)
		  self:updateSettings()
		  return
		end
	  end	  	  
	end
	
	--....
	return 1
  end  

    -- automations
  object = self.menu:getItem(self.menuItem_automations)
  if object.checkbox:onClick(self.mouse) then
    --self:onAimClick(checkbox.object.is_checked)
	automations_enabled = object.checkbox.is_checked
	
    if not object.checkbox.is_checked then  
	  autoattack_enabled       = false
	  autozoom_in_enabled      = false
	  autozoom_out_enabled     = false
	  
	  object.canShowSubItems   = false
    end
	
	self:updateSettings()
	return 1
  end

  if object.canShowSubItems then 
    for i = 1, #object.subItems do     
	  local subItem = object.subItems[i]
	  
	  if subItem.id == self.menuSubItem_automations_autoattack then
	    if subItem.checkbox:onClick(self.mouse) then
		  autoattack_enabled = subItem.checkbox.is_checked  
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_automations_autozoom_in then
	    if subItem.checkbox:onClick(self.mouse) then
		  autozoom_in_enabled = subItem.checkbox.is_checked  
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_automations_autozoom_out then
	    if subItem.checkbox:onClick(self.mouse) then
		  autozoom_out_enabled = subItem.checkbox.is_checked  
		  self:updateSettings()
		  return
		end
	  end	  
	end
	
	--...
	return 1
  end

  -- mybot   
  object = self.menu:getItem(self.menuItem_bot)
    if object.checkbox:onClick(self.mouse) then
      --self:onAimClick(checkbox.object.is_checked)
      MyBot_enabled = object.checkbox.is_checked
	  
      if MyBot_enabled then
        automations_enabled = true
		autoattack_enabled = true
	  else
		object.canShowSubItems = false
      end

     self:updateSettings()
     return 1
   end
  
  -- outros   
  object = self.menu:getItem(self.menuItem_outros)
  if object.checkbox:onClick(self.mouse) then
    --self:onAimClick(checkbox.object.is_checked)
	outros_enabled = object.checkbox.is_checked
	
	if not outros_enabled then
	  notfications_enabled = false
	  canDisableMenu_ok = false
	  show_fps = false
	  show_watch = false
	  show_mode = false
	  
	  object.canShowSubItems = false
	else
	  show_fps = true
	  show_watch = true
	  show_mode = true
	end
	
	self:updateSettings()
	return 1
  end
  
  if object.canShowSubItems then
    -- verifica todos os subitems do aimbot
    for i = 1, #object.subItems do
      -- verifica se o botão direito do modo foi clicado
	  local subItem = object.subItems[i]

	  if subItem.id == self.menuSubItem_outros_not then
	    if subItem.checkbox:onClick(self.mouse) then
		  notfications_enabled = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end	  
	  
	  if subItem.id == self.menuSubItem_outros_menu then
	    if subItem.checkbox:onClick(self.mouse) then
		  canDisableMenu_ok = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end	  
	  
	  if subItem.id == self.menuSubItem_outros_fps then
	    if subItem.checkbox:onClick(self.mouse) then
		  show_fps = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end

	  if subItem.id == self.menuSubItem_outros_watch then
	    if subItem.checkbox:onClick(self.mouse) then
		  show_watch = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end
	  
	  if subItem.id == self.menuSubItem_outros_mode then
	    if subItem.checkbox:onClick(self.mouse) then
		  show_mode = subItem.checkbox.is_checked
		  self:updateSettings()
		  return
		end
	  end	  
	  
	--....
  end
 end
end

function CWarbot:onMouseMove(pos)
  self.mouse = pos
  self.menu:onMouseMove(pos)
  if self.debugging_mouse_position then
    self:print(_fmt("mouse {x: %d, y: %d}", self.mouse.x, self.mouse.y))
  end
end

function warbot_ondraw()
  Warbot:onDraw()
end

function warbot_lbuttondown()
  Warbot:onLButtonDown()
end

function warbot_lbuttonup()
  return Warbot:onLButtonUp()
end

function warbot_mousemove(pos)
  Warbot:onMouseMove(pos)
end

Warbot = CWarbot()
WFXRegisterEvent(WFX_EVENTID_DRAW, "warbot_ondraw")
WFXRegisterEvent(WFX_EVENTID_LBUTTON_UP, "warbot_lbuttonup")
WFXRegisterEvent(WFX_EVENTID_MOUSEMOVE, "warbot_mousemove")