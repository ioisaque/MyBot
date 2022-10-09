require 'wfx_def'
require 'mybot\\mybot'
require 'menu\\warbot'
require 'menu\\hotkeys'
require 'vclient\\vclient'

function getDate()
	return tostring(os.date("%d/%m/%Y"))
end

function getTime()
	return tostring(os.date("%H:%M:%S"))
end

local oldTick = 0
local last_FPS = 0
local FPS = 0

function getFPS()
	return last_FPS
end

function fps_ondraw()
	if oldTick == 0 then
		oldTick = GetTickCount()
	end
	if ((GetTickCount() - oldTick) < 1000) then
		FPS = FPS + 1
	else
		last_FPS = FPS
		FPS = 0
		oldTick = 0
	end
	
--WFXPrint(string.format("PvEGetReadyStatus --> %s", PvEGetReadyStatus()))
--WFXPrint(string.format("PvEGetRoomPrivateStatus --> %s", PvEGetRoomPrivateStatus()))
end

WFXRegisterEvent(WFX_EVENTID_DRAW, "fps_ondraw")