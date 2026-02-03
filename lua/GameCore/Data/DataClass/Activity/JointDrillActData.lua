local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local JointDrillActData = class("JointDrillActData", ActivityDataBase)
local ClientManager = (CS.ClientManager).Instance
local TimerManager = require("GameCore.Timer.TimerManager")
JointDrillActData.Init = function(self)
  -- function num : 0_0
  self.jointDrillActCfg = nil
  self.nJointDrillType = 0
  self.nActStatus = 0
  self.actTimer = nil
  self.tbPassedLevels = {}
  self.tbQuests = {}
  self.nTotalScore = 0
  self.nLastRefreshRankTime = 0
  self.nRankingRefreshTime = 600
  self.mapSelfRankData = nil
  self.mapRankList = nil
  self.nTotalRank = 0
  self:InitConfig()
end

JointDrillActData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapActCfg = (ConfigTable.GetData)("JointDrillControl", self.nActId)
  if mapActCfg == nil then
    return 
  end
  self.jointDrillActCfg = mapActCfg
  self.nJointDrillType = mapActCfg.Type
  if (CacheTable.Get)("_JointDrillQuest") == nil or next((CacheTable.Get)("_JointDrillQuest")) == nil then
    local funcForeachJointDrillQuest = function(line)
    -- function num : 0_1_0 , upvalues : _ENV
    if (CacheTable.GetData)("_JointDrillQuest", line.GroupId) == nil then
      (CacheTable.SetData)("_JointDrillQuest", line.GroupId, {})
    end
    ;
    (CacheTable.InsertData)("_JointDrillQuest", line.GroupId, line)
  end

    ForEachTableLine((ConfigTable.Get)("JointDrillQuest"), funcForeachJointDrillQuest)
  end
end

JointDrillActData.GetJointDrillActCfg = function(self)
  -- function num : 0_2
  return self.jointDrillActCfg
end

JointDrillActData.RefreshJointDrillActData = function(self, msgData)
  -- function num : 0_3 , upvalues : _ENV
  if self.nJointDrillType == (GameEnum.JointDrillMode).JointDrill_Mode_1 then
    (PlayerData.JointDrill_1):InitData()
    if msgData.Mode1 ~= nil then
      (PlayerData.JointDrill_1):CacheJointDrillData(self.nActId, msgData.Meta, msgData.Mode1)
    end
  else
    if self.nJointDrillType == (GameEnum.JointDrillMode).JointDrill_Mode_2 then
      (PlayerData.JointDrill_2):InitData()
      if msgData.Mode2 ~= nil then
        (PlayerData.JointDrill_2):CacheJointDrillData(self.nActId, msgData.Meta, msgData.Mode2)
      end
    end
  end
  self.tbPassedLevels = msgData.PassedLevels
  if msgData.Quests ~= nil then
    self.tbQuests = msgData.Quests
  end
  self:RefreshJointDrillQuestRedDot()
  self:StartActTimer()
end

JointDrillActData.GetChallengeStartTime = function(self)
  -- function num : 0_4
  if self.jointDrillActCfg ~= nil then
    return self.nOpenTime + (self.jointDrillActCfg).DrillStartTime
  end
end

JointDrillActData.GetChallengeEndTime = function(self)
  -- function num : 0_5
  if self.jointDrillActCfg ~= nil then
    return self.nOpenTime + (self.jointDrillActCfg).DrillStartTime + (self.jointDrillActCfg).DrillDurationTime
  end
end

JointDrillActData.RefreshJointDrillQuestRedDot = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local bHasReward = false
  for _,v in ipairs(self.tbQuests) do
    if v.Status == 1 then
      bHasReward = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.JointDrillQuest, nil, bHasReward)
  end
end

JointDrillActData.RefreshQuestData = function(self, questData)
  -- function num : 0_7 , upvalues : _ENV
  local bHasData = false
  for k,v in ipairs(self.tbQuests) do
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R8 in 'UnsetPending'

    if v.Id == questData.Id then
      (self.tbQuests)[k] = questData
      bHasData = true
      break
    end
  end
  do
    if not bHasData then
      (table.insert)(self.tbQuests, questData)
    end
    self:RefreshJointDrillQuestRedDot()
  end
