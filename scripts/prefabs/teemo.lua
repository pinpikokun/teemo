
local MakePlayerCharacter = require ("prefabs/player_common")

local assets = {
    Asset( "ANIM", "anim/teemo.zip" ),
    Asset( "ANIM", "anim/ghost_teemo_build.zip" ),
}
local prefabs = {}

local start_inv = {
    "red_cap",
    "red_cap",
    "red_cap",
    "green_cap",
    "blue_cap",
    "noxious_trap",
    "blind_dart",
    -- "sewing_kit",
--    "chester_eyebone",
--    "goldenaxe",
--	  "ruinshat",
	  -- "footballhat",
	  -- "winterhat",
--	  "flowerhat",
}

local function doCamouflage(inst)

    if not inst.isCamouflage then
        inst.isCamouflage = true
        inst:AddTag("notarget")
        inst.AnimState:SetMultColour(.1,.1,.1,.5)
        inst.DynamicShadow:Enable(false)
    end

    local x,y,z = inst.Transform:GetWorldPosition() 
    local ents = TheSim:FindEntities(x, y, z, 20)
    for k,v in pairs(ents) do
        if v.components.combat and v.components.combat.target == inst then
            v.components.combat:BlankOutAttacks(.5)
        end
    end
end

local function updCamouflagePrm(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.camouflage_p = pos
    inst.camouflage_t = GetTime()
    inst.camouflage_h = inst.components.health.currenthealth
end

local function disableCamouflage(inst)

    updCamouflagePrm(inst)

    if not inst.isCamouflage then return end

    inst.isCamouflage = false
    inst:RemoveTag("notarget")
    inst.AnimState:SetMultColour(1.0,1.0,1.0,1.0)
    inst.DynamicShadow:Enable(true)

    inst.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD - (TUNING.WILSON_ATTACK_PERIOD * 0.4)
    inst:DoTaskInTime(3.0, function(inst)
        inst.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
    end, inst)

end

local function checkCamouflage(inst)

    if inst.components.sanity:GetPercent() < .3 then
        disableCamouflage(inst)
        return
    end

    if inst.components.health.currenthealth < inst.camouflage_h then
        disableCamouflage(inst)
        return
    end

    local pos = Vector3(inst.Transform:GetWorldPosition())
    local running = inst.components.locomotor:WantsToRun()
    if pos == inst.camouflage_p and not running then
        if GetTime() - inst.camouflage_t > 2.0 then doCamouflage(inst) end
    else
        disableCamouflage(inst)
    end
end

local function onAttacked(inst, data)
    disableCamouflage(inst)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.resetMoveQuickTask = inst:DoTaskInTime(5.0, function(inst)
        inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.26
    end, inst)
end

local function stopPassive(inst)
    if inst.camouflageTask ~= nil then
        inst.camouflageTask:Cancel()
        inst.camouflageTask = nil
    end

    if inst.resetMoveQuickTask ~= nil then
        inst.resetMoveQuickTask:Cancel()
        inst.resetMoveQuickTask = nil
    end
end

local function startPassive(inst)
    updCamouflagePrm(inst)
    inst.camouflageTask = inst:DoPeriodicTask(.5, checkCamouflage)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.26
end

local function onDeath(inst, data)
    inst.deathcause = data ~= nil and data.cause or "unknown"
    if inst.deathcause == "file_load" then return end
    stopPassive(inst)
end

local common_postinit = function(inst)
	inst.soundsname = "teemo"
	inst.MiniMapEntity:SetIcon( "teemo.tex" )
    inst:AddTag("teemo")
end

local function doToxicShotEndTask(target)

    if target.toxicShotEndTask ~= nil then
        target.toxicShotEndTask:Cancel()
    end

    target.toxicShotEndTask = target:DoTaskInTime(4.0, function(target)
        if target.toxicShotDamageTask ~= nil then
            target.toxicShotDamageTask:Cancel()
            target.toxicShotDamageTask = nil
        end
    end, target)
end

local function toxicEffect(target)
    -- 毒エフェクト
    local size = 1
    if target:HasTag("smallcreature") then
        size = 0
    elseif target:HasTag("largecreature") then
        size = 2
    end

    local fx = SpawnPrefab("toxic_effect_by_teemo")
    fx.entity:SetParent(target.entity)
    fx.Transform:SetPosition(0, size, 0)
end

local function toxicShot(inst, data)
    local target = data.target

    if target.components.health then
        -- ヘルスが無い場合は何もしない
        if target.components.health.currenthealth <= 0 then
            return
        end

        -- 毒エフェクト
        toxicEffect(target)
        target.components.health:DoDelta(-10, nil, "toxicShot")
    end

    -- toxicShot発動中は効果延長
    if target.toxicShotDamageTask ~= nil then
        doToxicShotEndTask(target)
        return
    end

    if target.components.combat then

        if target.components.health then
            -- if target.toxicShotDamageTask ~= nil then
            --     target.toxicShotDamageTask:Cancel()
            --     target.toxicShotDamageTask = nil
            -- end
            
            -- 毒の効果（1秒毎
            target.toxicShotDamageTask = target:DoPeriodicTask(1.0, function()

                -- ヘルスが無い場合は何もしない
                if target.components.health.currenthealth <= 0 then
                    return
                end

                -- 毒エフェクト
                toxicEffect(target)

                -- ダメージ
                local dmg = 6
                target.components.health:DoDelta(-dmg, nil, "toxicShot")
                -- プレーヤーの場合画面が赤くなるやつ（PVP用)
                if target.HUD then target.HUD.bloodover:Flash() end

            end)
        end

        doToxicShotEndTask(target)
    end
end

-- ACTIONS.GIVE.fn = function(act)
--     if act.target ~= nil and act.target.components.trader ~= nil then
--         act.target.components.trader:AcceptGift(act.doer, act.invobject)
--         return true
--     end
-- end

local master_postinit = function(inst)

	inst.components.health:SetMaxHealth(100)
	inst.components.hunger:SetMax(100)
	inst.components.sanity:SetMax(100)

    startPassive(inst)

--    inst:ListenForEvent("performaction", function() disableCamouflage(inst) end)
    inst:ListenForEvent("buildsuccess", function() disableCamouflage(inst) end)
    inst:ListenForEvent("equipped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("onpickup", function() disableCamouflage(inst) end)
    inst:ListenForEvent("ondropped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneatsomething", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneaten", function() disableCamouflage(inst) end)
    inst:ListenForEvent("working", function() disableCamouflage(inst) end)
    inst:ListenForEvent("onattackother", function() disableCamouflage(inst) end)
    inst:ListenForEvent("attacked", onAttacked)
    inst:ListenForEvent("death", onDeath)
    inst:ListenForEvent("ms_respawnedfromghost", function() startPassive(inst) end)

    -- 攻撃を当てた時のイベント
    inst:ListenForEvent("onhitother", toxicShot)

end

return MakePlayerCharacter("teemo", prefabs, assets, common_postinit, master_postinit, start_inv)
