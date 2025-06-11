AddCSLuaFile()

HYPERCAT_SCP096.LOGS = HYPERCAT_SCP096.LOGS or {}

if SERVER then
    function HYPERCAT_SCP096.LOGS.Log(action, targetID, adminID, details)
        HYPERCAT_SCP096.DB.LogAction(action, targetID, adminID, details)
        
        local logMessage = string.format("[SCP-096] %s - Target: %s Admin: %s Details: %s",
            action,
            targetID or "N/A",
            adminID or "CONSOLE",
            details or ""
        )
        
        -- BLogs Support FULLY TESTED 6/11/2025
        if BLogs and BLogs.Log then
            BLogs.Log({
                module = "SCP096",
                category = "SCP Actions",
                message = logMessage,
                color = Color(255, 200, 0),
                steam64 = adminID
            })
        end
        
        if MLogs and MLogs.Log then
            MLogs.Log("scp096", logMessage, adminID)
        end
        
        if serverguard and serverguard.LogToDiscord then
            serverguard.LogToDiscord(logMessage)
        end
        
        if ulx and ulx.log then
            ulx.log(logMessage)
        end
        
        ServerLog(logMessage .. "\n")
    end
    
    hook.Add("InitPostEntity", "HYPERCAT_SCP096_MLogs", function()
        if MLogs and MLogs.AddModule then
            MLogs.AddModule("scp096", Color(255, 200, 0), "SCP-096")
        end
    end)
    
    hook.Add("InitPostEntity", "HYPERCAT_SCP096_BLogs", function()
        if BLogs and BLogs.RegisterCategory then
            BLogs.RegisterCategory("SCP096", "SCP-096", Color(255, 200, 0))
        end
    end)
    
    local LogTypes = {
        whitelist_add = "Added %s to SCP-096 whitelist",
        whitelist_remove = "Removed %s from SCP-096 whitelist",
        scp096_kill = "SCP-096 (%s) killed %s",
        exploit_detected = "Exploit detected for %s: %s",
        recontain = "SCP-096 (%s) was recontained by %s"
    }
    
    function HYPERCAT_SCP096.LOGS.LogAction(type, ...)
        if not LogTypes[type] then return end
        
        local msg = string.format(LogTypes[type], ...)
        HYPERCAT_SCP096.LOGS.Log(type, select(1, ...), select(2, ...), msg)
    end
end 