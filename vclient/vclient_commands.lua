require 'settings\\settings'

local settings = CSettings(WFX_ADDONS_PATH.."vclient\\vclients.ini")

function getcommand(text)
  if text:byte(1) == 47 then -- if "/"
    local command = text:sub(2)
	if not command:find(" ") then
	  return {command,nil}
	end	
	if command then
	  command = command:sub(1, command:find(" ")-1)
	  text = text:sub(command:len()+3)
	  return {command,text}
	end
  end
end

function vclient_print(client, s)
  local _fmt = string.format
  --WFXPrint(_fmt("'%s' %s",client:getUsername(), s))
end

function vclient_vclientlistener(client, eventId)
  --vclient_print(client, string.format("eid: %d\n\n", eventId))

  if (eventId == -1) then
    --vclient_print(client, "erro.\n")
  elseif (eventId == 0) then
    --vclient_print(client, "conectando-se ao jogo...\n")
  elseif (eventId == 1) then    
    --vclient_print(client, "conectou-se ao jogo.\n")
	--settings:saveKey(client:getUsername(), "password", client:getPassword())
	--client:selectServer(from)
	--vclient_print(client, string.format("tentando conectar-se ao canal: '%s'...\n", from))
  elseif (eventId == 2) then
    --vclient_print(client, "desconectou-se do jogo.\n")    
  elseif (eventId == 3) then
    settings:saveKey(client:getUsername(), "password", client:getPassword())
    --vclient_print(client, "conectou.\n")
	client:selectServer(from)
  elseif (eventId == 4) then
    --vclient_print(client, string.format("conectou-se ao canal (Nickname: '%s').\nentrando na sala: %d (%s)...\n", client:getNickname(), roomId, from))
	client:gameRoomJoin(roomId, 0, "", 0, 0, 0)
    
	--vclient_print(client, string.format("falhou para conectar-se ao canal '%s'.\n", from))
  elseif (eventId == 80) then
    vclient_print(client, "falhou ao entrar na sala.\n")
  end
end

local vClientMgr = WFXGetVClientMgr()

function enumHandler(username, password)
  local cli = vClientMgr:create(username,password)
  cli:registerListener("vclient_vclientlistener")
  cli:init()

  --WFXPrint(string.format("aa %s %s\n", username, password))  
  --local cli = WFXCreateVClient(username, password)
  --cli:init()
--  cli:registerListener("vclient_vclientlistener")
--  cli:setPassword(password)
  --cli:init()
end

function vclient_command_filter(text)  
  local v = getcommand(text)
  if not v then
    WFXPrint(string.format("'%s' is not command a command prefix\n", text))
    return
  end
  local cmd = v[1]
  local cmdval = v[2]
  
  WFXPrint(string.format("'%s' '%s'\n", cmd, cmdval))
  
  if cmd == "room" then
    --[[if cmdval then
      cli:gameRoomJoin(tonumber(cmdval), 0, 0, 0, 0)
	else
	  cli:gameRoomJoin(roomId, 0, 0, 0, 0)
	end
    return 1--]]
  end
   
  if cmd == "del" then
    if cmdval then
	  settings:deleteSection(cmdval)
	end
    return 1
  end  
  
  if cmd == "start" then
    WFXPrint("HEEEYY")
    --sendXML("gameroom_askserver", 
	
	--local s = makeQueryHeader(from, "kaway", "gameroom_setplayer team_id='0' status='1' class_id='0'")
	--sendXML("gameroom_setplayer", s)
	--[[
	s = makeQueryHeader("main_pve", "kaway", "gameroom_ask_server", nil)
	--]]
	--WFXPrint(string.format("aa '%x'\n", tonumber(getUID(false))))
	
	initGame()
	askServer()
		
	WFXPrint("bxx")
	
	--sendXML("gameroom_askserver", s)
	
    return 1
  end
  
  if cmd == "cmd" then
    if cmdval == "on" then
	  WFXAllocConsole()
	elseif cmdval == "off" then
	  WFXFreeConsole()
    end
	
	return 1
  end
  
  if cmd == "server" then
    cli:selectServer("main_pvp_newbie_1")
    return 1
  end
  
  if cmd == "dc" then
    WFXPrint("removendo vclients...\n")
    vClientMgr:removeAll()
	WFXPrint("operacao concluida!\n")
	return 1
  end
  
  if cmd == "c" then
    if cmdval then
	  v = getcommand(string.format("/%s", cmdval))
	  if not v then 
	    WFXPrint("invalid command format\n")
		return 1
	  end
	  
	  local username = v[1]
	  local password = v[2]
	   
	  local cli = vClientMgr:create(username,password)
	  cli:registerListener("vclient_vclientlistener")
	  cli:init()
	  
	  --WFXPrint(string.format("conectando conta: '%s' pw: '*'\n", username, password))  
	  return 1
	else
	  WFXPrint("conectando contas atraves do arquivo 'vclient.ini'\n")
	  settings:enumSections(enumHandler)
	end
	
	return 1
  end
  return 1
end

WFXRegisterEvent(WFX_EVENTID_CHAT_MESSAGE, "vclient_command_filter")