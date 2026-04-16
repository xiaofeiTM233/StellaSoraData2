local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local TrekkerVersusData = class("TrekkerVersusData", ActivityDataBase)
TrekkerVersusData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nActId = 0
  self.nRecord = 0
  self.nLastBuildId = 0
  self.tbRecordAffix = {}
  self.tbRecordChar = {}
  self.nRecordBuildLevel = 0
  self.nCachedBuildId = 0
  self.mapQuests = {}
  self.CachedAffixes = {}
  self.bFirstIn = true
  self.nSuccessBattle = 0
  self.nLastBattleHard = 0
  self.nTimerIdleRefresh = 0
  self.bFirstBattlePlayed = false
  ;
  (EventManager.Add)("TrekkerVersusReceiveHeatQuest", self, self.RequestReceiveScheduleReward)
  ;
  (EventManager.Add)("TrekkerVersusFanGiftDataRefresh", self, self.OnEvent_TrekkerVersusFanGiftDataRefresh)
end

TrekkerVersusData.GetActivityData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  return {nActId = self.nActId, tbRecordAffix = clone(self.tbRecordAffix), tbRecordChar = clone(self.tbRecordChar), nRecordBuildLevel = self.nRecordBuildLevel, nLastBuildId = self.nLastBuildId, nRecord = self.nRecord}
end

TrekkerVersusData.RefreshTrekkerVersusData = function(self, nActId, msgData)
  -- function num : 0_2 , upvalues : _ENV
  self:Init()
  self.nActId = nActId
  self.nDayNum = msgData.DayNum
  self.nFanLevel = msgData.Level
  self.nFanExp = msgData.Exp
  self.nIdleRewardStartTime = (msgData.Show).IdleTime
  if not (msgData.Show).IdleValues then
    self.tbIdleReward = {}
    self.nSelfHotValue = (msgData.Show).SelfHotValue
    self.nRivalHotValue = (msgData.Show).RivalHotValue
    if not msgData.HotValueRewardIds then
      self.tbHotValueRewardIds = {}
      self.tbDuelRewardIds = msgData.DuelRewardIds
      self.tbDuelHistory = msgData.Results
      self.bFirstBattlePlayed = self.nIdleRewardStartTime ~= nil and self.nIdleRewardStartTime > 0
      self.nLastBuildId = msgData.BuildId
      self.nCachedBuildId = msgData.BuildId
      self.nRecord = (msgData.Show).Difficult or 0
      self.nRivalCount = 0
      local foreachRival = function(mapData)
    -- function num : 0_2_0 , upvalues : self
    if mapData.GroupId == self.nActId then
      self.nRivalCount = self.nRivalCount + 1
    end
  end

      ForEachTableLine(DataTable.TravelerDuelTarget, foreachRival)
      for _,mapQuest in ipairs(msgData.Quests) do
        -- DECOMPILER ERROR at PC65: Confused about usage of register: R9 in 'UnsetPending'

        (self.mapQuests)[mapQuest.Id] = mapQuest
      end
      self:RefreshQusetRedDot()
      ;
      (PlayerData.State):RefreshTrekkerVersusIdleRewardRedDot()
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
end

TrekkerVersusData.EnterTrekkerVersus = function(self, nLevelId, nBuildId, tbAffix)
  -- function num : 0_3 , upvalues : _ENV
  local callback = function()
    -- function num : 0_3_0 , upvalues : self, nBuildId, nLevelId, tbAffix
    self:SetCachedBuildId(nBuildId)
    self:EnterGame(nLevelId, nBuildId, tbAffix)
  end

  local msg = {ActivityId = self.nActId, LevelId = nLevelId, BuildId = nBuildId, AffixIds = tbAffix}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_apply_req, msg, nil, callback)
end

