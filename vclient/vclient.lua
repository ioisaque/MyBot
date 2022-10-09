require 'wfx_def'
require 'vclient\\vclient_commands'

roomId = 0
from   = ""

local function on_gameroom_open()
  WFXPrint("criou uma sala\n")
end

local function on_gameroom_join()
  WFXPrint("entrou na sala\n")
end

local function on_session_join()
  WFXPrint("iniciou a partida\n")
  
  
  
  --WFXGetVClientMgr():removeAll()
  --WFXPrint("operacao concluida!\n")
end

local function on_gameroom_leave()
  roomId = 0
  WFXGetVClientMgr():removeAll()
  WFXPrint("saiu da sala\n")  
end

local function on_packet(name,t)
  --WFXPrint(string.format("node name is: %s\n", name))
  
  if name == "gameroom_leave" then
    on_gameroom_leave()
	return
  end
	  
  if name == "session_join" then
	on_session_join()
	return
  end
	
  if name == "gameroom_join" then
	on_gameroom_join()
	return
   end	
   
   if name == "gameroom_open" then
     on_gameroom_open()
   end
end

local function list_table(name, t)
  WFXPrint(string.format("%d listando tabela %s\n", #t, name))
  for i = #t, 1, -1 do   
    WFXPrint(string.format("%s\n", t[i].n))  
  end
  WFXPrint("fim da listagem\n")
end

local function make_luatable(t) 
  local lt = {}
  for i = #t, 1, -1 do   
    local name = t[i].n
	local val  = t[i].val
	if not val then 
	  val = "nil"
	end
    lt = {name}
	lt[name] = t[i].val
  end
  return lt
end

local function on_query(name, t)
  list_table(name,t)
  local name = t[i].n
  --if name then 
end

local function find_table(name,t)
  for i = 1, #t do  
    if t[i].n == name then
      return t[i].t
    end
  end	
end

local function list_iq(name, pattern, t)
  if not name then
    WFXPrint("invalid name\n")
    return
  end  
  if not t then
    WFXPrint(string.format("%s has an invalid table\n", name))
    return
  end
  
  --WFXPrint(string.format("name is: '%s'\n", name))
  
  if name == "gameroom_open" then
	t = find_table("game_room", pattern)
	list_table("game_room", t)
	t = make_luatable(t)
	roomId = tonumber(t["room_id"])
	if not roomId then
      roomId = 0 
    end
  elseif name == "gameroom_join" then 
    t = make_luatable(t)
	roomId = tonumber(t["room_id"])
	if not roomId then
      roomId = 0 
    end
  elseif name == "gameroom_leave" then
    on_gameroom_leave()
   elseif name == "session_join" then
	WFXGetVClientMgr():removeAll()
  end  
end

local function on_iq(t)  
  for i = #t, 1, -1 do     
    list_iq(t[i].n, t, t[i].t)
  end
end

local function handle_recv(name, t) 
  --WFXPrint(string.format("handle_recv %s\n", name))  
  if name == "iq" then
    on_iq(t)
   end
end

function loadServer(t)
  for i = 1, #t do
    if (t[i].n == "iq") then
	  local att = t[i].t
	  if att then
	    for j = 1, #att do
	      if att[j].n == "from" then
			if string.find(att[j].val, "masterserver@warface/") then
			  from = string.sub(att[j].val, 22)
			  return
			end
		  end
		end
      end
	end
  end
end
	
function vclient_recv(t)
  loadServer(t)
  --WFXPrint("packet start\n")
  for i = #t, 1, -1 do   
    handle_recv(t[i].n, t)
  end
  --WFXPrint("packet end\n")
  --[[
  
    if (t[i].n == "query") then
	  on_iq(t)
	end
	
	if node.n == "iq" then
	  on_iq(t)
	end
	
	local node = t[i-1]	
	if node == nil then
	  goto l_next1
	end
	on_packet(node.n, t)	
	::l_next1::
  end
  --]]
end

WFXRegisterEvent(WFX_EVENTID_RECV_DATA, "vclient_recv")