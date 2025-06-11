if !SERVER then return end

include("autorun/sh_hypercat_scp096_config.lua")
include("autorun/sh_hypercat_scp096_db.lua")
include("autorun/sh_hypercat_scp096_logs.lua")
include("autorun/sh_hypercat_scp096_net.lua")

hook.Add("Initialize", "HyperCat_SCP096_Init", function()
    HYPERCAT_SCP096.DB.Initialize()
    HYPERCAT_SCP096.LOGS.Initialize()
    
    print("[SCP-096] Server initialized")
end)

hook.Add("PlayerInitialSpawn", "HyperCat_SCP096_PlayerInit", function(ply)
    if !IsValid(ply) then return end
    
    timer.Simple(5, function()
        if !IsValid(ply) then return end
        
        if HYPERCAT_SCP096.DB.IsWhitelisted(ply:SteamID64()) then
            HYPERCAT_SCP096.NET.BroadcastWhitelistUpdate(ply:SteamID64(), true)
        end
    end)
end)

hook.Add("PlayerDisconnected", "HyperCat_SCP096_PlayerLeave", function(ply)
    if !IsValid(ply) then return end
    
    local weapon = ply:GetWeapon("weapon_hypercat_scp096")
    if IsValid(weapon) then
        HYPERCAT_SCP096.LOGS.LogAction("player_leave", ply:SteamID64())
    end
end) 