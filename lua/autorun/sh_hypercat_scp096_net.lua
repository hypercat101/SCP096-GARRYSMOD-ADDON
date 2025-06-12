AddCSLuaFile()

HYPERCAT_SCP096.NET = HYPERCAT_SCP096.NET or {}

if SERVER then
    util.AddNetworkString("HYPERCAT_SCP096_WhitelistUpdate")
    util.AddNetworkString("HYPERCAT_SCP096_AdminAction")
    util.AddNetworkString("HYPERCAT_SCP096_Notification")
end

if SERVER then
    function HYPERCAT_SCP096.NET.BroadcastWhitelistUpdate(steamID, isWhitelisted)
        net.Start("HYPERCAT_SCP096_WhitelistUpdate")
            net.WriteString(steamID)
            net.WriteBool(isWhitelisted)
        net.Broadcast()
    end

    function HYPERCAT_SCP096.NET.SendNotification(message, ply)
    end

    net.Receive("HYPERCAT_SCP096_AdminAction", function(len, ply)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end

        local action = net.ReadString()
        local targetID = net.ReadString()

        if action == "whitelist_add" then
            if HYPERCAT_SCP096.DB.AddToWhitelist(targetID, ply:SteamID64()) then
                HYPERCAT_SCP096.NET.SendNotification("Successfully whitelisted " .. targetID, ply)
                HYPERCAT_SCP096.NET.BroadcastWhitelistUpdate(targetID, true)
            else
                HYPERCAT_SCP096.NET.SendNotification("Failed to whitelist " .. targetID, ply)
            end
        elseif action == "whitelist_remove" then
            if HYPERCAT_SCP096.DB.RemoveFromWhitelist(targetID, ply:SteamID64()) then
                HYPERCAT_SCP096.NET.SendNotification("Successfully removed " .. targetID .. " from whitelist", ply)
                HYPERCAT_SCP096.NET.BroadcastWhitelistUpdate(targetID, false)
            else
                HYPERCAT_SCP096.NET.SendNotification("Failed to remove " .. targetID .. " from whitelist", ply)
            end
        end
    end)
end

if CLIENT then
    net.Receive("HYPERCAT_SCP096_WhitelistUpdate", function()
        local steamID = net.ReadString()
        local isWhitelisted = net.ReadBool()
        
        HYPERCAT_SCP096.LocalWhitelistCache = HYPERCAT_SCP096.LocalWhitelistCache or {}
        HYPERCAT_SCP096.LocalWhitelistCache[steamID] = isWhitelisted
    end)

    net.Receive("HYPERCAT_SCP096_Notification", function()
        local message = net.ReadString()
        chat.AddText(Color(255, 200, 0), "[SCP-096] ", Color(255, 255, 255), message)
    end)

    function HYPERCAT_SCP096.NET.RequestWhitelistAction(action, targetID)
        if not LocalPlayer():IsSuperAdmin() then return end
        
        net.Start("HYPERCAT_SCP096_AdminAction")
            net.WriteString(action)
            net.WriteString(targetID)
        net.SendToServer()
    end
end 