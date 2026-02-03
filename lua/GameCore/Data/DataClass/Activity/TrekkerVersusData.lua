local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local TrekkerVersusData = class("TrekkerVersusData", ActivityDataBase)
TrekkerVersusData.Init = function(self)
  -- function num : 0_0
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
end

TrekkerVersusData.GetActivityData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  return {nActId = self.nActId, tbRecordAffix = clone(self.tbRecordAffix), tbRecordChar = clone(self.tbRecordChar), nRecordBuildLevel = self.nRecordBuildLevel, nLastBuildId = self.nLastBuildId, nRecord = self.nRecord}
end

TrekkerVersusData.RefreshTrekkerVersusData = function(self, nActId, msgData)
  -- function num : 0_2 , upvalues : _ENV
  self:Init()
  self.nActId = nActId
  self.nLastBuildId = msgData.BuildId
  self.nCachedBuildId = msgData.BuildId
  self.tbRecordAffix = (msgData.Show).AffixIds
  self.tbRecordChar = (msgData.Show).CharIds
  self.nRecordBuildLevel = (msgData.Show).BuildScore
  local nRecordLevel = 0
  for _,nAffixId in ipairs(self.tbRecordAffix) do
    local mapAffixCfgData = (ConfigTable.GetData)("TravelerDuelChallengeAffix", nAffixId)
    if mapAffixCfgData ~= nil then
      nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
    end
  end
  self.nRecord = nRecordLevel
  for _,mapQuest in ipairs(msgData.Quests) do
    -- DECOMPILER ERROR at PC39: Confused about usage of register: R9 in 'UnsetPending'

    (self.mapQuests)[mapQuest.Id] = mapQuest
  end
  self:RefreshQusetRedDot()
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
    if sumTime > 86400 then
      sCond = orderedFormat((ConfigTable.GetUIText)("TDQuest_Day"), (math.floor)(sumTime / 86400))
    else
      sCond = (ConfigTable.GetUIText)("TDQuest_LessThenDay")
    end
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

TrekkerVersusData.SetCachedBuildId = function(self, nBuildId)
  -- function num : 0_7
  self.nCachedBuildId = nBuildId
end

TrekkerVersusData.SetCacheAffixids = function(self, tbAffixes)
  -- function num : 0_8
  if tbAffixes ~= nil then
    self.CachedAffixes = tbAffixes
  end
end

TrekkerVersusData.GetCacheAffixids = function(self)
  -- function num : 0_9
  return self.CachedAffixes
end

TrekkerVersusData.EnterGame = function(self, nLevel, nBuildId, tbAffixes)
  -- function num : 0_10 , upvalues : _ENV
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
  -- function num : 0_11 , upvalues : _ENV
  local callback = function()
    -- function num : 0_11_0 , upvalues : bSuccess, _ENV, tbAffix, self, nBuildId, msgCallback
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
      -- function num : 0_11_0_0 , upvalues : self, _ENV
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

TrekkerVersusData.CheckBattleSuccess = function(self)
  -- function num : 0_12
  local retResult = self.nSuccessBattle
  local retHard = self.nLastBattleHard
  self.nSuccessBattle = 0
  self.nLastBattleHard = 0
  return retResult, retHard
end

TrekkerVersusData.LevelEnd = function(self)
  -- function num : 0_13 , upvalues : _ENV
  if type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

TrekkerVersusData.RefreshQuestData = function(self, questData)
  -- function num : 0_14
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.mapQuests)[questData.Id] = questData
  self:RefreshQusetRedDot()
end

TrekkerVersusData.ReceiveQuestReward = function(self, callback)
  -- function num : 0_15 , upvalues : _ENV
  local bReceive = false
  for _,mapQuest in pairs(self.mapQuests) do
    if mapQuest.Status == 1 then
      bReceive = true
      break
    end
  end
  do
    local msgCallback = function(_, msgData)
    -- function num : 0_15_0 , upvalues : callback, _ENV, self
    if callback ~= nil then
      callback(msgData)
    end
    for _,mapQuest in pairs(self.mapQuests) do
      if mapQuest.Status == 1 then
        mapQuest.Status = 2
      end
    end
    self:RefreshQusetRedDot()
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
  -- function num : 0_16 , upvalues : _ENV
  local mapCfgData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  return mapCfgData
end

TrekkerVersusData.GetChallengeStartTime = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local mapActivityData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  if mapActivityData ~= nil then
    return String2Time(mapActivityData.OpenTime)
  end
  return self.nOpenTime
end

TrekkerVersusData.GetChallengeEndTime = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local mapActivityData = (ConfigTable.GetData)("TravelerDuelChallengeControl", self.nActId)
  if mapActivityData ~= nil then
    return String2Time(mapActivityData.EndTime)
  end
  return self.nEndTime
end

TrekkerVersusData.RefreshQusetRedDot = function(self)
  -- function num : 0_19 , upvalues : _ENV
  local bVisible = false
  for _,mapQuest in pairs(self.mapQuests) do
    if mapQuest.Status == 1 then
      bVisible = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusQuest, nil, bVisible)
    ;
    (RedDotManager.SetValid)(RedDotDefine.TrekkerVersusQuest_1, nil, bVisible)
  end
end

TrekkerVersusData.GetFirstIn = function(self)
  -- function num : 0_20
  local bFirst = self.bFirstIn
  if self.bFirstIn == true then
    self.bFirstIn = false
  end
  return bFirst
end

return TrekkerVersusData

