local PenguinCard = class("PenguinCard")
local SuitName = {[(GameEnum.PenguinBaseCardSuit).Blue] = "<sprite name=\"icon_PengCard_Water_small\">", [(GameEnum.PenguinBaseCardSuit).Red] = "<sprite name=\"icon_PengCard_Fire_small\">", [(GameEnum.PenguinBaseCardSuit).Green] = "<sprite name=\"icon_PengCard_Wind_small\">"}
PenguinCard.ctor = function(self, nId)
  -- function num : 0_0
  self:Clear()
  self:Init(nId)
end

PenguinCard.Upgrade = function(self, nAddLevel)
  -- function num : 0_1
  local nAfter = self.nLevel + nAddLevel
  if self.nMaxLevel >= nAfter or not self.nMaxLevel then
    local nId = self:GetIdByLevel(self.nGroupId, nAfter)
    self:Clear()
    self:Init(nId)
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
  self.sDesc = nil
  self.nTriggerCount = nil
end

PenguinCard.Init = function(self, nId)
  -- function num : 0_3
  self.nId = nId
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
  self.sDesc = self:SetDesc(mapCfg)
end

PenguinCard.SetSlotIndex = function(self, nSlotIndex)
  -- function num : 0_5
  self.nSlotIndex = nSlotIndex
end

PenguinCard.SetDesc = function(self, mapCfg)
  -- function num : 0_6 , upvalues : _ENV, SuitName
  local ParseTriggerParam = function(tbParam, nIndex)
    -- function num : 0_6_0 , upvalues : self, _ENV, SuitName
    if self.nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCards then
      local nSuit = tbParam[nIndex]
      return SuitName[nSuit]
    else
      do
        if self.nTriggerType == (GameEnum.PenguinCardTriggerType).BaseCardId then
          local nBaseCardId = tbParam[nIndex]
          local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
          if mapBase then
            return mapBase.Title
          end
        else
          do
            if self.nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCount or self.nTriggerType == (GameEnum.PenguinCardTriggerType).HandRankSuitCount then
              local mapSuit = {}
              for k,v in pairs(tbParam) do
                local nSuit = tonumber(k)
                if nSuit then
                  mapSuit[nSuit] = v
                end
              end
              local i = 1
              for nSuit,v in ipairsSorted(mapSuit) do
                do
                  do
                    if i == nIndex then
                      local sName = ""
                      for _ = 1, v do
                        sName = sName .. SuitName[nSuit]
                      end
                      return sName
                    end
                    i = i + 1
                    -- DECOMPILER ERROR at PC70: LeaveBlock: unexpected jumping out DO_STMT

                  end
                end
              end
            end
          end
        end
      end
    end
  end

  local ParseEffectParam = function(tbParam, nIndex)
    -- function num : 0_6_1 , upvalues : self, _ENV
    if self.nEffectType == (GameEnum.PenguinCardEffectType).AddBaseCardWeight then
      local tbId = {}
      for k,_ in pairs(tbParam) do
        local nId = tonumber(k)
        if nId then
          (table.insert)(tbId, nId)
        end
      end
      ;
      (table.sort)(tbId, function(a, b)
      -- function num : 0_6_1_0
      do return a < b end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
)
      local nBaseCardId = tbId[nIndex]
      local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
      if mapBase then
        return mapBase.Title
      end
    else
      do
        if self.nEffectType == (GameEnum.PenguinCardEffectType).ReplaceBaseCard then
          local nBaseCardId = tbParam[nIndex]
          local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
          if mapBase then
            return mapBase.Title
          end
        else
          do
            if self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips or self.nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier or self.nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier then
              return tbParam[nIndex]
            end
          end
        end
      end
    end
  end

  local result = (string.gsub)(mapCfg.Desc, "%b{}", function(token)
    -- function num : 0_6_2 , upvalues : mapCfg, _ENV, ParseTriggerParam, ParseEffectParam
    if token == "{TriggerProbability}" then
      return mapCfg.TriggerProbability
    else
      if token == "{TriggerLimitParam}" then
        return mapCfg.TriggerLimitParam
      end
    end
    local trigIdx = (string.match)(token, "^{TriggerParam_(%d+)}$")
    do
      if trigIdx then
        local idx = tonumber(trigIdx)
        return ParseTriggerParam(decodeJson(mapCfg.TriggerParam), idx)
      end
      local effectIdx = (string.match)(token, "^{EffectParam_(%d+)}$")
      do
        if effectIdx then
          local idx = tonumber(effectIdx)
          return ParseEffectParam(decodeJson(mapCfg.EffectParam), idx)
        end
        return token
      end
    end
  end
)
  return result