TrekkerVersusData.GetTravelerDuelAffixUnlock = function(self, nAffixId)
  -- function num : 0_4 , upvalues : _ENV
  local mapAffixCfgData = (ConfigTable.GetData)("TravelerDuelChallengeAffix", nAffixId)
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStamp
  local _fixedTimeStamp = self.nOpenTime + mapAffixCfgData.UnlockDurationTime * 60
  if mapAffixCfgData.UnlockDurationTime > 0 and curTimeStamp < _fixedTimeStamp then
    local sCond = ""
    local sumTime = _fixedTimeStamp - curTimeStamp
    sCond = orderedFormat((ConfigTable.GetUIText)("TDQuest_Day"), (math.ceil)(sumTime / 86400))
    return false, 4, sCond
  end
  do
    if mapAffixCfgData.UnlockDifficulty > 0 and self.nRecord < mapAffixCfgData.UnlockDifficulty then
      return false, 3, mapAffixCfgData.UnlockDifficulty
    end
    return true, 0, 0
  end
end

TrekkerVersusData.GetCachedBuildId = function(self)
  -- function num : 0_5
  return self.nCachedBuildId
end

TrekkerVersusData.GetAllQuestData = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local ret = {}
  for _,mapQuest in pairs(self.mapQuests) do
    (table.insert)(ret, mapQuest)
  end
  local statusOrder = {[0] = 1, [1] = 2, [2] = 0}
  local sort = function(a, b)
    -- function num : 0_6_0 , upvalues : statusOrder
    if a.Id >= b.Id then
      do return a.Status ~= b.Status end
      do return statusOrder[b.Status] < statusOrder[a.Status] end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

  ;
  (table.sort)(ret, sort)
  return ret
end

TrekkerVersusData.CheckBattlePlayed = function(self)
  -- function num : 0_7
  return self.bFirstBattlePlayed
end

TrekkerVersusData.GetCurStreamerDuelData = function(self)
  -- function num : 0_8 , upvalues : _ENV
  (self:GetTrekkerVersusCfgData())
  local mapStreamerDuelCfgData = nil
  local mapDuelData = nil
  local nMaxDay = 1
  local mapLastData = nil
  local foreachDuel = function(mapData)
    -- function num : 0_8_0 , upvalues : nMaxDay, mapLastData, mapStreamerDuelCfgData, self, mapDuelData
    if nMaxDay <= mapData.DayNum then
      nMaxDay = mapData.DayNum
      mapLastData = mapData
    end
    if mapData.GroupId == mapStreamerDuelCfgData.TargetGroupId and mapData.DayNum == self.nDayNum then
      mapDuelData = mapData
    end
  end

  ForEachTableLine(DataTable.TravelerDuelTarget, foreachDuel)
  if mapDuelData == nil then
    mapDuelData = mapLastData
  end
  return mapDuelData
end

