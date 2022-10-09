--###############################--
--#								#--
--# 	 Mission Pathfinder  	#--
--#        						#--
--###############################--

local points = {
D3DXVECTOR3(334.60131835938,84.334701538086,27.622331619263),
D3DXVECTOR3(338.33477783203,91.759635925293,27.065668106079),
D3DXVECTOR3(339.04156494141,99.986053466797,26.61626625061),
D3DXVECTOR3(338.52685546875,108.87387084961,27.270341873169),
D3DXVECTOR3(338.02737426758,117.18686676025,29.509950637817),
D3DXVECTOR3(338.10794067383,125.72666931152,31.061729431152),
D3DXVECTOR3(338.47122192383,132.484375,31.215679168701),
D3DXVECTOR3(338.25616455078,141.29336547852,31.211067199707),
D3DXVECTOR3(337.9306640625,149.89804077148,30.104200363159)
}

function pathfinder_actions()
 MyBot_jump(3)
 MyBot_jump(5)
 MyBot_interact(12)
 MyBot_push(25)
 MyBot_interact2(32)
end

function pathfinder()
 if(p > #points) then
  bot_start = false
  p = 1
 end
 point = points[p]
end

--- Neste arquivo contém apenas os pontos predefinidos do mapa.