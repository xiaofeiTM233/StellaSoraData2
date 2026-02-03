local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local PenguinCardActData = class("PenguinCardActData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local PenguinLevel = require("Game.UI.Play_PenguinCard.PenguinLevel")
local ClientManager = (CS.ClientManager).Instance
local RapidJson = require("rapidjson")
PenguinCardActData.Init = function(self)
  -- function num : 0_0
  self.mapLevelData = {}
  self.tbLevelList = {}
  self.mapQuestData = {}
  self.tbQuestList = {}
  self.tbQuestGroup = {}
  self.tbSkipNewLevel = {}
  self.tbNewLevel = {}
  self:ParseConfig()
end

PenguinCardActData.ParseConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV, LocalData
  local foreach_questGroupTable = function(data)
    -- function num : 0_1_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if data.ActivityId == self.nActId then
      (self.tbQuestList)[data.Id] = {}
      ;
      (table.insert)(self.tbQuestGroup, data.Id)
    end
  end

  ForEachTableLine(DataTable.ActivityPenguinCardQuestGroup, foreach_questGroupTable)
  ;
  (table.sort)(self.tbQuestGroup, function(a, b)
    -- function num : 0_1_1
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  local foreach_questTable = function(data)
    -- function num : 0_1_2 , upvalues : self, _ENV
    if (self.tbQuestList)[data.Group] ~= nil then
      (table.insert)((self.tbQuestList)[data.Group], data.Id)
    end
  end

  ForEachTableLine(DataTable.ActivityPenguinCardQuest, foreach_questTable)
  for _,v in pairs(self.tbQuestList) do
    (table.sort)(v, function(a, b)
    -- function num : 0_1_3
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  end
  local foreach_levelTable = function(data)
    -- function num : 0_1_4 , upvalues : self, _ENV
    if data.ActivityId == self.nActId then
      (table.insert)(self.tbLevelList, data.Id)
    end
  end

  ForEachTableLine(DataTable.ActivityPenguinCardLevel, foreach_levelTable)
  ;
  (table.sort)(self.tbLevelList, function(a, b)
    -- function num : 0_1_5
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  local sJson = (LocalData.GetPlayerLocalData)("PenguinCardLevel")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.tbSkipNewLevel = tb
  end
end

PenguinCardActData.RefreshPenguinCardActData = function(self, msgData)
  -- function num : 0_2
  self:CacheLevelData(msgData.Levels)
  self:CacheQuestData(msgData.Quests)
end

PenguinCardActData.RefreshQuestData = function(self, questData)
  -- function num : 0_3
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

  (self.mapQuestData)[questData.Id] = self:CreateQuest(questData)
  self:RefreshQuestRedDot(questData.Id)
end

PenguinCardActData.CacheQuestData = function(self, tbQuest)
  -- function num : 0_4 , upvalues : _ENV
  for _,v in ipairs(tbQuest) do
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R7 in 'UnsetPending'

    (self.mapQuestData)[v.Id] = self:CreateQuest(v)
    self:RefreshQuestRedDot(v.Id)
  end
end

PenguinCardActData.CreateQuest = function(self, mapQuestData)
  -- function num : 0_5 , upvalues : _ENV
  local tbQuestData = {}
  tbQuestData.nId = mapQuestData.Id
  if (mapQuestData.Progress)[1] ~= nil then
    tbQuestData.nCur = ((mapQuestData.Progress)[1]).Cur
    tbQuestData.nMax = ((mapQuestData.Progress)[1]).Max
  else
    tbQuestData.nCur = 0
    tbQuestData.nMax = self:GetQuestMaxProgress(mapQuestData.Id)
  end
  if mapQuestData.Status == 0 then
    tbQuestData.nStatus = (AllEnum.ActQuestStatus).UnComplete
  else
    if mapQuestData.Status == 1 then
      tbQuestData.nStatus = (AllEnum.ActQuestStatus).Complete
    else
      if mapQuestData.Status == 2 then
        tbQuestData.nStatus = (AllEnum.ActQuestStatus).Received
      end
    end
  end
  return tbQuestData
end

PenguinCardActData.GetQuestMaxProgress = function(self, nId)
  -- function num : 0_6 , upvalues : _ENV
  local nMax = 0
  local mapCfg = (ConfigTable.GetData)("ActivityPenguinCardQuest", nId)
  if mapCfg then
    if mapCfg.FinishType == (GameEnum.activityQuestCompleteCond).ActivityPenguinCardLevelPassedScore then
      nMax = 1
    else
      if mapCfg.FinishType == (GameEnum.activityQuestCompleteCond).ActivityPenguinCardLevelPassedWithStar then
        local tbParam = decodeJson(mapCfg.FinishParams)
        nMax = tbParam[2]
      end
    end
  end
  do
    return nMax
  end
end

PenguinCardActData.GetQuestGroup = function(self)
  -- function num : 0_7
  return self.tbQuestGroup
end

PenguinCardActData.GetQuestbyGroupId = function(self, nGroupId)
  -- function num : 0_8
  return (self.tbQuestList)[nGroupId]
end

PenguinCardActData.GetQuestData = function(self, nId)
  -- function num : 0_9 , upvalues : _ENV
  if (self.mapQuestData)[nId] then
    return (self.mapQuestData)[nId]
  else
    return {nId = nId, nCur = 0, nMax = self:GetQuestMaxProgress(nId), nStatus = (AllEnum.ActQuestStatus).UnComplete}
  end
end

PenguinCardActData.GetGroupQuestReceiveCount = function(self, nGroupId)
  -- function num : 0_10 , upvalues : _ENV
  local nResult = 0
  if (self.tbQuestList)[nGroupId] == nil then
    return nResult
  end
  for _,nId in pairs((self.tbQuestList)[nGroupId]) do
    if (self.mapQuestData)[nId] and ((self.mapQuestData)[nId]).nStatus == (AllEnum.ActQuestStatus).Received then
      nResult = nResult + 1
    end
  end
  return nResult
end

PenguinCardActData.GetAllQuestCount = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local nResult = 0
  for _,v in pairs(self.tbQuestList) do
    nResult = nResult + #v
  end
  return nResult
end

PenguinCardActData.GetAllReceivedCount = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local nResult = 0
  for nGroupId,_ in pairs(self.tbQuestList) do
    nResult = nResult + self:GetGroupQuestReceiveCount(nGroupId)
  end
  return nResult
end

PenguinCardActData.CacheLevelData = function(self, tbLevel)
  -- function num : 0_13 , upvalues : _ENV
  for _,v in ipairs(tbLevel) do
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R7 in 'UnsetPending'

    (self.mapLevelData)[v.Id] = {nScore = v.Score, nStar = v.Star}
  end
  self:RefreshLevelRedDot()
end

PenguinCardActData.GetLevelList = function(self)
  -- function num : 0_14
  return self.tbLevelList
end

PenguinCardActData.CheckLevelLock = function(self, nLevelId)
  -- function num : 0_15
  local bLock = self:CheckLevelLockByTime(nLevelId)
  if bLock == true then
    return bLock
  end
  bLock = self:CheckLevelLockByPrev(nLevelId)
  return bLock
end

PenguinCardActData.CheckLevelLockByTime = function(self, nLevelId)
  -- function num : 0_16 , upvalues : ClientManager
  local nRemain = self:GetLevelStartTime(nLevelId) - ClientManager.serverTimeStamp
  local bLock = nRemain > 0
  do return bLock, nRemain end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PenguinCardActData.CheckLevelLockByPrev = function(self, nLevelId)
  -- function num : 0_17 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("ActivityPenguinCardLevel", nLevelId)
  if not mapCfg then
    return true
  end
  local nPrev = mapCfg.Prev
  if nPrev == 0 then
    return false
  end
  local mapLevel = (self.mapLevelData)[nPrev]
  if mapLevel and mapLevel.nStar > 0 then
    return false
  end
  return true
end

PenguinCardActData.GetLevelData = function(self, nId)
  -- function num : 0_18
  if not (self.mapLevelData)[nId] then
    return {nScore = 0, nStar = 0}
  end
end

PenguinCardActData.GetLevelStartTime = function(self, nLevelId)
  -- function num : 0_19 , upvalues : _ENV, ClientManager
  local mapCfg = (ConfigTable.GetData)("ActivityPenguinCardLevel", nLevelId)
  if not mapCfg then
    return 0
  end
  local openActDayNextTime = ClientManager:GetNextRefreshTime(self.nOpenTime)
  local nTempDay = 0
  if self.nOpenTime < openActDayNextTime then
    nTempDay = 1
  end
  local nDay = (ClientManager.serverTimeStamp - openActDayNextTime) // 86400 + nTempDay
  if mapCfg.Duration <= nDay then
    return 0
  end
  local openDayNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  return openDayNextTime + (mapCfg.Duration - nDay - 1) * 86400
end

PenguinCardActData.EnterLevel = function(self, nLevelId)
  -- function num : 0_20 , upvalues : _ENV, PenguinLevel
  local mapCfg = (ConfigTable.GetData)("ActivityPenguinCardLevel", nLevelId)
  if not mapCfg then
    return 
  end
  local LevelData = (PenguinLevel.new)()
  LevelData:Init(mapCfg.FloorId, nLevelId, self.nActId, mapCfg.StarScore)
end

PenguinCardActData.RefreshQuestRedDot = function(self, nId)
  -- function num : 0_21 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("ActivityPenguinCardQuest", nId)
  if not mapCfg then
    return 
  end
  local mapQuest = (self.mapQuestData)[nId]
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_PenguinCard_Quest, {mapCfg.Group, nId}, mapQuest.nStatus == (AllEnum.ActQuestStatus).Complete)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PenguinCardActData.RefreshLevelRedDot = function(self)
  -- function num : 0_22 , upvalues : _ENV
  self.tbNewLevel = {}
  for _,nId in ipairs(self.tbLevelList) do
    local bSkip = (table.indexof)(self.tbSkipNewLevel, nId) > 0
    if bSkip then
      (RedDotManager.SetValid)(RedDotDefine.Activity_PenguinCard_Level, {nId}, false)
    else
      local bLock = self:CheckLevelLock(nId)
      local bHasScore = not (self.mapLevelData)[nId] or ((self.mapLevelData)[nId]).nScore > 0
      local bNew = (not bLock and not bHasScore)
      if bNew then
        (table.insert)(self.tbNewLevel, nId)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_PenguinCard_Level, {nId}, bNew)
    end
  end
  -- DECOMPILER ERROR: 8 unprocessed JMP targets
end

PenguinCardActData.SkipLevelRedDot = function(self)
  -- function num : 0_23 , upvalues : _ENV, LocalData, RapidJson
  for _,nId in ipairs(self.tbNewLevel) do
    (RedDotManager.SetValid)(RedDotDefine.Activity_PenguinCard_Level, {nId}, false)
    if (table.indexof)(self.tbSkipNewLevel, nId) == 0 then
      (table.insert)(self.tbSkipNewLevel, nId)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("PenguinCardLevel", (RapidJson.encode)(self.tbSkipNewLevel))
end

PenguinCardActData.SendActivityPenguinCardSettleReq = function(self, nLevelId, nStar, nScore, callback)
  -- function num : 0_24 , upvalues : _ENV
  local msgData = {LevelId = nLevelId, Star = nStar, Score = nScore}
  local successCallback = function(_, mapMainData)
    -- function num : 0_24_0 , upvalues : self, nLevelId, nScore, nStar, _ENV, callback
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R2 in 'UnsetPending'

    if not (self.mapLevelData)[nLevelId] or (self.mapLevelData)[nLevelId] and ((self.mapLevelData)[nLevelId]).nScore < nScore then
      (self.mapLevelData)[nLevelId] = {nScore = nScore, nStar = nStar}
    end
    local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapMainData)
    local tbItem = {}
    for _,v in ipairs(mapReward.tbReward) do
      local item = {Tid = v.id, Qty = v.count, rewardType = (AllEnum.RewardType).First}
      ;
      (table.insert)(tbItem, item)
    end
    ;
    (UTILS.OpenReceiveByDisplayItem)(tbItem, mapMainData, callback)
    self:RefreshLevelRedDot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_penguin_card_level_settle_req, msgData, nil, successCallback)
