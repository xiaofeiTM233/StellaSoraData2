local ConfigData = require("GameCore.Data.ConfigData")
local AttrConfig = require("GameCore.Common.AttrConfig")
local EquipmentData = class("EquipmentData")
EquipmentData.ctor = function(self, mapEquipment, nCharId, nGemId)
  -- function num : 0_0
  self:Clear()
  self:InitEquip(mapEquipment, nCharId, nGemId)
end

EquipmentData.Clear = function(self)
  -- function num : 0_1
  self.nCharId = nil
  self.nGemId = nil
  self.sName = nil
  self.sIcon = nil
  self.sDesc = nil
  self.nType = nil
  self.nGenerateId = nil
  self.nRefreshId = nil
  self.bLock = nil
  self.tbAffix = nil
  self.tbUpgradeCount = nil
  self.tbAlterAffix = nil
  self.tbAlterUpgradeCount = nil
  self.tbPotentialAffix = nil
  self.tbSkillAffix = nil
  self.tbRandomAttr = nil
  self.tbEffect = nil
end

EquipmentData.InitEquip = function(self, mapEquipment, nCharId, nGemId)
  -- function num : 0_2 , upvalues : _ENV
  self.nCharId = nCharId
  self.nGemId = nGemId
  local equipmentCfg = (ConfigTable.GetData)("CharGem", nGemId)
  if equipmentCfg == nil then
    printError((string.format)("获取装备表配置失败！！！id = [%s]", nGemId))
    return 
  end
  self:ParseConfigData(equipmentCfg)
  self:ParseServerData(mapEquipment)
end

EquipmentData.ParseConfigData = function(self, equipmentCfg)
  -- function num : 0_3
  self.sName = equipmentCfg.Title
  self.sIcon = equipmentCfg.Icon
  self.sDesc = equipmentCfg.Desc
  self.nType = equipmentCfg.Type
  self.nGenerateId = equipmentCfg.GenerateCostTid
  self.nRefreshId = equipmentCfg.RefreshCostTid
  self.tbRandomAttr = {}
end

EquipmentData.ParseServerData = function(self, mapEquipment)
  -- function num : 0_4
  self.bLock = mapEquipment.Lock
  self:UpdateAffix(mapEquipment.Attributes, mapEquipment.OverlockCount)
  self:UpdateAlterAffix(mapEquipment.AlterAttributes, mapEquipment.AlterOverlockCount)
end

EquipmentData.UpdateAffix = function(self, tbAttributes, tbCount)
  -- function num : 0_5
  self.tbAffix = tbAttributes
  self.tbUpgradeCount = tbCount
  self:UpdateRandomAttr(self.tbAffix, self.tbUpgradeCount)
end

EquipmentData.UpdateAlterAffix = function(self, tbAttributes, tbCount)
  -- function num : 0_6
  self.tbAlterAffix = tbAttributes
  self.tbAlterUpgradeCount = tbCount
end

EquipmentData.ReplaceRandomAttr = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
    return 
  end
  if not self.tbAlterUpgradeCount or next(self.tbAlterUpgradeCount) == nil then
    return 
  end
  self.tbAffix = clone(self.tbAlterAffix)
  for k,_ in ipairs(self.tbAlterAffix) do
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R6 in 'UnsetPending'

    (self.tbAlterAffix)[k] = 0
  end
  self.tbUpgradeCount = clone(self.tbAlterUpgradeCount)
  for k,_ in ipairs(self.tbAlterUpgradeCount) do
    -- DECOMPILER ERROR at PC39: Confused about usage of register: R6 in 'UnsetPending'

    (self.tbAlterUpgradeCount)[k] = 0
  end
  self:UpdateRandomAttr(self.tbAffix, self.tbUpgradeCount)
end

EquipmentData.UpdateRandomAttr = function(self, mapAttrs, tbCount)
  -- function num : 0_8 , upvalues : _ENV, ConfigData
  self.tbPotentialAffix = {}
  self.tbSkillAffix = {}
  self.tbRandomAttr = {}
  self.tbEffect = {}
  local add = function(mapCfg, nAttrId)
    -- function num : 0_8_0 , upvalues : _ENV, self, ConfigData
    if not mapCfg then
      return 
    end
    if mapCfg.AttrType == (GameEnum.CharGemEffectType).Potential then
      (table.insert)(self.tbPotentialAffix, mapCfg)
    else
      if mapCfg.AttrType == (GameEnum.CharGemEffectType).SkillLevel then
        (table.insert)(self.tbSkillAffix, mapCfg)
      else
        if mapCfg.AttrTypeSecondSubtype == (GameEnum.parameterType).BASE_VALUE then
          if not tonumber(mapCfg.Value) then
            local value = mapCfg.AttrType ~= (GameEnum.effectType).ATTR_FIX and mapCfg.AttrType ~= (GameEnum.effectType).PLAYER_ATTR_FIX or 0
          end
          local mapData = {AttrId = nAttrId, Value = value, CfgValue = value / ConfigData.IntFloatPrecision}
          ;
          (table.insert)(self.tbRandomAttr, mapData)
        else
          do
            ;
            (table.insert)(self.tbEffect, mapCfg.EffectId)
          end
        end
      end
    end
  end

  for k,v in ipairs(mapAttrs) do
    if v > 0 then
      local mapCfg = (ConfigTable.GetData)("CharGemAttrValue", v)
      if mapCfg then
        if tbCount and tbCount[k] > 0 then
          local nId = mapCfg.TypeId * 100 + tbCount[k] + mapCfg.Level
          local mapAfterCfg = (ConfigTable.GetData)("CharGemAttrValue", nId)
          add(mapAfterCfg, nId)
        else
          do
            do
              add(mapCfg, v)
              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
