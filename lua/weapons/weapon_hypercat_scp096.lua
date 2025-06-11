AddCSLuaFile()
include("autorun/sh_hypercat_scp096_config.lua")
include("autorun/sh_hypercat_scp096_db.lua")
include("autorun/sh_hypercat_scp096_net.lua")

DEFINE_BASECLASS("weapon_base")

SWEP.PrintName = "SCP-096 (The Shy Guy)"
SWEP.Author = "HyperCat"
SWEP.Contact = "steamcommunity.com/id/hypercat"
SWEP.Purpose = "SCP-096 addon for DarkRP"
SWEP.Instructions = "Left click to attack"
SWEP.Category = "HyperCat's SCPs"

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = true,
    Ammo = "none",
    Delay = 0.5
}

SWEP.Secondary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.HitDist = HYPERCAT_SCP096.Combat.KillRange or 100
SWEP.HitInc = 0.2
SWEP.HitPush = 2000

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}

SWEP.IsSCP096 = true
SWEP.SCPClass = "096"

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Kills")
    self:NetworkVar("Float", 0, "NextIdle")
    self:NetworkVar("Float", 1, "StartTime")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
    self:SetKills(0)
    self:SetNextIdle(0)
    self:SetStartTime(CurTime())
    
    if SERVER then
        timer.Simple(0.2, function()
            if !IsValid(self) or !IsValid(self:GetOwner()) then return end
            
            local p = self:GetOwner()
            p:SetHealth(HYPERCAT_SCP096.Stats.Health)
            p:SetMaxHealth(HYPERCAT_SCP096.Stats.Health)
            p:SetWalkSpeed(HYPERCAT_SCP096.Stats.WalkSpeed)
            p:SetRunSpeed(HYPERCAT_SCP096.Stats.RunSpeed)
            p:SetJumpPower(HYPERCAT_SCP096.Stats.JumpPower or 200)
        end)
    end
end

function SWEP:CanHit(t)
    if !IsValid(t) or !t:IsPlayer() or !t:Alive() then return false end
    if t:GetPos():Distance(self:GetOwner():GetPos()) > self.HitDist then return false end
    if HYPERCAT_SCP096.ImmuneJobs[team.GetName(t:Team())] then return false end
    
    if t:IsProtected() or t:InVehicle() then return false end
    if t:GetMoveType() == MOVETYPE_NOCLIP then return false end
    
    return true
end

function SWEP:PrimaryAttack()
    if !IsValid(self:GetOwner()) then return end
    
    self:SetNextPrimaryFire(CurTime() + HYPERCAT_SCP096.Combat.AttackDelay)
    
    local p = self:GetOwner()
    local tr = p:GetEyeTrace()
    local t = tr.Entity
    
    if self:CanHit(t) then
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:EmitSound(HYPERCAT_SCP096.Sounds.Attack[math.random(#HYPERCAT_SCP096.Sounds.Attack)])
        
        if SERVER then
            if not self:ValidateAttack(t) then return end
            
            local d = DamageInfo()
            d:SetDamage(t:Health() * 2)
            d:SetAttacker(p)
            d:SetInflictor(self)
            d:SetDamageType(DMG_SLASH)
            t:TakeDamageInfo(d)
            
            util.Effect("BloodImpact", EffectData():SetOrigin(t:GetPos() + Vector(0,0,30)))
            p:EmitSound(HYPERCAT_SCP096.Sounds.Hit[math.random(#HYPERCAT_SCP096.Sounds.Hit)])
            
            if !t:Alive() then
                self:SetKills(self:GetKills() + 1)
                HYPERCAT_SCP096.DB.UpdateStats(p:SteamID64(), 1, 0)
                HYPERCAT_SCP096.LOGS.LogAction("scp096_kill", t:SteamID64(), p:SteamID64())
                local stats = HYPERCAT_SCP096.DB.GetStats(p:SteamID64())
                if stats then
                    HYPERCAT_SCP096.NET.SendStatsUpdate(p, stats)
                end
            end
        end
    end
end

function SWEP:ValidateAttack(target)
    local owner = self:GetOwner()
    if not IsValid(owner) or not IsValid(target) then return false end
    
    if self.LastKillTime and CurTime() - self.LastKillTime < 0.1 then
        HYPERCAT_SCP096.LOGS.LogAction("exploit_detected", owner:SteamID64(), nil, "Rapid kills detected")
        return false
    end
    
    local dist = owner:GetPos():Distance(target:GetPos())
    if dist > self.HitDist * 1.1 then
        HYPERCAT_SCP096.LOGS.LogAction("exploit_detected", owner:SteamID64(), nil, "Distance exploit detected")
        return false
    end
    
    self.LastKillTime = CurTime()
    return true
end

function SWEP:SecondaryAttack()
    return false
end

if CLIENT then
    function SWEP:DrawHUD()
        if self:GetKills() > 0 then
            draw.SimpleText("Kills: " .. self:GetKills(), "DermaDefault", ScrW() / 2, ScrH() - 30, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

function SWEP:Think()
    if SERVER and IsValid(self:GetOwner()) then
        if CurTime() > self:GetNextIdle() then
            local s = HYPERCAT_SCP096.Sounds.Idle[math.random(#HYPERCAT_SCP096.Sounds.Idle)]
            self:GetOwner():EmitSound(s, 75, 100, 0.5)
            self:SetNextIdle(CurTime() + math.random(8, 15))
        end
    end
end

function SWEP:OnRemove()
    if SERVER and IsValid(self:GetOwner()) then
        local playTime = CurTime() - self:GetStartTime()
        HYPERCAT_SCP096.DB.UpdateStats(self:GetOwner():SteamID64(), 0, math.floor(playTime))
        
        self:GetOwner():SetWalkSpeed(250)
        self:GetOwner():SetRunSpeed(500)
        for _, s in pairs(HYPERCAT_SCP096.Sounds.Idle) do
            self:GetOwner():StopSound(s)
        end
    end
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()
    self:Remove()
end
