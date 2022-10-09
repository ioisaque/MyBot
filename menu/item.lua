require 'settings\\colors'
require 'menu\\checkbox'
require 'menu\\drawtext'

class 'CItem'
function CItem:__init(rect, text)
  self.canShowSubItems = false
  self.rect = rect  --{left=_rect.top, top=_rect.top, right=_rect.right, bottom=_rect.bottom}
  self.text = text
  self.subItems = {}
  self.buttons = {}  
  self.textcolor = WHITE
  self.font = WFXCreateFont(0,7,FW_EXTRABOLD, false, "Arial")
  local y = (rect.bottom/15) - 10
  self.checkbox = CCheckBox(rect.left+10, rect.top+8)
end

function CItem:getButton(itemId)
  --WFXPrint(string.format("%s %d", self.text, #self.buttons))
  for i = 1, #self.buttons do
    local item = self.buttons[i]
    if item.id == itemId then
	  return item
	end	
  end
end

function CItem:getSubItem(itemId)
  --WFXPrint(string.format("%s %d", self.text, #self.buttons))
  for i = 1, #self.subItems do
    local item = self.subItems[i]
    if item.id == itemId then
	  return item
	end	
  end
end

function CItem:drawString(x,y,text)
  myDrawText(self.font, SUB_COLOR, x, y, 20, 10, text)
end

function CItem:setText(_text)
  -- altera o texto do item
  self.text = _text
end

function CItem:setBorderColor(color)
end

function CItem:setTextColor(color)
	self.textcolor = color
end

function CItem:onExecute()
  self.executed = not self.executed
  if self.executed then
    self.checkbox.is_checked = false
	self.color = GREEN
  else
	self.checkbox.is_checked = true
	self.color = RED
  end
  return self.executed
end