TrekkerVersusData.GetCurHeatValue = function(self)
  -- function num : 0_9
  local nLastDuelResultHeatValue = 0
  nLastDuelResultHeatValue = self.tbDuelHistory == nil or #self.tbDuelHistory <= 0 or ((self.tbDuelHistory)[#self.tbDuelHistory]).SelfHotValue or 0
  if self.nSelfHotValue < nLastDuelResultHeatValue then
    self.nSelfHotValue = nLastDuelResultHeatValue
    self.nRivalHotValue = ((self.tbDuelHistory)[#self.tbDuelHistory]).RivalHotValue or 0
  end
  local mapHeatData = {nSelfHotValue = self.nSelfHotValue or 0, nRivalHotValue = self.nRivalHotValue or 0}
  return mapHeatData
end

TrekkerVersusData.GetCurDayNum = function(self)
  -- function num : 0_10
  return self.nDayNum
end

TrekkerVersusData.GetCurFanData = function(self)
  -- function num : 0_11
  local mapFanData = {nFanLevel = self.nFanLevel or 0, nFanExp = self.nFanExp or 0}
  return mapFanData
end

TrekkerVersusData.GetDuelHistory = function(self)
  -- function num : 0_12 , upvalues : _ENV
  (table.sort)(self.tbDuelHistory, function(a, b)
    -- function num : 0_12_0
    do return b.SelfHotValue < a.SelfHotValue end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return self.tbDuelHistory
end

TrekkerVersusData.GetIdleReward = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local tbIdleReward = {}
  local bAllZero = true
  local foreachIdleReward = function(mapData)
    -- function num : 0_13_0 , upvalues : _ENV, self, bAllZero, tbIdleReward
    for k,v in pairs(self.tbIdleReward) do
      if v.TypeId == mapData.HotValueItemType then
        local nCount = (math.floor)(v.Value / mapData.CumulativeValue)
        if nCount >= 1 then
          bAllZero = false
        end
        ;
        (table.insert)(tbIdleReward, {Tid = mapData.Id, Qty = nCount})
        break
      end
    end
  end

  ForEachTableLine(DataTable.TravelerDuelHotValueItem, foreachIdleReward)
  if bAllZero then
    tbIdleReward = {}
  end
  return tbIdleReward
end

TrekkerVersusData.GetIdleValue = function(self)
  -- function num : 0_14
  return self.tbIdleReward or 0
end

TrekkerVersusData.GetRecordLevel = function(self)
  -- function num : 0_15
  return self.nRecord or 0
end

TrekkerVersusData.GetIdleRewardStartTime = function(self)
  -- function num : 0_16
  return self.nIdleRewardStartTime
end

TrekkerVersusData.GetRivalCount = function(self)
  -- function num : 0_17
  return self.nRivalCount or 0
end

TrekkerVersusData.GetHotValueRewardTable = function(self)
  -- function num : 0_18
  return self.tbHotValueRewardIds
end

TrekkerVersusData.GetDuelRewardTable = function(self)
  -- function num : 0_19
  return self.tbDuelRewardIds
end

TrekkerVersusData.SetCachedBuildId = function(self, nBuildId)
  -- function num : 0_20
  self.nCachedBuildId = nBuildId
end

TrekkerVersusData.SetCacheAffixids = function(self, tbAffixes)
  -- function num : 0_21
  if tbAffixes ~= nil then
    self.CachedAffixes = tbAffixes
  end
end

TrekkerVersusData.GetCacheAffixids = function(self)
  -- function num : 0_22
  return self.CachedAffixes
end

TrekkerVersusData.EnterGame = function(self, nLevel, nBuildId, tbAffixes)
  -- function num : 0_23 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.TravelerDuelLevel.TravelerDuelLevelData")
  if luaClass == nil then
    return 
  end
  self.entryLevelId = nLevel
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevel, tbAffixes, nBuildId)
  end
end

TrekkerVersusData.SettleBattle = function(self, bSuccess, nLevelId, nTime, tbAffix, nBuildId, msgCallback)
  -- function num : 0_24 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_24_0 , upvalues : bSuccess, _ENV, tbAffix, self, nBuildId, msgCallback
    local bNewRecord = false
    if bSuccess then
      local nRecordLevel = 0
      for _,nAffixId in ipairs(tbAffix) do
        local mapAffixCfgData = (ConfigTable.GetData)("TravelerDuelChallengeAffix", nAffixId)
        if mapAffixCfgData ~= nil then
          nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
        end
      end
      if self.nRecord <= nRecordLevel then
        self.nRecord = nRecordLevel
        self.tbRecordAffix = clone(tbAffix)
        bNewRecord = true
        local buildDataCallback = function(mapBuild)
      -- function num : 0_24_0_0 , upvalues : self, _ENV
      self.nRecordBuildLevel = mapBuild.nScore
      self.tbRecordChar = {}
      for _,mapBuildChar in ipairs(mapBuild.tbChar) do
        (table.insert)(self.tbRecordChar, mapBuildChar.nTid)
      end
    end

        ;
        (PlayerData.Build):GetBuildDetailData(buildDataCallback, nBuildId)
      end
      do
        do
          self.nSuccessBattle = 1
          self.nLastBattleHard = nRecordLevel
          self.bFirstBattlePlayed = true
          self.nSuccessBattle = -1
          do
            local nRecordLevel = 0
            for _,nAffixId in ipairs(tbAffix) do
              local mapAffixCfgData = (ConfigTable.GetData)("TravelerDuelChallengeAffix", nAffixId)
              if mapAffixCfgData ~= nil then
                nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
              end
            end
            self.nLastBattleHard = nRecordLevel
            if msgData ~= nil and msgData.Show ~= nil then
              self.nIdleRewardStartTime = (msgData.Show).IdleTime
              self.tbIdleReward = (msgData.Show).IdleValues
            end
            if msgCallback ~= nil then
              msgCallback(bNewRecord)
            end
          end
        end
      end
    end
  end

  local msg = {ActivityId = self.nActId, Time = nTime, Passed = bSuccess, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).TravelerDuel, true)}
}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_settle_req, msg, nil, callback)
end

