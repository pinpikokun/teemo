local assets =
{
--    Asset("ANIM", "anim/explode_noxious_trap_p.zip"),
    Asset("ANIM", "anim/explode_noxious_trap_g.zip"),
}

local function playExplodeAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end

    inst.Transform:SetFromProxy(proxy.GUID)

    -- ウンコ燃焼を使う
    inst.AnimState:SetBank("poopcloud")
--    inst.AnimState:SetBuild("explode_noxious_trap_"..(math.random()>=.5 and "p" or "g"))
    inst.AnimState:SetBuild("explode_noxious_trap_g")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)

    inst:ListenForEvent("animover", inst.Remove)

end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddNetwork()

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, playExplodeAnim)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetFourFaced()

    inst:AddTag("FX")
    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("common/explode_noxious_trap", fn, assets)