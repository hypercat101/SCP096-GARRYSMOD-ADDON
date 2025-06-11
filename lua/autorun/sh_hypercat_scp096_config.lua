--[[
    SCP-096 Configuration
    Author: Hypercat
    Version: 2.1.0
]]

AddCSLuaFile()

HYPERCAT_SCP096 = HYPERCAT_SCP096 or {}

if SERVER then
    resource.AddWorkshop("1315125663") -- SCP096 Playermodel
end

HYPERCAT_SCP096.Model = "models/player/scp096.mdl"

HYPERCAT_SCP096.Stats = {
    Health = 4000,
    WalkSpeed = 170,
    RunSpeed = 220,
    JumpPower = 200,
    CanJump = true
}

HYPERCAT_SCP096.Combat = {
    KillRange = 100,
    AttackDelay = 0.4,
    DamageMultiplier = 2.0
}

HYPERCAT_SCP096.Weapons = {
    Primary = "weapon_hypercat_scp096"
}

HYPERCAT_SCP096.Sounds = {
    Attack = {
        "npc/zombie/zo_attack1.wav",
        "npc/zombie/zo_attack2.wav"
    },
    Hit = {
        "physics/flesh/flesh_impact_hard1.wav",
        "physics/flesh/flesh_impact_hard2.wav"
    },
    Idle = {
        "npc/zombie/zombie_voice_idle1.wav",
        "npc/zombie/zombie_voice_idle2.wav",
        "npc/zombie/zombie_voice_idle3.wav",
        "npc/zombie/zombie_voice_idle4.wav"
    }
}

HYPERCAT_SCP096.ImmuneJobs = {
    ["SCP-096"] = true,
    ["Site Director"] = true,
    ["MTF Commander"] = true,
    ["O5 Council"] = true
}

HYPERCAT_SCP096.Database = {
    CacheTimeout = 300, 
    LogRetention = 604800 
}

HYPERCAT_SCP096.Colors = {
    Primary = Color(255, 200, 0),
    Secondary = Color(255, 255, 255),
    Error = Color(255, 50, 50)
} 