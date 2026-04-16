local PenguinCardBuff = class("PenguinCardBuff")
local PenguinCardUtils = require("Game.UI.Play_PenguinCard.PenguinCardUtils")
PenguinCardBuff.ctor = function(self, nId)
  -- function num : 0_0
  self:Clear()
  self:Init(nId)
end

PenguinCardBuff.Clear = function(self)
  -- function num : 0_1
  self.nId = nil
  self.bOnly = nil
  self.sName = nil
  self.sIcon = nil
  self.nTriggerPhase = nil
  self.nTriggerType = nil
  self.tbTriggerParam = nil
  self.nTriggerProbability = nil
  self.nTriggerLimit = nil
  self.nTriggerLimitParam = nil
  self.nEffectType = nil
  self.tbEffectParam = nil
  self.tbGrowthEffectParam = nil
  self.nDurationType = nil
  self.nDurationParam = nil
  self.nTriggerCount = nil
  self.nDurationCount = nil
  self.nGrowthLayer = nil
end

PenguinCardBuff.Init = function(self, nId)
  -- function num : 0_2
  self.nId = nId
  self:ParseConfigData(nId)
end

PenguinCardBuff.ParseConfigData = function(self, nId)
  -- function num : 0_3 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("PenguinCardBuff", nId)
  if mapCfg == nil then
    return 
  end
  self.bOnly = mapCfg.ForcedReplacement or mapCfg.Duration ~= (GameEnum.PenguinCardBuffDuration).FullGame
  self.sName = mapCfg.Title
  self.sIcon = mapCfg.Icon
  self.nTriggerPhase = mapCfg.TriggerPhase
  self.nTriggerType = mapCfg.TriggerType
  self.tbTriggerParam = decodeJson(mapCfg.TriggerParam)
  self.nTriggerProbability = mapCfg.TriggerProbability
  self.nTriggerLimit = mapCfg.TriggerLimit
  self.nTriggerLimitParam = mapCfg.TriggerLimitParam
  self.nEffectType = mapCfg.EffectType
  self.tbEffectParam = decodeJson(mapCfg.EffectParam)
  self.tbGrowthEffectParam = decodeJson(mapCfg.GrowthEffectParam)
  self.nDurationType = mapCfg.Duration
  self.nDurationParam = mapCfg.DurationParam
  self.nDurationCount = 0
  self.nGrowthLayer = 0
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PenguinCardBuff.GetDesc = function(self)
  -- function num : 0_4 , upvalues : _ENV, PenguinCardUtils
  local mapCfg = (ConfigTable.GetData)("PenguinCardBuff", self.nId)
  if mapCfg == nil then
    return ""
  end
  return (PenguinCardUtils.SetEffectDesc)(mapCfg, self.nGrowthLayer)
end

PenguinCardBuff.GetDelayTime = function(self)
  -- function num : 0_5 , upvalues : _ENV
  if self.nEffectType == (GameEnum.PenguinCardEffectType).BlockFatalDamage then
    return 0.7
  end
  return 0
end

PenguinCardBuff.AddDuration_Count = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if self.nDurationType == (GameEnum.PenguinCardBuffDuration).Count then
    self.nDurationCount = self.nDurationCount + 1
    if self.nDurationParam <= self.nDurationCount then
      return false
    end
  end
  return true
end

PenguinCardBuff.AddDuration_Turn = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if self.nDurationType == (GameEnum.PenguinCardBuffDuration).Turn then
    self.nDurationCount = self.nDurationCount + 1
    if self.nDurationParam <= self.nDurationCount then
      return false
    end
  end
  return true
end

PenguinCardBuff.AddGrowthLayer = function(self)
  -- function num : 0_8
  self.nGrowthLayer = self.nGrowthLayer + 1
end

PenguinCardBuff.ResetAllTrigger = function(self)
  -- function num : 0_9
  self:ResetGameTrigger()
  self:ResetRoundTrigger()
  self:ResetTurnTrigger()
end

PenguinCardBuff.ResetGameTrigger = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Game then
    self.nTriggerCount = 0
  end
end

PenguinCardBuff.ResetRoundTrigger = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Round then
    self.nTriggerCount = 0
  end
end

PenguinCardBuff.ResetTurnTrigger = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Turn then
    self.nTriggerCount = 0
  end
end

PenguinCardBuff.Trigger = function(self, nTriggerPhase, mapTriggerSource, callback)
  -- function num : 0_13 , upvalues : _ENV, PenguinCardUtils
  if self.nTriggerLimit ~= (GameEnum.PenguinCardTriggerLimit).None and self.nTriggerLimitParam <= self.nTriggerCount then
    return false
  end
  if nTriggerPhase ~= self.nTriggerPhase then
    return false
  end
  local bAble = (PenguinCardUtils.CheckTriggerAble)(self.nTriggerType, self.tbTriggerParam, self.nTriggerProbability, mapTriggerSource)
  if not bAble then
    return false
  end
  local mapEffectValue = nil
  if self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips or self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier or self.nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier or self.nEffectType == (GameEnum.PenguinCardEffectType).UpgradeDiscount or self.nEffectType == (GameEnum.PenguinCardEffectType).AddRound or self.nEffectType == (GameEnum.PenguinCardEffectType).UpgradeRebate then
    if self.bOnly == true then
      mapEffectValue = (self.tbEffectParam)[1]
    else
      mapEffectValue = (self.tbEffectParam)[1] + self.nGrowthLayer * (self.tbGrowthEffectParam)[1]
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
      printLog("任务奖励触发：" .. "  " .. self.sName .. "  " .. self:GetDesc())
    end
    callback(self.nEffectType, mapEffectValue)
  end
  ;
  (EventManager.Hit)("PenguinCardBuffTriggered", self.nId)
  return true
end

return PenguinCardBuff

