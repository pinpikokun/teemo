local assets=
{
	Asset("ANIM", "anim/noxious_trap.zip"),
	
	Asset("IMAGE", "images/inventoryimages/noxious_trap.tex"),
	Asset("ATLAS", "images/inventoryimages/noxious_trap.xml"),
}

local function explodeTrap(inst, target)
	-- local pos = Vector3(inst.Transform:GetWorldPosition())

	-- 爆発エフェクト
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
	SpawnPrefab("explode_noxious_trap").Transform:SetPosition(inst.Transform:GetWorldPosition())
	-- ダメージ
	inst.components.explosive_noxious_trap:OnBurnt()

	-- 色んな種類のPrefab
	-- 消えるエフェクト
	-- "small_puff"　-- ドロンって感じの煙
	-- "maxwell_smoke" -- 上から何かが降ってきて着地したような煙
	-- "collapse_small" -- 何かが壊れた時の煙
	-- "collapse_big" -- 大きい何かが壊れた時の煙
	-- "ground_chunks_breaking" -- 何かが壊れた感じの破裂
	-- "splash_ocean"　-- 丸いつぶが飛び散る
	-- "spawn_fx_medium" -- マルチで人が入ってきた時の渦巻きと音
	-- "lightning" --雷
	-- "sanity_lower"　-- 影が上に登って消えていく
	-- "impact" -- 攻撃があたった感じ
	-- "chesterlight" -- 画面がなんとなく明るく
	-- "chester_transform_fx"　-- 爆弾が爆発
	-- "spat_splat_fx" -- 黄色いベチャッとしたやつ
	-- "lightning_rod_fx"　-- 縦に薄い雷みたいなの
	-- "die_fx" -- 茶色い爆発
	-- "mining_fx" -- 石が砕けた感じ
	-- "ghost_transform_overlay_fx" -- 雷＆ハート？
	-- "emote_fx"　-- 手をふるアクションで出てくる点々
	-- "sparks"　-- ロボが雷食らった時のバチバチ
	-- "splash"　-- 砂利みたいなのがボロボロでてくる

	-- 消えないエフェクト
	-- "spawnlight_multiplayer" -- マルチで夜に入った時のマルイ光
	-- "hauntfx"　-- 火の玉
	-- "gridplacer" -- ピックフォークで掘る時の範囲の点線
	-- "warningshadow" -- 震えてる影
	-- "shadowhand" -- 影の手
	-- "lighterfire" -- ライターの炎
	-- "forcefieldfx"　-- 赤いシールド

	-- アイテム
	-- "shadowmeteor" -- 影→隕石が降ってくる
	-- "plant_normal"　-- 野菜の第一段階
	-- "houndstooth" -- 爪
	-- "armorruins"　-- 最後の鎧
	-- "ruins_bat" -- 最後の武器
	-- "ruinshat" -- 最後の帽子
	-- "ash"　-- 灰
	-- "bird_egg" -- 鳥の卵
	-- "humanmeat" -- 白い肉
	
	-- いきもの
	-- "butterfly" -- 蝶
	-- "frog" -- 蛙
	-- "perd" ベリーを食べる鳥
	-- "beefalo" -- ビーファロー
	-- "krampus" -- クランパス
	-- "lureplant"　-- ルアープラント
	-- "abigail"　-- アビゲイル

	-- その他
	-- "maxwelllight" -- 建造物
	-- "maxwell"　-- シングルに出てくる最初のマクスウェル
	-- "bishop_charge_hit"　-- 一つ目の機械が攻撃する時の音
	-- "firework_fx" -- 花火の音
	-- "multifirework_fx" -- 激しい花火の音

	-- "tentacle"
	-- "flower"
	-- "petals"
	-- "world"
	-- "chester"
	-- "pine_needles"
	-- "eyeturret"
	-- "eyeturret_base"
	-- "eye_charge_hit"
	-- "poopcloud"
	-- "explode_small"
	-- "minerhatlight"
	-- "plantmeat"
	-- "rabbit"
	-- "maxwellhead"
	-- "diviningrodstart"
	-- "lanternlight"
	-- "minotaurchest"
	-- "statue_transition_2"
	-- "statue_transition"
	-- "poop"
	-- "ghost"
	-- "sanity_raise"
	-- "rottenegg"
	-- "bird_egg_cooked"
	-- "petals_evil"
	-- "goldnugget"
	-- "evergreen_short"
	-- "spoiled_food"
	-- "skeleton_player"
	-- "player_classified"
	-- "raindrop"
	-- "lavalight"
	-- "shadowtentacle"
	-- "shadowhand_arm"
	-- "burntground"
	-- "meteorwarning"
	-- "slurtleslime"
	-- "teenbird"
	-- "tallbird"
	-- "spiderqueen"
	-- "spiderden"
	-- "stafflight"
	-- "smallbird"
	-- "tentacle_pillar_arm"
	-- "torchfire"
	-- "shadowwaxwell"
	-- "gears"
	-- "sanityrock"
	-- "spider_warrior"
	-- "shovel_dirt"
	-- "brokentool"