TrekkerVersusData.RequestIdleRefresh = function(self, callback)
  -- function num : 0_25 , upvalues : _ENV
  local nElapsedTime = ((CS.ClientManager).Instance).serverTimeStamp - self.nTimerIdleRefresh
  if nElapsedTime < 60 then
    if callback ~= nil then
      callback()
    end
    return 
  end
  self.nTimerIdleRefresh = ((CS.ClientManager).Instance).serverTimeStamp
  local cb = function(_, msgData)
    -- function num : 0_25_0 , upvalues : self, _ENV, callback
    if msgData ~= nil then
      self.nDifficult = msgData.Difficulty
      self.tbIdleReward = msgData.IdleValues
      self.nSelfHotValue = msgData.SelfHotValue
      self.nRivalHotValue = msgData.RivalHotValue
      local bRedDotOn = false
      do
        if self.tbIdleReward ~= nil and #self.tbIdleReward > 0 then
          local nPassedTime = ((CS.ClientManager).Instance).serverTimeStamp - self.nIdleRewardStartTime
          if 3600 * (ConfigTable.GetConfigNumber)("TrekkerVersusIdleRewardRedDotTime") <= nPassedTime then
            bRedDotOn = true
          end
        end
        local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
        if bInActGroup then
          (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusIdleReward, {nActGroupId, self.nActId}, bRedDotOn)
        end
        ;
        (PlayerData.State):RefreshTrekkerVersusIdleRewardRedDot(self.nIdleRewardStartTime)
        self:RefreshQusetRedDot()
        local mapHeatData = self:GetCurHeatValue()
        ;
        (EventManager.Hit)("UpdateTrekkerVersusHotValue", mapHeatData.nSelfHotValue, mapHeatData.nRivalHotValue)
        if callback ~= nil then
          callback(msgData)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_idle_refresh_req, {Value = self.nActId}, nil, cb)
end

TrekkerVersusData.RequestIdleRewardReceive = function(self, callback)
  -- function num : 0_26 , upvalues : _ENV
  local msg = {Value = self.nActId}
  local cb = function(_, msgData)
    -- function num : 0_26_0 , upvalues : _ENV, self, callback
    if msgData ~= nil then
      do
        if msgData.Change ~= nil then
          local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData.Change)
          ;
          (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
          ;
          (UTILS.OpenReceiveByDisplayItem)(msgData.AwardItems, msgData.ChangeInfo)
        end
        self.nIdleRewardStartTime = msgData.IdleTime
        for k,v in pairs(self.tbIdleReward) do
          v.Value = 0
        end
        ;
        (PlayerData.State):RefreshTrekkerVersusIdleRewardRedDot(self.nIdleRewardStartTime)
        self:RefreshQusetRedDot()
        if callback ~= nil then
          callback(msgData)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_idle_reward_receive_req, msg, nil, cb)
end

TrekkerVersusData.RequestSendStreamerGift = function(self, tbGift, nAddHotValue, callback)
  -- function num : 0_27 , upvalues : _ENV
  local msg = {ActivityId = self.nActId, Items = tbGift}
  local cb = function(_, msgData)
    -- function num : 0_27_0 , upvalues : self, _ENV, nAddHotValue, callback
    if msgData ~= nil then
      local nPrevFanLevel = self.nFanLevel
      local nPrevFanExp = self.nFanExp
      self.nFanLevel = msgData.Level
      self.nFanExp = msgData.Exp
      local nNowTime = ((CS.ClientManager).Instance).serverTimeStamp
      if self.nSelfHotValue < msgData.SelfHotValue then
        self.nSelfHotValue = msgData.SelfHotValue
      else
        if nNowTime < self:GetChallengeEndTime() then
          self.nSelfHotValue = self.nSelfHotValue + nAddHotValue
        end
      end
      self.nRivalHotValue = msgData.RivalHotValue
      local mapHeatData = self:GetCurHeatValue()
      ;
      (EventManager.Hit)("UpdateTrekkerVersusHotValue", mapHeatData.nSelfHotValue, mapHeatData.nRivalHotValue)
      do
        if msgData.Change ~= nil then
          local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData.Change)
          ;
          (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        end
        self:RefreshQusetRedDot()
        if callback ~= nil then
          callback(msgData, nPrevFanLevel, nPrevFanExp)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_rank_boost_req, msg, nil, cb)
