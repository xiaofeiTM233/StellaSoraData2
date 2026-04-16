local PenguinCardQuest = class("PenguinCardQuest")
local PenguinCardUtils = require("Game.UI.Play_PenguinCard.PenguinCardUtils")
PenguinCardQuest.ctor = function(self, nId)
  -- function num : 0_0
  self:Clear()
  self:Init(nId)
end

PenguinCardQuest.Clear = function(self)
  -- function num : 0_1
  self.nId = nil
  self.nLevel = nil
  self.nTurnLimit = nil
  self.nBuffGroup = nil
  self.nType = nil
  self.tbParam = nil
  self.sDesc = nil
  self.nTurnCount = nil
  self.nAimCount = nil
  self.nMaxAim = nil
  self.nBuffId = nil
end

PenguinCardQuest.Init = function(self, nId)
  -- function num : 0_2
  self.nId = nId
  self:ParseConfigData(nId)
end

PenguinCardQuest.ParseConfigData = function(self, nId)
  -- function num : 0_3 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("PenguinCardQuest", nId)
  if mapCfg == nil then
    return 
  end
  self.nLevel = mapCfg.Level
  self.nTurnLimit = mapCfg.TurnLimit
  self.nBuffGroup = mapCfg.BuffGroup
  self.nType = mapCfg.Type
  self.tbParam = {}
  for i = 1, 4 do
    (table.insert)(self.tbParam, mapCfg["Param" .. i])
  end
  self.sDesc = self:SetDesc(mapCfg)
  self.nTurnCount = 0
  self.nAimCount = 0
  self.nMaxAim = (self.tbParam)[1]
  self:CreateBuffId()
end

PenguinCardQuest.SetDesc = function(self, mapCfg)
  -- function num : 0_4 , upvalues : _ENV, PenguinCardUtils
  local ParseParam = function(tbParam, nIndex)
    -- function num : 0_4_0 , upvalues : self, _ENV, PenguinCardUtils
    if nIndex == 0 then
      return self.nTurnLimit
    end
    local nParam = tbParam[nIndex]
    if self.nType == (GameEnum.PenguinCardQuestType).SuitCount and nIndex == 2 then
      return (PenguinCardUtils.SuitName)[nParam]
    else
      if self.nType == (GameEnum.PenguinCardQuestType).HandRank and nIndex == 2 then
        local mapHandRankCfg = (ConfigTable.GetData)("PenguinCardHandRank", nParam)
        if mapHandRankCfg then
          return mapHandRankCfg.Title
        end
      end
    end
    do
      return nParam
    end
  end

  local result = (string.gsub)(mapCfg.Desc, "%b{}", function(token)
    -- function num : 0_4_1 , upvalues : _ENV, ParseParam, self
    local content = (string.match)(token, "^{(.-)}$")
    local sParameterKey, lang, langIdx = ParseLanguageParam(content)
    if lang ~= nil then
      token = (string.format)("{%s}", sParameterKey)
    end
    local trigIdx = (string.match)(token, "^{(%d+)}$")
    if trigIdx then
      local idx = tonumber(trigIdx)
      local str = ParseParam(self.tbParam, idx)
      str = LanguagePost(lang, langIdx, str)
      return str
    end
    do
      return token
    end
  end
)
  return result
end

PenguinCardQuest.CreateBuffId = function(self)
  -- function num : 0_5 , upvalues : _ENV, PenguinCardUtils
  local mapCfg = (ConfigTable.GetData)("PenguinCardBuffWeight", self.nBuffGroup)
  if not mapCfg then
    return 
  end
  local tbBuffId = (PenguinCardUtils.WeightedRandom)(mapCfg.BuffList, mapCfg.Weight, 1)
  self.nBuffId = tbBuffId[1]
end

PenguinCardQuest.AddTurnCount = function(self)
  -- function num : 0_6
  self.nTurnCount = self.nTurnCount + 1
end

PenguinCardQuest.AddProgress = function(self, nType, mapData)
  -- function num : 0_7 , upvalues : _ENV
  if nType ~= self.nType then
    return 
  end
  if self.nType == (GameEnum.PenguinCardQuestType).Score then
    self:ChangeAimCount(mapData.nCount)
  else
    if self.nType == (GameEnum.PenguinCardQuestType).HandRank then
      local nAimId = (self.tbParam)[2]
      if mapData.nId == nAimId then
        self:ChangeAimCount(mapData.nCount)
      end
    else
      do
        if self.nType == (GameEnum.PenguinCardQuestType).SuitCount then
          local nAimId = (self.tbParam)[2]
          if mapData.nId == nAimId then
            self:ChangeAimCount(mapData.nCount)
          end
        end
      end
    end
  end
end

PenguinCardQuest.ChangeAimCount = function(self, nChange)
  -- function num : 0_8 , upvalues : _ENV
  local nBefore = self.nAimCount
  self.nAimCount = self.nAimCount + nChange
  if (NovaAPI.IsEditorPlatform)() and nBefore ~= self.nAimCount then
    printLog("任务进度变化：" .. "  " .. self.nAimCount .. "/" .. self.nMaxAim)
  end
  ;
  (EventManager.Hit)("PenguinCard_ChangeQuestProcess", nChange)
end

PenguinCardQuest.CheckExpired = function(self)
  -- function num : 0_9
  do return self.nTurnLimit <= self.nTurnCount end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PenguinCardQuest.CheckComplete = function(self)
  -- function num : 0_10
  do return self.nMaxAim <= self.nAimCount end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

return PenguinCardQuest

