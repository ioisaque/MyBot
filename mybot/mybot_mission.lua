--###############################--
--#								#--
--#		  Define Mission		#--
--#								#--
--###############################--
require 'mybot\\mapas\\along_the_road'
require 'mybot\\mapas\\pathfinder'
require 'mybot\\mapas\\refugio'

function MyBot_DefineMission()
  PONTOS()	ACOES()
end

function ACOES()
	--along_the_road_actions()
	pathfinder_actions()
	--refugio_actions()
end

function PONTOS()
	--along_the_road()
	pathfinder()
	--refugio()
end