end

TrekkerVersusData.RequestReceiveScheduleReward = function(self, nScheduleType)
  -- function num : 0_28 , upvalues : _ENV
  local msg = {ActivityId = self.nActId, ScheduleType = nScheduleType}
  local callback = function(_, msgData)
    -- function num : 0_28_0 , upvalues : _ENV, nScheduleType, self
    if msgData ~= nil then
      do
        if msgData.Change ~= nil then
          local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData.Change)
          ;
          (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
          ;
          (UTILS.OpenReceiveByDisplayItem)(msgData.AwardItems, msgData.ChangeInfo)
        end
        if nScheduleType == 1 then
          local foreachHeatQuest = function(mapQuestData)
      -- function num : 0_28_0_0 , upvalues : self, _ENV
      if mapQuestData.TargetValue <= self.nSelfHotValue and (table.indexof)(self.tbHotValueRewardIds, mapQuestData.Id) <= 0 then
        (table.insert)(self.tbHotValueRewardIds, mapQuestData.Id)
      end
    end

          ForEachTableLine(DataTable.TravelerDuelHotValueRewards, foreachHeatQuest)
          self:RefreshQusetRedDot()
          ;
          (EventManager.Hit)("TrekkerVersusHeatQuestRefresh")
        else
          do
            if nScheduleType == 2 then
              for _,v in pairs(self.tbDuelHistory) do
                if (table.indexof)(self.tbDuelRewardIds, v.TargetId) <= 0 then
                  (table.insert)(self.tbDuelRewardIds, v.TargetId)
                end
              end
              self:RefreshQusetRedDot()
              ;
              (EventManager.Hit)("TrekkerVersusDuelQuestRefresh")
            end
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_schedule_reward_receive_req, msg, nil, callback)
end

TrekkerVersusData.CheckBattleSuccess = function(self)
  -- function num : 0_29
  local retResult = self.nSuccessBattle
  local retHard = self.nLastBattleHard
  self.nSuccessBattle = 0
  self.nLastBattleHard = 0
  return retResult, retHard
end

TrekkerVersusData.LevelEnd = function(self)
  -- function num : 0_30 , upvalues : _ENV
  if type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

TrekkerVersusData.RefreshQuestData = function(self, questData)
  -- function num : 0_31
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.mapQuests)[questData.Id] = questData
  self:RefreshQusetRedDot()
end

TrekkerVersusData.ReceiveQuestReward = function(self, callback)
  -- function num : 0_32 , upvalues : _ENV
  local bReceive = false
  for _,mapQuest in pairs(self.mapQuests) do
    if mapQuest.Status == 1 then
      bReceive = true
      break
    end
  end
  do
    local msgCallback = function(_, msgData)
    -- function num : 0_32_0 , upvalues : _ENV, self, callback
    do
      if msgData.Change ~= nil then
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData.Change)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        ;
        (UTILS.OpenReceiveByDisplayItem)(msgData.AwardItems, msgData.ChangeInfo)
      end
      for _,mapQuest in pairs(self.mapQuests) do
        if mapQuest.Status == 1 then
          mapQuest.Status = 2
        end
      end
      self:RefreshQusetRedDot()
      ;
      (EventManager.Hit)("TrekkerVersusQuestRefresh")
      if callback ~= nil then
        callback(msgData)
      end
    end
  end

    if bReceive then
      local msg = {Value = self.nActId}
      ;
      (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trekker_versus_reward_receive_req, msg, nil, msgCallback)
    else
      do
        local sTip = (ConfigTable.GetUIText)("Quest_ReceiveNone")
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, sTip)
      end
    end
  end
