local PenguinCardUtils = {}
PenguinCardUtils.GameState = {Start = 0, Prepare = 1, Dealing = 2, Flip = 3, Settlement = 4, Complete = 5, Quest = 6}
PenguinCardUtils.SuitName = {[(GameEnum.PenguinBaseCardSuit).Blue] = "<sprite name=\"icon_PengCard_Water_small\">", [(GameEnum.PenguinBaseCardSuit).Red] = "<sprite name=\"icon_PengCard_Fire_small\">", [(GameEnum.PenguinBaseCardSuit).Green] = "<sprite name=\"icon_PengCard_Wind_small\">"}
PenguinCardUtils.CheckTriggerAble = function(nTriggerType, tbTriggerParam, nTriggerProbability, mapTriggerSource)
  -- function num : 0_0 , upvalues : _ENV
  local bAble = false
  if nTriggerType == (GameEnum.PenguinCardTriggerType).None then
    bAble = true
  else
    if mapTriggerSource then
      if nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCards and mapTriggerSource.SuitCards then
        local nAimCount = #tbTriggerParam
        local nHasCount = 0
        for _,nAimSuit in ipairs(tbTriggerParam) do
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
          if nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCount and mapTriggerSource.SuitCount then
            for k,nAimCount in pairs(tbTriggerParam) do
              if not (mapTriggerSource.SuitCount)[tonumber(R12_PC54)] or (mapTriggerSource.SuitCount)[tonumber(R12_PC54)] < nAimCount then
                return false
              end
            end
            bAble = true
          else
            if nTriggerType == (GameEnum.PenguinCardTriggerType).HandRankSuitCount and mapTriggerSource.HandRankSuitCount then
              for k,nAimCount in pairs(tbTriggerParam) do
                -- DECOMPILER ERROR at PC85: Overwrote pending register: R12 in 'AssignReg'

                -- DECOMPILER ERROR at PC92: Overwrote pending register: R12 in 'AssignReg'

                if not (mapTriggerSource.HandRankSuitCount)[tonumber(R12_PC54)] or (mapTriggerSource.HandRankSuitCount)[tonumber(R12_PC54)] < nAimCount then
                  return false
                end
              end
              bAble = true
            else
              if (mapTriggerSource.BaseCard).nId ~= tbTriggerParam[1] then
                bAble = nTriggerType ~= (GameEnum.PenguinCardTriggerType).BaseCardId or not mapTriggerSource.BaseCard
                if nTriggerType == (GameEnum.PenguinCardTriggerType).RepeatHandRank and mapTriggerSource.HandRankCount and mapTriggerSource.HandRank then
                  bAble = false
                  for id,count in pairs(mapTriggerSource.HandRankCount) do
                    if mapTriggerSource.HandRank == id and count >= 2 then
                      bAble = true
                      break
                    end
                  end
                elseif nTriggerType == (GameEnum.PenguinCardTriggerType).HandRank and mapTriggerSource.HandRank then
                  for _,v in ipairs(tbTriggerParam) do
                    if mapTriggerSource.HandRank == v then
                      bAble = true
                      break
                    end
                  end
                end
                local randomValue = (math.random)(0, 100)
                do return not bAble or randomValue <= nTriggerProbability end
                -- DECOMPILER ERROR: 8 unprocessed JMP targets
              end
            end
          end
        end
      end
    end
  end
end

PenguinCardUtils.CheckGrowthLayer = function(nGrowthTriggerType, tbGrowthTriggerParam, mapTriggerSource)
  -- function num : 0_1 , upvalues : _ENV
  local nAdd = 0
  if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).None then
    nAdd = 1
  else
    if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).HandRank and mapTriggerSource.HandRank then
      for _,v in ipairs(tbGrowthTriggerParam) do
        if mapTriggerSource.HandRank == v then
          nAdd = 1
          break
        end
      end
    else
      do
        if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).LevelCount and mapTriggerSource.PenguinCardLevel then
          nAdd = mapTriggerSource.PenguinCardLevel
        else
          if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).SuitCountInCard and mapTriggerSource.BaseCard then
            local nAimSuit = tbGrowthTriggerParam[1]
            local mapCfg = (ConfigTable.GetData)("PenguinBaseCard", (mapTriggerSource.BaseCard).nId)
            if mapCfg and nAimSuit == mapCfg.Suit1 then
              nAdd = mapCfg.SuitCount1
            end
          end
        end
        do
          return nAdd
        end
      end
    end
  end
end

