
function myDrawText(font, color, x, y, h, w, text)
  local rect = {left=x, top=y, right=w, bottom=h}
  WFXDrawText(font, rect.left,rect.top, rect.right, rect.bottom, color,	text)
end

-- color
END_INFO_COLOR = ICE
ITEM_COLOR = WHITE
SUB_COLOR = WHITE
NOT_COLOR = ICE