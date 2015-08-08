local assets = {  
    Asset("ANIM", "anim/blind_dart.zip"),
	Asset("ANIM", "anim/swap_blind_dart.zip"),

	Asset("IMAGE", "images/inventoryimages/blind_dart.tex"),
	Asset("ATLAS", "images/inventoryimages/blind_dart.xml"),
}

local function onequip(inst, owner)
    -- 手に持っている時の見た目？
    owner.AnimState:OverrideSymbol("swap_object", "swap_blind_dart", "swap_blind_dart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function doBlindEffect(target)
    local size = 1
    if target:HasTag("smallcreature") then
        size = 0
    elseif target:HasTag("largecreature") then
        size = 2
    end

    local fx = SpawnPrefab("blind_effect")
    fx.entity:SetParent(target.entity)
    fx.Transform:SetPosition(0, size, 0)
    target.blindEffect = fx
end

local function doBlindEffectEndTask(target)
    if target.blindEffectEndTask ~= nil then
        target.blindEffectEndTask:Cancel()
    end

    local time = 2.5
    if target.components.health then
        if target.components.health.currenthealth <= 0 then
            time = 0.5
        end
    end

    target.blindEffectEndTask = target:DoTaskInTime(time, function(target)
        if target.blindEffect ~= nil then
            target.blindEffect:Remove()
            target.blindEffect = nil
        end
    end, target)
end

local function doBlind(target)
    if target.components.combat then
        -- -- 標的を見失う
        -- target.components.combat.target = nil
        -- 2.5秒間攻撃できなくする
        target.components.combat:BlankOutAttacks(2.5)
    end
end

local function onattack(inst, atker, target, skipsanity)

    -- ブラインド効果は吹き矢攻撃の場合のみ
    if inst:HasTag("blowdart") then

        if target.blindEffect ~= nil then
            doBlind(target)
            doBlindEffectEndTask(target)
            return
        end

        doBlind(target)
        doBlindEffect(target)
        doBlindEffectEndTask(target)

    end

    -- １回でも攻撃したら使用率回復出来るようにする
    inst.components.trader.enabled = true

end

local function onFinished(inst)

    if inst:HasTag("blowdart") then
        -- 攻撃アクションを吹き矢ではなくする
        inst:RemoveTag("blowdart")
        -- 攻撃時にダーツを飛ばなくする
        inst.components.weapon:SetProjectile(nil)
        -- 射程を殴りに変更
        inst.components.weapon:SetRange(nil, nil)
        -- 攻撃で%を減らなくする
        inst.components.weapon.attackwear = 0
    end

    -- finiteusesの作りがゴミなので使用率リフレッシュ
    local finiteuses = inst.components.finiteuses
    finiteuses.inst:PushEvent("percentusedchange", {percent = finiteuses:GetPercent()})
end

local function shouldAcceptItem(inst, item)
    -- 使用率回復に使用できるのはキノコだけ
    if item.prefab == "red_cap"  or item.prefab == "green_cap" or item.prefab == "blue_cap" then
       return true
    end
    return false
end

local function onGetItem(inst, giver, item)

    -- キノコを追加した場合
    -- if item.prefab == "red_cap"  or item.prefab == "green_cap" or item.prefab == "blue_cap" then

        -- inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/pop")

        -- 吹き矢じゃなかった場合
        if not inst:HasTag("blowdart") then
            -- 攻撃アクションを吹き矢に戻す
            inst:AddTag("blowdart")
            -- 射程を戻す
            inst.components.weapon:SetRange(4, 8)
            -- 攻撃時にダーツを飛ばす
            inst.components.weapon:SetProjectile("blowdart_walrus")
            -- 攻撃で%を減るようにする
            inst.components.weapon.attackwear = 1
        end

        -- キノコによって回復率が異なる
        local finiteuses = inst.components.finiteuses
        if item.prefab == "red_cap" then
            finiteuses.current = finiteuses.current + finiteuses.total * 0.1
        end
        if item.prefab == "green_cap" then
            finiteuses.current = finiteuses.current + finiteuses.total * 0.5
        end
        if item.prefab == "blue_cap" then
            finiteuses.current = finiteuses.current + finiteuses.total * 1.0
        end

        -- 回復した結果100%を超えた
        if finiteuses.current >= finiteuses.total then
           finiteuses.current = finiteuses.total
           -- キノコを追加できない
           inst.components.trader.enabled = false
        end

        -- 使用率を反映
        finiteuses.inst:PushEvent("percentusedchange", {percent = finiteuses:GetPercent()})
    -- end
end

local function onLoad(inst, data)
    if data then
        if data.idTraderEnabled then
            inst.components.trader.enabled = data.idTraderEnabled
        end
    end
end

local function onSave(inst, data)
    data.idTraderEnabled = inst.components.trader.enabled
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    -- RemovePhysicsColliders(inst)

    -- 画像の構成
    inst.AnimState:SetBank("blind_dart")
    -- 実際の画像
    inst.AnimState:SetBuild("blind_dart")
    -- 画像構成の何番目の画像を表示するか
    inst.AnimState:PlayAnimation("idle")

    -- 攻撃の見た目
    inst:AddTag("blowdart")
    -- 攻撃の音に使われてる？
    inst:AddTag("sharp")

    inst.entity:SetPristine()

    -- ホストではない場合はここまで？
    if not TheWorld.ismastersim then
        return inst
    end
	
    -- 武器
    inst:AddComponent("weapon")
    -- ダメージ
    inst.components.weapon:SetDamage(10)
    -- 範囲（攻撃射程、ヒット射程）
    inst.components.weapon:SetRange(4, 8)
    -- 攻撃効果
    inst.components.weapon:SetOnAttack(onattack)
    -- 吹き矢の矢を飛ばす見た目追加
    inst.components.weapon:SetProjectile("blowdart_walrus")


	inst:AddComponent("inspectable")

    -- インベントリ
    inst:AddComponent("inventoryitem")
    -- インベントリの見た目
	inst.components.inventoryitem.atlasname = "images/inventoryimages/blind_dart.xml"
    inst.components.inventoryitem.keepondeath = true

    -- 幽霊の攻撃（ハウント）時の処理？
    -- MakeHauntableLaunchAndPerish(inst)

    -- 装備
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- teemoのみ装備出来る
    if not inst.components.characterspecific then
        inst:AddComponent("characterspecific")
    end
    inst.components.characterspecific:SetOwner("teemo")
    inst.components.characterspecific:SetStorable(true)
    inst.components.characterspecific:SetComment("Captain Teemo on duty!") 

    -- 使用率
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(10)
    inst.components.finiteuses:SetUses(10)
    inst.components.finiteuses:SetOnFinished(onFinished)

    -- 使用率回復
    inst:AddComponent("trader")
    inst.components.trader.onaccept = onGetItem
    inst.components.trader:SetAcceptTest(shouldAcceptItem)
    inst.components.trader.enabled = false

    inst.OnSave = onSave
    inst.OnLoad = onLoad

    return inst
end

return Prefab( "common/inventory/blind_dart", fn, assets)