PenguinCardUtils.SetEffectDesc = function(mapCfg, nGrowthLayer)
  -- function num : 0_2 , upvalues : _ENV, PenguinCardUtils
  local nTriggerType = mapCfg.TriggerType
  local nEffectType = mapCfg.EffectType
  local nGrowthTriggerType = mapCfg.GrowthTriggerType
  if not nGrowthLayer then
    nGrowthLayer = 0
  end
  local sError = "<color=#BD3059>Error:Parameter mismatch</color>"
  local ParseTriggerParam = function(tbParam, nIndex)
    -- function num : 0_2_0 , upvalues : nTriggerType, _ENV, sError, PenguinCardUtils
    if nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCards then
      local nSuit = tbParam[nIndex]
      if nSuit == nil then
        return sError
      end
      return (PenguinCardUtils.SuitName)[nSuit]
    else
      do
        if nTriggerType == (GameEnum.PenguinCardTriggerType).BaseCardId then
          local nBaseCardId = tbParam[nIndex]
          if nBaseCardId == nil then
            return sError
          end
          local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
          if mapBase then
            return mapBase.Title
          end
        else
          do
            if nTriggerType == (GameEnum.PenguinCardTriggerType).SuitCount or nTriggerType == (GameEnum.PenguinCardTriggerType).HandRankSuitCount then
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
                        sName = sName .. (PenguinCardUtils.SuitName)[nSuit]
                      end
                      return sName
                    end
                    i = i + 1
                    -- DECOMPILER ERROR at PC80: LeaveBlock: unexpected jumping out DO_STMT

                  end
                end
              end
            else
              do
                if nTriggerType == (GameEnum.PenguinCardTriggerType).HandRank then
                  if tbParam[nIndex] == nil then
                    return sError
                  end
                  local mapHandRank = (ConfigTable.GetData)("PenguinCardHandRank", tbParam[nIndex])
                  if mapHandRank then
                    return mapHandRank.Title
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
    -- function num : 0_2_1 , upvalues : nEffectType, _ENV, sError
    if nEffectType == (GameEnum.PenguinCardEffectType).AddBaseCardWeight then
      local tbId = {}
      for k,_ in pairs(tbParam) do
        local nId = tonumber(k)
        if nId then
          (table.insert)(tbId, nId)
        end
      end
      ;
      (table.sort)(tbId, function(a, b)
      -- function num : 0_2_1_0
      do return a < b end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
)
      local nBaseCardId = tbId[nIndex]
      if nBaseCardId == nil then
        return sError
      end
      local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
      if mapBase then
        return mapBase.Title
      end
    else
      do
        if nEffectType == (GameEnum.PenguinCardEffectType).ReplaceBaseCard then
          local nBaseCardId = tbParam[nIndex]
          if nBaseCardId == nil then
            return sError
          end
          local mapBase = (ConfigTable.GetData)("PenguinBaseCard", nBaseCardId)
          if mapBase then
            return mapBase.Title
          end
        else
          do
            if nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips or nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier or nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier or nEffectType == (GameEnum.PenguinCardEffectType).UpgradeDiscount or nEffectType == (GameEnum.PenguinCardEffectType).AddRound or nEffectType == (GameEnum.PenguinCardEffectType).BlockFatalDamage or nEffectType == (GameEnum.PenguinCardEffectType).UpgradeRebate then
              if tbParam[nIndex] == nil then
                return sError
              end
              return (math.abs)(tbParam[nIndex])
            end
          end
        end
      end
    end
  end

  local ParseGrowthTriggerParam = function(tbParam, nIndex)
    -- function num : 0_2_2 , upvalues : nGrowthTriggerType, _ENV, sError, PenguinCardUtils
    if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).SuitCountInCard then
      if tbParam[nIndex] == nil then
        return sError
      end
      return (PenguinCardUtils.SuitName)[tbParam[nIndex]]
    else
      if nGrowthTriggerType == (GameEnum.PenguinCardGrowthTriggerType).HandRank then
        if tbParam[nIndex] == nil then
          return sError
        end
        local mapHandRank = (ConfigTable.GetData)("PenguinCardHandRank", tbParam[nIndex])
        if mapHandRank then
          return mapHandRank.Title
        end
      end
    end
  end

  local ParseTotalEffectParam = function(tbEffectParam, tbGrowthParam, nIndex)
    -- function num : 0_2_3 , upvalues : nEffectType, _ENV, sError, nGrowthLayer
    if nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips or nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier or nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier or nEffectType == (GameEnum.PenguinCardEffectType).UpgradeDiscount or nEffectType == (GameEnum.PenguinCardEffectType).AddRound or nEffectType == (GameEnum.PenguinCardEffectType).UpgradeRebate then
      if tbEffectParam[nIndex] == nil or tbGrowthParam[nIndex] == nil then
        return sError
      end
      local nValue = tbEffectParam[nIndex] + nGrowthLayer * tbGrowthParam[nIndex]
      if nValue < 0 then
        nValue = 0
      end
      return nValue
    end
  end

  local result = (string.gsub)(mapCfg.Desc, "%b{}", function(token)
    -- function num : 0_2_4 , upvalues : _ENV, mapCfg, ParseTriggerParam, ParseEffectParam, ParseGrowthTriggerParam, ParseTotalEffectParam
    local content = (string.match)(token, "^{(.-)}$")
    local sParameterKey, lang, langIdx = ParseLanguageParam(content)
    if lang ~= nil then
      token = (string.format)("{%s}", sParameterKey)
    end
    if token == "{TriggerProbability}" then
      return mapCfg.TriggerProbability
    else
      if token == "{TriggerLimitParam}" then
        return mapCfg.TriggerLimitParam
      else
        if token == "{DurationParam}" then
          return mapCfg.DurationParam
        end
      end
    end
    local trigIdx = (string.match)(token, "^{TriggerParam_(%d+)}$")
    if trigIdx then
      local idx = tonumber(trigIdx)
      local str = ParseTriggerParam(decodeJson(mapCfg.TriggerParam), idx)
      str = LanguagePost(lang, langIdx, str)
      return str
    end
    do
      local effectIdx = (string.match)(token, "^{EffectParam_(%d+)}$")
      if effectIdx then
        local idx = tonumber(effectIdx)
        local str = ParseEffectParam(decodeJson(mapCfg.EffectParam), idx)
        str = LanguagePost(lang, langIdx, str)
        return str
      end
      do
        local trigGrowthIdx = (string.match)(token, "^{GrowthTriggerParam_(%d+)}$")
        if trigGrowthIdx then
          local idx = tonumber(trigGrowthIdx)
          local str = ParseGrowthTriggerParam(decodeJson(mapCfg.GrowthTriggerParam), idx)
          str = LanguagePost(lang, langIdx, str)
          return str
        end
        do
          local effectGrowthIdx = (string.match)(token, "^{GrowthEffectParam_(%d+)}$")
          if effectGrowthIdx then
            local idx = tonumber(effectGrowthIdx)
            local str = ParseEffectParam(decodeJson(mapCfg.GrowthEffectParam), idx)
            str = LanguagePost(lang, langIdx, str)
            return str
          end
          do
            local effectTotalIdx = (string.match)(token, "^{TotalEffectParam_(%d+)}$")
            if effectTotalIdx then
              local idx = tonumber(effectTotalIdx)
              local str = ParseTotalEffectParam(decodeJson(mapCfg.EffectParam), decodeJson(mapCfg.GrowthEffectParam), idx)
              str = LanguagePost(lang, langIdx, str)
              return str
            end
            do
              return token
            end
          end
        end
      end
    end
  end
)
  return result
