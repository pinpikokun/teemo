local Explosive_Noxious_Trap = Class(function(self,inst)
    self.inst = inst
    self.explosiveRange = 4
    self.explosiveDamage = 50
    -- self.explosiveTime = 4
end)

local function doEndTask(v)

    if v.noxiousTrapEndTask ~= nil then
        v.noxiousTrapEndTask:Cancel()
    end

    v.noxiousTrapEndTask = v:DoTaskInTime(4.0, function(v)
        if v.components.locomotor ~= nil then
            v.components.locomotor.bonusspeed = 0
        end
        if v.noxiousTrapDamageTask ~= nil then
            v.noxiousTrapDamageTask:Cancel()
            v.noxiousTrapDamageTask = nil
        end
    end, v)
end

local function doSlow(v)
    if v.components.locomotor then
        v.components.locomotor.bonusspeed = v.components.locomotor.runspeed * -0.5
    end
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

function Explosive_Noxious_Trap:OnBurnt()

    local x, y, z = self.inst.Transform:GetWorldPosition()

    local counterList = TheSim:FindEntities(x, y, z, self.explosiveRange*5)
    local counterPlayer = self.inst
        for k, v in pairs(counterList) do
        if v:HasTag("player") then
            counterPlayer = v
        break
        end
    end

    -- playerは爆発対象外
    local nonTarget = "player"
    if TheNet:GetPVPEnabled() then
        nonTarget = "teemo"
    end

    local ents = TheSim:FindEntities(x, y, z, self.explosiveRange)
    for k, v in pairs(ents) do
        -- アイテムは対象外
        local inpocket = v.components.inventoryitem and v.components.inventoryitem:IsHeld()
        if not inpocket then
            if v.components.combat and v ~= self.inst then

                if not v:HasTag(nonTarget) and not v:HasTag("companion") then --and v.entity:IsVisible() and not v:HasTag("notraptrigger") then

                    -- ダメージ
                     -- v.components.combat:GetAttacked(counterPlayer, 1 , nil)
                    -- ダメージモーション
                    v:PushEvent("attacked", {attacker = counterPlayer, damage = self.explosiveDamage, weapon = nil})

                    if v.components.health and v.noxiousTrapDamageTask == nil then

                        -- 毒の効果（1秒毎
                        v.noxiousTrapDamageTask = v:DoPeriodicTask(1.0, function()

                            -- ヘルスが無い場合は何もしない
                            if v.components.health.currenthealth <= 0 then
                                return
                            end

                            -- 毒エフェクト
                            toxicEffect(v)

                            -- ダメージ
                            local dmg = self.explosiveDamage
                            if v:HasTag("smallcreature") then
                                dmg = self.explosiveDamage * 0.75
                            end
                            if v:HasTag("largecreature") then
                                dmg = self.explosiveDamage * 1.75
                            end
                            if v:HasTag("monster") then
                                dmg = self.explosiveDamage * 1.75
                            end
                            if v:HasTag("player") then
                                dmg = self.explosiveDamage * 0.35
                            end

                            v.components.health:DoDelta(-dmg, nil, "noxiousTrap")
                            -- プレーヤーの場合画面が赤くなるやつ（PVP用)
                            if v.HUD then v.HUD.bloodover:Flash() end

                        end)
                    end

                    doSlow(v)
                    doEndTask(v)
                end
            end
        end
    end
    self.inst:Remove()
end

return Explosive_Noxious_Trap