end

EquipmentData.UpdateLockState = function(self, bLock)
  -- function num : 0_9
  self.bLock = bLock
end

EquipmentData.GetEnhancedPotential = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local tbPotential = {}
  for _,v in ipairs(self.tbPotentialAffix) do
    local nPotentialId = (UTILS.GetPotentialId)(self.nCharId, v.AttrTypeFirstSubtype)
    if not tbPotential[nPotentialId] then
      tbPotential[nPotentialId] = 0
    end
    tbPotential[nPotentialId] = tbPotential[nPotentialId] + tonumber(v.Value)
  end
  return tbPotential
end

EquipmentData.GetEnhancedSkill = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local tbSkillId = (PlayerData.Char):GetSkillIds(self.nCharId)
  local tbSkill = {}
  for _,v in ipairs(self.tbSkillAffix) do
    local nSkillId = tbSkillId[v.AttrTypeFirstSubtype]
    if not tbSkill[nSkillId] then
      tbSkill[nSkillId] = 0
    end
    tbSkill[nSkillId] = tbSkill[nSkillId] + tonumber(v.Value)
  end
  return tbSkill
end

EquipmentData.GetRandomAttr = function(self)
  -- function num : 0_12
  return self.tbRandomAttr
end

EquipmentData.GetEffect = function(self)
  -- function num : 0_13
  return self.tbEffect
end

EquipmentData.CheckAlterEmpty = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
    return true
  end
  for _,v in pairs(self.tbAlterAffix) do
    if v == 0 then
      return true
    end
  end
  return false
end

EquipmentData.GetUpgradeCount = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local nAll = 0
  if self.tbUpgradeCount then
    for _,v in ipairs(self.tbUpgradeCount) do
      nAll = nAll + v
    end
  end
  do
    return nAll
  end
end

EquipmentData.ChangeUpgradeCount = function(self, nAttrIndex, nChange)
  -- function num : 0_16
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R3 in 'UnsetPending'

  if (self.tbAlterUpgradeCount)[nAttrIndex] == (self.tbUpgradeCount)[nAttrIndex] and (self.tbAlterAffix)[nAttrIndex] == (self.tbAffix)[nAttrIndex] then
    (self.tbAlterUpgradeCount)[nAttrIndex] = (self.tbAlterUpgradeCount)[nAttrIndex] + nChange
  end
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.tbUpgradeCount)[nAttrIndex] = (self.tbUpgradeCount)[nAttrIndex] + nChange
end

EquipmentData.CheckUpgradeAble = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local nAll = self:GetUpgradeCount()
  local nLimit = (ConfigTable.GetConfigNumber)("CharGemOverlockCount")
  do return nAll < nLimit end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

EquipmentData.CheckUpgradeAlterSame = function(self, nAttrIndex)
  -- function num : 0_18 , upvalues : _ENV
  if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
    return true
  end
  if not self.tbAlterUpgradeCount or next(self.tbAlterUpgradeCount) == nil then
    return true
  end
  if (self.tbAlterAffix)[nAttrIndex] == 0 then
    return true
  end
  if (self.tbAlterUpgradeCount)[nAttrIndex] == (self.tbUpgradeCount)[nAttrIndex] and (self.tbAlterAffix)[nAttrIndex] == (self.tbAffix)[nAttrIndex] then
    return true
  end
  return false
end

EquipmentData.GetTypeDesc = function(self)
  -- function num : 0_19 , upvalues : _ENV
  local sLanguage = ((AllEnum.EquipmentType)[self.nType]).Language
  return (ConfigTable.GetUIText)(sLanguage)
end

EquipmentData.GetTypeIcon = function(self)
  -- function num : 0_20 , upvalues : _ENV
  return ((AllEnum.EquipmentType)[self.nType]).Icon
end

EquipmentData.GetEffectDescId = function(self, attrSybType1, attrSybType2)
  -- function num : 0_21 , upvalues : _ENV
  return (GameEnum.effectType).ATTR_FIX * 10000 + attrSybType1 * 10 + attrSybType2
end

return EquipmentData

