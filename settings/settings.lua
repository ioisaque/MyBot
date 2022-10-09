require 'settings\\inifile'

class 'CSettings'
function CSettings:__init(file_name)
  self.filename = file_name
  if not self:file_exists(self.filename) then
    local file = io.open (self.filename, "w")
	file:write("")
	file:close()
  end
end

function CSettings:enumSections(func)
  local t = inifile.parse(self.filename)
  for section, s in pairs(t) do
    for key, value in pairs(s) do
	  func(section, value)
	end
  end
end

function CSettings:sectionExists(section)
  local t = inifile.parse(self.filename)
  for sec, s in pairs(t) do
    --for key, value in pairs(s) do
	  --WFXPrint(string.format("[%s]: %s", sec, key))
	  if sec == section then
	    return true
      end
	--end
  end
  return false
end

function CSettings:deleteSection(section)
  local t = inifile.parse(self.filename)
  t[tostring(section)] = nil
  inifile.save(self.filename, t)
end

function CSettings:file_exists(file_name)
  local f=io.open(file_name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function CSettings:loadKey(section, key) 	
  local t = inifile.parse(self.filename)
  if t[tostring(section)] then
    if t[tostring(section)][tostring(key)] then
	  return t[tostring(section)][tostring(key)]
	end
  end
end

function CSettings:sectionCount()
  local t = inifile.parse(self.filename)
  local count = 0
  for section, s in pairs(t) do
    count = count + 1
  end
  return count
end

function CSettings:saveKey(section, key, value)
  local t = inifile.parse(self.filename)
  local k = self:loadKey(section,key)
  if k then
    t[tostring(section)][tostring(key)] = value
	inifile.save(self.filename, t)
  else
    local count = self:sectionCount()
	--WFXPrint(string.format("count is: %d, %s %s", count, section, tostring(self:sectionExists(section))))
	if count > 0 then	  
	  if not self:sectionExists(section) then
	    t[tostring(section)] = { }
	  end
	  t[tostring(section)][tostring(key)] = value
	  inifile.save(self.filename, t)	 
	else
	  local file = io.open (self.filename, "w")
	  file:write(string.format("[%s]\n%s=%s", section, key, value))
	  file:close()
	end  
  end 
end