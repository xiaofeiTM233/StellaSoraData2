local PenguinCard = class("PenguinCard")
local PenguinCardUtils = require("Game.UI.Play_PenguinCard.PenguinCardUtils")
PenguinCard.ctor = function(self, nId)
  -- function num : 0_0
  self:Clear()
  self:Init(nId)
end

PenguinCard.Upgrade = function(self, nAddLevel)
  -- function num : 0_1 , upvalues : _ENV
  local nAfter = self.nLevel + nAddLevel
  if self.nMaxLevel >= nAfter or not self.nMaxLevel then
    local nId = self:GetIdByLevel(self.nGroupId, nAfter)
    local nCacheGrowthLayer = 0
    if self.nGrowthType ~= (GameEnum.PenguinCardGrowthType).None and not self.bUpgradeResetGrowth then
      nCacheGrowthLayer = self.nGrowthLayer
    end
    self:Clear()
    self:Init(nId, nCacheGrowthLayer)
  end
end

PenguinCard.Clear = function(self)
  -- function num : 0_2
  self.nId = nil
  self.nSlotIndex = nil
  self.nGroupId = nil
  self.sName = nil
  self.sIcon = nil
  self.nRarity = nil
  self.nLevel = nil
  self.nMaxLevel = nil
  self.nSoldPrice = nil
  self.nTriggerPhase = nil
  self.nTriggerType = nil
  self.tbTriggerParam = nil
  self.nTriggerProbability = nil
  self.nTriggerLimit = nil
  self.nTriggerLimitParam = nil
  self.nEffectType = nil
  self.tbEffectParam = nil
  self.nGrowthType = nil
  self.bUpgradeResetGrowth = nil
  self.nGrowthTriggerPhase = nil
  self.nGrowthTriggerType = nil
  self.tbGrowthTriggerParam = nil
  self.tbGrowthEffectParam = nil
  self.nTriggerCount = nil
  self.nGrowthLayer = nil
end

PenguinCard.Init = function(self, nId, nGrowthLayer)
  -- function num : 0_3
  self.nId = nId
  self.nGrowthLayer = nGrowthLayer or 0
  self:ParseConfigData(nId)
end

PenguinCard.ParseConfigData = function(self, nId)
  -- function num : 0_4 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("PenguinCard", nId)
  if mapCfg == nil then
    return 
  end
  self.nGroupId = mapCfg.GroupId
  self.sName = mapCfg.Title
  self.sIcon = mapCfg.Icon
  self.nRarity = mapCfg.Rarity
  self.nLevel = mapCfg.Level
  self.nMaxLevel = mapCfg.MaxLevel
  self.nSoldPrice = mapCfg.SoldPrice
  self.nTriggerPhase = mapCfg.TriggerPhase
  self.nTriggerType = mapCfg.TriggerType
  self.tbTriggerParam = decodeJson(mapCfg.TriggerParam)
  self.nTriggerProbability = mapCfg.TriggerProbability
  self.nTriggerLimit = mapCfg.TriggerLimit
  self.nTriggerLimitParam = mapCfg.TriggerLimitParam
  self.nEffectType = mapCfg.EffectType
  self.tbEffectParam = decodeJson(mapCfg.EffectParam)
  self.nGrowthType = mapCfg.GrowthType
  self.bUpgradeResetGrowth = mapCfg.UpgradeResetGrowth
  self.nGrowthTriggerPhase = mapCfg.GrowthTriggerPhase
  self.nGrowthTriggerType = mapCfg.GrowthTriggerType
  self.tbGrowthTriggerParam = decodeJson(mapCfg.GrowthTriggerParam)
  self.tbGrowthEffectParam = decodeJson(mapCfg.GrowthEffectParam)
end

PenguinCard.SetSlotIndex = function(self, nSlotIndex)
  -- function num : 0_5
  self.nSlotIndex = nSlotIndex
end

