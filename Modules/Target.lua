-- Modules/Target.lua
local Target = {}

Target.Current = nil

function Target:Set(model)
    self.Current = model
end

function Target:Get()
    return self.Current
end

function Target:Clear()
    self.Current = nil
end

return Target