end

local function findTarget(inst)
	-- 10分経過したら終了
	inst.elapsed = inst.elapsed + .3
	if inst.elapsed >= 600 then
	    stopSearchTask(inst)
	    inst:Remove()
	    return
	end

	-- 爆発の対象
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2.0)
    for k, v in pairs(ents) do

	    	if v:HasTag("monster") or v:HasTag("character")
	    		or v:HasTag("animal") or v:HasTag("shadowcreature")
	    		or v:HasTag("largecreature") or v:HasTag("smallcreature")
	    		or v:HasTag("insect") then

	    		-- playerは爆発対象外
	    		local nonTarget = "player"
	    		if TheNet:GetPVPEnabled() then
	    			nonTarget = "teemo"
	    		end

		    	if not v:HasTag(nonTarget) and not v:HasTag("companion") then--and v.entity:IsVisible() and not v:HasTag("notraptrigger") then
		    		stopSearchTask(inst)
		    		explodeTrap(inst, v)
		    		-- inst:Remove()
		    		break
		    	end
	    	end

    end
end

function stopSearchTask(inst)
    if inst.searchTask ~= nil then
        inst.searchTask:Cancel()
        inst.searchTask = nil
    end
end

local function startTrap(inst)
	inst.isSetTrap = true
 	inst.elapsed = 0

    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(0.9)
    inst.Light:SetColour(155/255, 225/255, 250/255)
    inst.Light:SetRadius(1.5)

	inst.AnimState:SetMultColour(.4,.4,.4,.4)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/pop")
	inst:RemoveComponent("inventoryitem")

    stopSearchTask(inst)

	inst.searchTask = inst:DoPeriodicTask(.3, findTarget, 2.0)
end

local function onDeploy(inst, pt, deployer)
	startTrap(inst)
	inst.Physics:Teleport(pt:Get())
end

local function onLoad(inst, data)
	if data then
		if data.isSetTrap then
			inst.isSetTrap = data.isSetTrap
			startTrap(inst)
		end
		if data.elapsed then
			inst.elapsed = data.elapsed
		end
	end
end

local function onSave(inst, data)
	data.isSetTrap = inst.isSetTrap
	data.elapsed = inst.elapsed
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("noxious_trap")
	inst.AnimState:SetBuild("noxious_trap")
	inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	inst:AddComponent("inspectable")

	-- インベントリアイテム
	inst:AddComponent("inventoryitem")
	-- インベントリ見た目
	inst.components.inventoryitem.atlasname = "images/inventoryimages/noxious_trap.xml"

	-- トラップ設置
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = onDeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)
    
    -- 爆発ダメージ
	inst:AddComponent("explosive_noxious_trap")

	inst.OnSave = onSave
	inst.OnLoad = onLoad

	-- TODO:爆発するように
	-- MakeHauntableLaunch(inst)

	return inst
end

return Prefab("common/inventory/noxious_trap", fn, assets),
MakePlacer("common/noxious_trap_placer", "noxious_trap", "noxious_trap", 2, false,true,false)