end

PenguinCard.ResetGameTrigger = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Game then
    self.nTriggerCount = 0
  end
end

PenguinCard.ResetRoundTrigger = function(self)
  -- function num : 0_8 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Round then
    self.nTriggerCount = 0
  end
end

PenguinCard.ResetTurnTrigger = function(self)
  -- function num : 0_9 , upvalues : _ENV
  if self.nTriggerLimit == (GameEnum.PenguinCardTriggerLimit).Turn then
    self.nTriggerCount = 0
  end
end

PenguinCard.Trigger = function(self, nTriggerPhase, mapTriggerSource, callback)
  -- function num : 0_10 , upvalues : _ENV
  if self.nTriggerLimit ~= (GameEnum.PenguinCardTriggerLimit).None and self.nTriggerLimitParam <= self.nTriggerCount then
    return 
  end
  if nTriggerPhase ~= self.nTriggerPhase then
    return 
  end
  local bAble = self:CheckTriggerAble(mapTriggerSource)
  if not bAble then
    return 
  end
  if self.nTriggerLimit ~= (GameEnum.PenguinCardTriggerLimit).None then
    self.nTriggerCount = self.nTriggerCount + 1
  end
  if callback then
    if (NovaAPI.IsEditorPlatform)() then
      printLog("企鹅牌触发：" .. "  " .. self.sName .. "  " .. self.sDesc)
    end
    callback(self.nEffectType, self.tbEffectParam)
  end
  ;
  (EventManager.Hit)("PenguinCardTriggered", self.nSlotIndex)
end

PenguinCard.CheckTriggerAble = function(self, mapTriggerSource)
  -- function num : 0_11 , upvalues : _ENV
  local bAble = false
  if self.nTriggerType == (GameEnum.PenguinCardTriggerType).None then
    bAble = true
  else
    if mapTriggerSource then
      if self.nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCards and mapTriggerSource.SuitCards then
        local nAimCount = #self.tbTriggerParam
        local nHasCount = 0
        for _,nAimSuit in ipairs(self.tbTriggerParam) do
          for _,nHasSuit in ipairs(mapTriggerSource.SuitCards) do
            if nAimSuit == nHasSuit then
              nHasCount = nHasCount + 1
            end
          end
        end
        if nAimCount <= nHasCount then
          bAble = true
        end
      else
        do
          if self.nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCount and mapTriggerSource.SuitCount then
            for k,nAimCount in pairs(self.tbTriggerParam) do
              if not (mapTriggerSource.SuitCount)[tonumber(R10_PC58)] or (mapTriggerSource.SuitCount)[tonumber(R10_PC58)] < nAimCount then
                return false
              end
            end
            bAble = true
          else
            if self.nTriggerType == (GameEnum.PenguinCardTriggerType).HandRankSuitCount and mapTriggerSource.HandRankSuitCount then
              for k,nAimCount in pairs(self.tbTriggerParam) do
                -- DECOMPILER ERROR at PC90: Overwrote pending register: R10 in 'AssignReg'

                -- DECOMPILER ERROR at PC97: Overwrote pending register: R10 in 'AssignReg'

                if not (mapTriggerSource.HandRankSuitCount)[tonumber(R10_PC58)] or (mapTriggerSource.HandRankSuitCount)[tonumber(R10_PC58)] < nAimCount then
                  return false
                end
              end
              bAble = true
            else
              -- DECOMPILER ERROR at PC123: Unhandled construct in 'MakeBoolean' P1

              if mapTriggerSource.BaseCard and (mapTriggerSource.BaseCard).nId ~= (self.tbTriggerParam)[1] then
                bAble = self.nTriggerType ~= (GameEnum.PenguinCardTriggerType).BaseCardId
                local randomValue = (math.random)(0, 100)
                do return not bAble or randomValue <= self.nTriggerProbability end
                -- DECOMPILER ERROR: 4 unprocessed JMP targets
              end
            end
          end
        end
      end
    end
  end
end

PenguinCard.GetIdByLevel = function(self, nGroupId, nLevel)
  -- function num : 0_12
  return nGroupId * 100 + nLevel
end

return PenguinCard

