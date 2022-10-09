require 'settings\\colors'
require 'wfx_def'

---- Cores do ESP ----
info = GREEN -- "Nº do ponto e distância"
circle = YELLOW -- "circulo do ponto"
---- End Settings ----

function getDistanceSqr(p1,p2)
  return (p1.x - p2.x) ^ 2 + ((p1.y) - (p2.y)) ^ 2 + (p1.z - p2.z) ^ 2
end

function getDistance(p1,p2)
  return math.sqrt(getDistanceSqr(p1,p2))
end

function mark_point(pos,radius,color)
 
  if (pos.x + pos.y + pos.z) == 0.0 then
    WFXPrint(string.format("invalid point pos in mybot_esp\n"))
    return
  end
   
  local range = radius
  local pi = 3.14159265
  local step = (pi * 2.0)/60
 
  local a = 0  
  local oldpos = D3DXVECTOR3(range * math.cos(a) + pos.x, range * math.sin(a) + pos.y, pos.z)
  local newpos = D3DXVECTOR3(0,0,0)
 
  repeat    
    newpos.x = range * math.cos(a) + pos.x
        newpos.y = range * math.sin(a) + pos.y
        newpos.z = pos.z
       
        local sp = WorldToScreen(newpos)
        local ep = WorldToScreen(oldpos)
       
        if (sp.x + sp.y + sp.z) >  0 then
          if (ep.x + ep.y + ep.z) > 0 then
            FDrawLine(sp.x, sp.y, ep.x, ep.y, 2, color)
          end
        end
               
        a = a + step
       
        oldpos.x = newpos.x
        oldpos.y = newpos.y
        oldpos.z = newpos.z
       
  until a >= pi*2.0
end

function MyBot_Esp(point)		
  local dist = getDistance(GetCharPos(), point)	
  local pointPos = WorldToScreen(point)
  local screen = GetScreenResolution()
	
  --if MyBot_ESP then
	mark_point(point, 1.0, circle)
	LDrawString(pointPos.x, pointPos.y, 0, 1.0, info, string.format("Ponto %d", p))
	LDrawString(pointPos.x, pointPos.y + 10, 0, 1.0, info, string.format("Distancia %1.0f m", dist))
  --end
end