end

TrekkerVersusData.GetTrekkerVersusCfgData = function(self)
  -- function num : 0_33 , upvalues : _ENV
  local mapCfgData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  return mapCfgData
end

TrekkerVersusData.GetChallengeStartTime = function(self)
  -- function num : 0_34 , upvalues : _ENV
  local mapActivityData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  if mapActivityData ~= nil then
    return String2Time(mapActivityData.OpenTime)
  end
  return self.nOpenTime
end

TrekkerVersusData.GetChallengeEndTime = function(self)
  -- function num : 0_35 , upvalues : _ENV
  local mapActivityData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  if mapActivityData ~= nil then
    return String2Time(mapActivityData.EndTime)
  end
  return self.nEndTime
end

TrekkerVersusData.IsOpenStreamerDuel = function(self, nStartTime)
  -- function num : 0_36 , upvalues : _ENV
  local nowTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nEndTime = ((CS.ClientManager).Instance):GetNextRefreshTime(nStartTime) + 86400 * (self.nRivalCount - 1)
  do return nStartTime < nowTime and nowTime < nEndTime end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

TrekkerVersusData.RefreshQusetRedDot = function(self)
  -- function num : 0_37 , upvalues : _ENV
  local bGiftQuestVisible = false
  local bBattleQuestVisible = false
  for _,mapQuest in pairs(self.mapQuests) do
    if mapQuest.Status == 1 then
      local mapQuestData = (ConfigTable.GetData)("TravelerDuelChallengeQuest", mapQuest.Id)
      if mapQuestData.CompleteCond == (GameEnum.questCompleteCond).TrekkerVersusFansWithSpecificLevel then
        bGiftQuestVisible = true
      else
        bBattleQuestVisible = true
      end
    end
  end
  local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
  if bInActGroup then
    (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusGiftQuest, {nActGroupId, self.nActId}, bGiftQuestVisible)
    ;
    (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusBattleQuest, {nActGroupId, self.nActId}, bBattleQuestVisible)
  end
  local bStreamerDuelOpen = self:IsOpenStreamerDuel(self:GetChallengeStartTime())
  if not bStreamerDuelOpen or not self.nDayNum - 1 then
    local nPassedDuelCount = self.nRivalCount
  end
  if self.nDayNum == 0 then
    nPassedDuelCount = self.nRivalCount
  end
  local nReceivedDuelReward = #self.tbDuelRewardIds
  if nReceivedDuelReward >= nPassedDuelCount then
    (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusDuelQuest, {nActGroupId, self.nActId}, not bInActGroup)
    local bHeatQuestVisible = false
    local foreachHeatReward = function(mapData)
    -- function num : 0_37_0 , upvalues : self, _ENV, bHeatQuestVisible
    if mapData.TargetValue <= self.nSelfHotValue and (table.indexof)(self.tbHotValueRewardIds, mapData.Id) <= 0 then
      bHeatQuestVisible = true
    end
  end

    ForEachTableLine(DataTable.TravelerDuelHotValueRewards, foreachHeatReward)
    if bInActGroup then
      (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusHeatQuest, {nActGroupId, self.nActId}, bHeatQuestVisible)
    end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

TrekkerVersusData.GetFirstIn = function(self)
  -- function num : 0_38
  local bFirst = self.bFirstIn
  if self.bFirstIn == true then
    self.bFirstIn = false
  end
  return bFirst
end

TrekkerVersusData.OnEvent_TrekkerVersusFanGiftDataRefresh = function(self, nActId, nFanLevel, nExp)
  -- function num : 0_39 , upvalues : _ENV
  if nActId ~= self.nActId then
    return 
  end
  self.nFanLevel = nFanLevel
  self.nFanExp = nExp
  ;
  (EventManager.Hit)("TrekkerVersusFanGiftShowRefresh")
end

return TrekkerVersusData