end

PenguinCardUtils.WeightedRandom = function(tbId, tbWeight, n, tbExcludeGroupId, bDuplicate)
  -- function num : 0_3 , upvalues : _ENV
  if #tbId ~= #tbWeight then
    printError("tbId 和 tbWeight 长度必须相同")
  end
  if not tbExcludeGroupId then
    tbExcludeGroupId = {}
  end
  local tbExcludeSet = {}
  for _,v in ipairs(tbExcludeGroupId) do
    tbExcludeSet[v] = true
  end
  local tbCandidates = {}
  for i = 1, #tbId do
    local id = tbId[i]
    local w = tbWeight[i]
    if next(tbExcludeSet) == nil then
      (table.insert)(tbCandidates, {id = id, weight = w})
    else
      local mapCfg = (ConfigTable.GetData)("PenguinCard", id)
      if mapCfg and not tbExcludeSet[mapCfg.GroupId] then
        (table.insert)(tbCandidates, {id = id, weight = w})
      end
    end
  end
  if #tbCandidates == 0 then
    return {}
  end
  local result = {}
  if bDuplicate then
    local totalWeight = 0
    for _,item in ipairs(tbCandidates) do
      totalWeight = totalWeight + item.weight
    end
    for _ = 1, n do
      local r = (math.random)() * (totalWeight)
      local cum = 0
      for _,item in ipairs(tbCandidates) do
        cum = cum + item.weight
        if r < cum then
          (table.insert)(result, item.id)
          break
        end
      end
    end
  else
    do
      do
        local actualN = (math.min)(n, #tbCandidates)
        for _ = 1, actualN do
          local totalWeight = 0
          for _,item in ipairs(tbCandidates) do
            totalWeight = totalWeight + item.weight
          end
          if totalWeight > 0 then
            local r = (math.random)() * (totalWeight)
            local cum = 0
            for i,item in ipairs(tbCandidates) do
              cum = cum + item.weight
              if r < cum then
                (table.insert)(result, item.id)
                ;
                (table.remove)(tbCandidates, i)
                break
              end
            end
            do
              -- DECOMPILER ERROR at PC148: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC148: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
        return result
      end
    end
  end
end

return PenguinCardUtils