PenguinCard.GetDesc = function(self)
  -- function num : 0_6 , upvalues : _ENV, PenguinCardUtils
  local mapCfg = (ConfigTable.GetData)("PenguinCard", self.nId)
  if mapCfg == nil then
    return ""
  end
  return (PenguinCardUtils.SetEffectDesc)(mapCfg, self.nGrowthLayer)
end

PenguinCard.ResetAllTrigger = function(self)
  -- function num : 0_7
  self:ResetGameTrigger()
  self:ResetRoundTrigger()
  self:ResetTurnTrigger()
end

PenguinCard.ResetGameTrigger = function(self)
  -- function num : 0_8 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Game then
    self.nTriggerCount = 0
  end
end

PenguinCard.ResetRoundTrigger = function(self)
  -- function num : 0_9 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Round then
    self.nTriggerCount = 0
  end
end

PenguinCard.ResetTurnTrigger = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Turn then
    self.nTriggerCount = 0
  end
  if self.nGrowthType == (GameEnum.PenguinCardGrowthType).CurTurn then
    self.nGrowthLayer = 0
  end
end

PenguinCard.Trigger = function(self, nTriggerPhase, mapTriggerSource, callback)
  -- function num : 0_11 , upvalues : _ENV, PenguinCardUtils
  if self.nTriggerLimit ~= (GameEnum.PenguinCardTriggerLimit).None and self.nTriggerLimitParam <= self.nTriggerCount then
    return 
  end
  if nTriggerPhase ~= self.nTriggerPhase then
    return 
  end
  local bAble = (PenguinCardUtils.CheckTriggerAble)(self.nTriggerType, self.tbTriggerParam, self.nTriggerProbability, mapTriggerSource)
  if not bAble then
    return 
  end
  local mapEffectValue = nil
  if self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips or self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier or self.nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier or self.nEffectType == (GameEnum.PenguinCardEffectType).UpgradeDiscount or self.nEffectType == (GameEnum.PenguinCardEffectType).AddRound or self.nEffectType == (GameEnum.PenguinCardEffectType).UpgradeRebate then
    if self.nGrowthType == (GameEnum.PenguinCardGrowthType).None then
      mapEffectValue = (self.tbEffectParam)[1]
    else
      mapEffectValue = (self.tbEffectParam)[1] + self.nGrowthLayer * (self.tbGrowthEffectParam)[1]
      if mapEffectValue < 0 then
        mapEffectValue = 0
      end
    end
  else
    mapEffectValue = self.tbEffectParam
  end
  if type(mapEffectValue) == "number" and mapEffectValue == 0 then
    return 
  end
  if self.nTriggerLimit ~= (GameEnum.PenguinCardTriggerLimit).None then
    self.nTriggerCount = self.nTriggerCount + 1
  end
  if callback then
    if (NovaAPI.IsEditorPlatform)() then
      printLog("企鹅牌触发：" .. "  " .. self.sName .. "  " .. self:GetDesc())
    end
    callback(self.nEffectType, mapEffectValue)
  end
  ;
  (EventManager.Hit)("PenguinCardTriggered", self.nSlotIndex)
end

PenguinCard.Growth = function(self, nTriggerPhase, mapTriggerSource)
  -- function num : 0_12 , upvalues : _ENV, PenguinCardUtils
  if self.nGrowthType == (GameEnum.PenguinCardGrowthType).None then
    return 
  end
  if nTriggerPhase ~= self.nGrowthTriggerPhase then
    return 
  end
  local nAdd = (PenguinCardUtils.CheckGrowthLayer)(self.nGrowthTriggerType, self.tbGrowthTriggerParam, mapTriggerSource)
  if nAdd == 0 then
    return 
  end
  if self.nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).LevelCount then
    self.nGrowthLayer = nAdd
  else
    self.nGrowthLayer = self.nGrowthLayer + nAdd
  end
  ;
  (EventManager.Hit)("PenguinCardGrowth", self.nSlotIndex)
end

PenguinCard.GetIdByLevel = function(self, nGroupId, nLevel)
  -- function num : 0_13
  return nGroupId * 100 + nLevel
end

return PenguinCard

