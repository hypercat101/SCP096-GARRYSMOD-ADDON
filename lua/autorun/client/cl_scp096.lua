local targs = {}

net.Receive("scp096_targets", function()
    targs = net.ReadTable()
end)

hook.Add("HUDPaint", "scp096", function()
    if LocalPlayer():Team() != TEAM_SCP096 then return end
    
    for k,v in pairs(targs) do
        if IsValid(v) and v:Alive() then
            local pos = v:GetPos():ToScreen()
            if pos.visible then
                surface.SetDrawColor(255,0,0)
                surface.DrawLine(pos.x-10,pos.y-10,pos.x+10,pos.y+10)
                surface.DrawLine(pos.x+10,pos.y-10,pos.x-10,pos.y+10)
                draw.SimpleText(v:Nick(),"Default",pos.x,pos.y+15,Color(255,0,0),TEXT_ALIGN_CENTER)
            end
        end
    end
end) 