local assets = 
{
   Asset("ANIM", "anim/blind_effect.zip")
}
local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    -- inst.components.lighttweener:StartTween(nil, 0, .9, 0.9, nil, .2)
    inst:DoTaskInTime(0.1, inst.Remove)
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    -- inst.entity:AddLight()
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("blind_effect")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

    -- inst:AddComponent("lighttweener")
    -- inst.components.lighttweener:StartTween(inst.Light, 3, -.9, -0.9, {-1,-1,-1}, 0)
    -- inst.components.lighttweener:StartTween(nil, 3, .9, 0.9, nil, .2)

    inst.kill_fx = kill_fx

    -- inst:DoTaskInTime(2.5, inst.Remove)

    -- inst:DoTaskInTime(2.5, function(inst)
    --     inst.AnimState:PlayAnimation("close")
    --     inst.components.lighttweener:StartTween(nil, 0, .9, 0.9, nil, .2)
    --     inst:DoTaskInTime(0.1, inst.Remove)
    -- end, inst)

    return inst
end

return Prefab("common/blind_effect", fn, assets)