end

PenguinCardActData.SendActivityPenguinCardQuestReceiveReq = function(self, nQuestId, nGroupId, callback)
  -- function num : 0_25 , upvalues : _ENV
  local msgData = {ActivityId = self.nActId, QuestId = nQuestId, GroupId = nGroupId}
  local max = function(nId)
    -- function num : 0_25_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapQuestData)[nId] and ((self.mapQuestData)[nId]).nStatus == (AllEnum.ActQuestStatus).Complete then
      ((self.mapQuestData)[nId]).nCur = ((self.mapQuestData)[nId]).nMax
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.mapQuestData)[nId]).nStatus = (AllEnum.ActQuestStatus).Received
      self:RefreshQuestRedDot(nId)
    end
  end

  local successCallback = function(_, mapMainData)
    -- function num : 0_25_1 , upvalues : nQuestId, max, self, nGroupId, _ENV, callback
    if nQuestId ~= 0 then
      max(nQuestId)
    else
      local tbQuest = self:GetQuestbyGroupId(nGroupId)
      for _,v in ipairs(tbQuest) do
        max(v)
      end
    end
    do
      ;
      (UTILS.OpenReceiveByChangeInfo)(mapMainData)
      if callback then
        callback(mapMainData)
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_penguin_card_quest_reward_receive_req, msgData, nil, successCallback)
end

return PenguinCardActData

