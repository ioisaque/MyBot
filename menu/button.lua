require 'wfx_def'

local images_path = WFX_ADDONS_PATH .. 'menu\\imgs\\'
local direita      = WFXLoadImage(images_path .. 'direita.png')
local esquerda     = WFXLoadImage(images_path .. 'esquerda.png')
local global_id = 1

class 'CButton'
function CButton:__init(x,y,position)
  self.id   = global_id
  global_id = global_id + 1
  local size = nil  
  size = WFXGetImageSize(direita)
  self.rect = {left=x+10, top=y+3, right=size.x, bottom=size.y}
  
  --WFXPrint(string.format("%d,%d", self.rect.left, self.rect.top))
  
  --WFXPrint(string.format("%d,%d", x,y))
  --WFXPrint(string.format("%d,%d", self.rect.left, self.rect.top))
  
  if (position == "direita") then
	self.image = direita
  else
	self.image = esquerda
  end
  
  return self.id
end

function CButton:onClick(pos)
  if self:ptInRect(pos) then
    return true
  else
	return false
  end
end

function CButton:ptInRect(pt)
  return 
    pt.x > self.rect.left and
	pt.y > self.rect.top and
	pt.x < self.rect.left + self.rect.right and
	pt.y < self.rect.top  + self.rect.bottom and true or nil
end

function CButton:show()
  WFXDrawImage(self.image, D3DXVECTOR3(self.rect.left, self.rect.top, 0), 255)
end