end

JointDrillActData.GetRewardQuestList = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local tbQuests = {}
  for _,v in ipairs(self.tbQuests) do
    local nSortStatus = 0
    if v.Status == 0 then
      nSortStatus = 1
    else
      if v.Status == 1 then
        nSortStatus = 0
      else
        if v.Status == 2 then
          nSortStatus = 2
        end
      end
    end
    v.SortStatus = nSortStatus
    ;
    (table.insert)(tbQuests, v)
  end
  return tbQuests
end

JointDrillActData.SendReceiveQuestReward = function(self, callback)
  -- function num : 0_9 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_9_0 , upvalues : _ENV, callback
    (UTILS.OpenReceiveByChangeInfo)(netMsg, function()
      -- function num : 0_9_0_0 , upvalues : callback
      if callback ~= nil then
        callback()
      end
    end
)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_quest_reward_receive_req, {}, nil, NetCallback)
end

JointDrillActData.StartActTimer = function(self)
  -- function num : 0_10 , upvalues : ClientManager, _ENV, TimerManager
  if self.actTimer ~= nil then
    (self.actTimer):Cancel()
    self.actTimer = nil
  end
  local nChallengeStartTime = self:GetChallengeStartTime()
  local nChallengeEndTime = self:GetChallengeEndTime()
  local nActEndTime = self:GetActEndTime()
  self.nActStatus = 0
  local refreshTime = function()
    -- function num : 0_10_0 , upvalues : ClientManager, nChallengeStartTime, self, _ENV, nChallengeEndTime, nActEndTime
    local nRemainTime = 0
    local nCurTime = ClientManager.serverTimeStamp
    if nCurTime < nChallengeStartTime then
      self.nActStatus = (AllEnum.JointDrillActStatus).WaitStart
      nRemainTime = nChallengeStartTime - nCurTime
    else
      if nCurTime <= nChallengeEndTime then
        self.nActStatus = (AllEnum.JointDrillActStatus).Start
        nRemainTime = nChallengeEndTime - nCurTime
      else
        if nChallengeEndTime < nCurTime and nCurTime < nActEndTime then
          self.nActStatus = (AllEnum.JointDrillActStatus).WaitClose
          nRemainTime = nActEndTime - nCurTime
        else
          if nActEndTime <= nCurTime then
            self.nActStatus = (AllEnum.JointDrillActStatus).Closed
            nRemainTime = 0
          end
        end
      end
    end
    ;
    (EventManager.Hit)("RefreshJointDrillActTime", self.nActStatus, nRemainTime)
    if nRemainTime <= 0 and self.actTimer ~= nil and self.nActStatus == (AllEnum.JointDrillActStatus).Closed then
      (self.actTimer):Cancel()
      self.actTimer = nil
      return 
    end
  end

  refreshTime()
  if self.actTimer == nil then
    self.actTimer = (TimerManager.Add)(0, 1, nil, refreshTime, true, true, true)
  end
end

JointDrillActData.GetActStatus = function(self)
  -- function num : 0_11
  return self.nActStatus
end

JointDrillActData.CheckPassedId = function(self, nLevelId)
  -- function num : 0_12 , upvalues : _ENV
  if self.tbPassedLevels ~= nil then
    for _,v in ipairs(self.tbPassedLevels) do
      if v.LevelId == nLevelId then
        return true
      end
    end
  end
  do
    return false
  end
end

JointDrillActData.PassedLevel = function(self, nLevelId, nScore)
  -- function num : 0_13 , upvalues : _ENV
  (table.insert)(self.tbPassedLevels, {LevelId = nLevelId, Score = nScore})
end

JointDrillActData.GetJointDrillType = function(self)
  -- function num : 0_14
  return self.nJointDrillType
end

return JointDrillActData

