--!strict

-- Load TimeService module on server start to ensure profile table exists
local TimeService = require(script.Parent:WaitForChild("TimeService"))
-- No-op reference to keep linter happy
if TimeService then
    -- Ready
end


