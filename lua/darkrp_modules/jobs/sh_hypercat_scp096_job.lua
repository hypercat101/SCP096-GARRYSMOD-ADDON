AddCSLuaFile()

include("autorun/sh_hypercat_scp096_config.lua")
include("autorun/sh_hypercat_scp096_db.lua")
include("autorun/sh_hypercat_scp096_logs.lua")

if SERVER then
    resource.AddWorkshop("1315125663") -- SCP096 Playermodel
end

local function setup(p)
    if !IsValid(p) then return end
    
    p:StripWeapons()
    p:SetModel(HYPERCAT_SCP096.Model)
    p:SetHealth(HYPERCAT_SCP096.Stats.Health)
    p:SetMaxHealth(HYPERCAT_SCP096.Stats.Health)
    p:SetWalkSpeed(HYPERCAT_SCP096.Stats.WalkSpeed)
    p:SetRunSpeed(HYPERCAT_SCP096.Stats.RunSpeed)
    p:SetJumpPower(HYPERCAT_SCP096.Stats.JumpPower)
    
    p:Give(HYPERCAT_SCP096.Weapons.Primary)
end

DarkRP.createCategory{
    name = "SCPs",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 0, 0),
    canSee = function() return true end,
    sortOrder = 100,
}

TEAM_SCP096 = DarkRP.createJob("SCP-096", {
    color = Color(255, 255, 255),
    model = HYPERCAT_SCP096.Model,
    description = [[SCP-096 "The Shy Guy" - A dangerous entity that becomes enraged when viewed. 
    Looking at its face triggers a violent response that cannot be stopped.]],
    weapons = {HYPERCAT_SCP096.Weapons.Primary},
    command = "become096",
    max = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "SCPs",
    customCheck = HYPERCAT_SCP096_IsWhitelisted,
    CustomCheckFailMsg = function() return "You need to be whitelisted to play as SCP-096" end,
    PlayerLoadout = function(p) setup(p) return true end,
})

hook.Add("PlayerSpawn", "SCP096_Setup", function(p)
    if !IsValid(p) or p:Team() != TEAM_SCP096 then return end
    timer.Simple(0.1, function()
        if IsValid(p) then setup(p) end
    end)
end)

hook.Add("OnPlayerChangedTeam", "SCP096_Reset", function(p, old, new)
    if old != TEAM_SCP096 then return end
    
    p:SetWalkSpeed(250)
    p:SetRunSpeed(500)
    p:SetHealth(100)
    p:SetMaxHealth(100)
    p:SetJumpPower(200)
    
    if SERVER then
        p:StopSound(HYPERCAT_SCP096.Sounds.RageLoop)
        for _, s in pairs(HYPERCAT_SCP096.Sounds.Idle) do
            p:StopSound(s)
        end
    end
    
    if SERVER then
        HYPERCAT_SCP096.LOGS.LogAction("job_leave", p:SteamID64())
    end
end)

hook.Add("canDropWeapon", "SCP096_NoDropWeapon", function(p, w)
    if !IsValid(w) then return end
    return w:GetClass() != HYPERCAT_SCP096.Weapons.Primary
end)

hook.Add("PlayerCanPickupWeapon", "SCP096_NoPickup", function(p, w)
    if !IsValid(p) or !IsValid(w) then return end
    if p:Team() != TEAM_SCP096 then return end
    
    local wep = p:GetWeapon(HYPERCAT_SCP096.Weapons.Primary)
    return !IsValid(wep)
end)

hook.Add("KeyPress", "SCP096_NoJump", function(p, k)
    if !IsValid(p) then return end
    if p:Team() != TEAM_SCP096 or k != IN_JUMP then return end
    return !HYPERCAT_SCP096.Stats.CanJump
end)

hook.Add("CanPlayerEnterVehicle", "SCP096_NoVehicles", function(p)
    return !IsValid(p) or p:Team() != TEAM_SCP096
end)

hook.Add("OnPlayerChangedTeam", "SCP096_LogJoin", function(p, old, new)
    if new != TEAM_SCP096 then return end
    if SERVER then
        HYPERCAT_SCP096.LOGS.LogAction("job_join", p:SteamID64())
    end
end)

if SERVER then
    hook.Add("PlayerInitialSpawn", "SCP096_WL_Notify", function(p)
        if !IsValid(p) or !p:IsSuperAdmin() then return end
        timer.Simple(5, function()
            if IsValid(p) then
                p:ChatPrint("type !scp096whitelist add/remove steamid")
            end
        end)
    end)
end 