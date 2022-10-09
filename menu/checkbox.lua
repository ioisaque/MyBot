require 'wfx_def'
require 'settings\\colors'

local images_path = WFX_ADDONS_PATH .. 'menu\\imgs\\'
local img_on      = WFXLoadImage(images_path .. 'on.png')
local img_off     = WFXLoadImage(images_path .. 'off.png')
local global_id = 1

class 'CCheckBox'
function CCheckBox:__init(x,y)
  self.clickListener = nil
  self.id   = global_id
  global_id = global_id + 1
  self.rect = {left=x, top=y, right=0, bottom=0}
  self.is_checked = true
  self:updateRect()
  return self.id
end

function CCheckBox:registerClickListener(f)
  self.clickListener = f
end

function CCheckBox:updateRect()
  local size = nil
  if self.is_checked then 
    size = WFXGetImageSize(img_on)  
  else 
    size = WFXGetImageSize(img_off)  
  end  
  self.rect.right = size.x
  self.rect.bottom = size.y
end  

function CCheckBox:onClick(pos)
  if self:ptInRect(pos) then
    self:click()
	if self.clickListener ~= nil then  
	  self.clickListener(self.is_checked)
	end
	return true
  end
  return false
end

function CCheckBox:ptInRect(pt)
  self:updateRect()
  return 
    pt.x > self.rect.left and
	pt.y > self.rect.top and
	pt.x < self.rect.left + self.rect.right and
	pt.y < self.rect.top  + self.rect.bottom and true or nil
end

function CCheckBox:click()
  self.is_checked = not self.is_checked
  return self.is_checked
end

function CCheckBox:show(transparency)
  local image = img_on
  if not self.is_checked then
    image = img_off
  end
  self:updateRect()
  WFXDrawImage(image, D3DXVECTOR3(self.rect.left, self.rect.top, 0), transparency) -- sub e item
end