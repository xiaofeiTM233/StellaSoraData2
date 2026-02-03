local PlayerJointDrillData_2 = class("PlayerJointDrillData_2")
local ConfigData = require("GameCore.Data.ConfigData")
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local ClientManager = (CS.ClientManager).Instance
local ListInt = ((((CS.System).Collections).Generic).List)((CS.System).Int32)
PlayerJointDrillData_2.Init = function(self)
  -- function num : 0_0
  self.bInit = false
end

PlayerJointDrillData_2.InitData = function(self)
  -- function num : 0_1
  if not self.bInit then
    self.bInit = true
    self.nActId = 0
    self.actDataIns = nil
    self.actTimer = nil
    self.bInBattle = false
    self.bResetLevelSelect = false
    self.curLevel = nil
    self.nCurLevelId = 0
    self.nCurLevel = 1
    self.nStartTime = 0
    self.nGameTime = 0
    self._EntryTime = 0
    self._EndTime = 0
    self.mapBossInfo = {}
    self.record = nil
    self.bSimulate = false
    self.tbTeams = {}
    self.nSelectBuildId = 0
    self.nChallengeCount = 0
    self.tbRecordFloors = {}
    self.nTotalScore = 0
    self.nLastRefreshRankTime = 0
    self.nRankingRefreshTime = 600
    self.mapSelfRankData = nil
    self.mapRankList = nil
    self.nTotalRank = 0
    self:InitConfig()
  end
end

PlayerJointDrillData_2.UnInit = function(self)
  -- function num : 0_2
end

PlayerJointDrillData_2.InitConfig = function(self)
  -- function num : 0_3 , upvalues : _ENV
  self.nMaxChallengeTime = (ConfigTable.GetConfigNumber)("JointDrill_Challenge_Time_Max")
  self.nOverFlowChallengeTime = (ConfigTable.GetConfigNumber)("JointDrill_Challenge_Time_OverFlow")
  local funcForeachJointDrillLevel2 = function(line)
    -- function num : 0_3_0 , upvalues : _ENV
    (CacheTable.SetField)("_JointDrill_2_Level", line.DrillLevelGroupId, line.Difficulty, line)
  end

  ForEachTableLine((ConfigTable.Get)("JointDrill_2_Level"), funcForeachJointDrillLevel2)
  local funcForeachJointDrillLevel2 = function(line)
    -- function num : 0_3_1 , upvalues : _ENV
    (CacheTable.SetField)("_JointDrill_2_Floor", line.FloorId, line.BattleLvs, line)
  end

  ForEachTableLine((ConfigTable.Get)("JointDrill_2_Floor"), funcForeachJointDrillLevel2)
  self.nRankCount = 0
  local funcForeachJointDrillRank = function(line)
    -- function num : 0_3_2 , upvalues : self
    self.nRankCount = self.nRankCount + 1
  end

  ForEachTableLine((ConfigTable.Get)("JointDrillRank"), funcForeachJointDrillRank)
end

PlayerJointDrillData_2.CacheJointDrillData = function(self, nActId, msgData, msgBossInfo)
  -- function num : 0_4 , upvalues : _ENV
  self.nActId = nActId
  self.actDataIns = (PlayerData.Activity):GetActivityDataById(nActId)
  self.bInBattle = msgData.LevelId ~= 0
  self.nCurLevelId = msgData.LevelId
  self.nCurLevel = msgData.Floor
  if self.bInBattle then
    local mapCfg = (ConfigTable.GetData)("JointDrill_2_Level", self.nCurLevelId)
    if mapCfg == nil then
      return 
    end
    self:InitBossInfo(mapCfg.MonsterGroupId)
    self.mapActControl = (ConfigTable.GetData)("JointDrillControl", self.nActId)
    for _,v in ipairs(msgBossInfo.BossHpMaxes) do
      for nLevel,mapBoss in ipairs(self.mapBossInfo) do
        for nIndex,boss in ipairs(mapBoss) do
          if boss.nBossCfgId == v.Id then
            boss.nHpMax = v.Hp
          end
        end
      end
    end
    for _,v in ipairs(msgBossInfo.BossHps) do
      for nLevel,mapBoss in ipairs(self.mapBossInfo) do
        for nIndex,boss in ipairs(mapBoss) do
          if boss.nBossCfgId == v.Id then
            boss.nHp = v.Hp
          end
        end
      end
    end
  end
  self.nStartTime = msgData.StartTime
  self.tbTeams = msgData.Teams
  self.bSimulate = msgData.Simulate
  self.nTotalScore = msgData.TotalScore
  self._EntryTime = msgData.StartTime
  self.record = msgBossInfo.Record
  if self.bInBattle then
    self:StartChallengeTime()
  else
    self:ChallengeEnd()
  end
  -- DECOMPILER ERROR: 11 unprocessed JMP targets
end

PlayerJointDrillData_2.GetMonsterCfg = function(self, nMonsterId)
  -- function num : 0_5 , upvalues : _ENV
  local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
  if mapMonsterCfg ~= nil then
    local nSkinId = mapMonsterCfg.FAId
    local mapSkinCfg = (ConfigTable.GetData)("MonsterSkin", nSkinId)
    if mapSkinCfg ~= nil then
      local nManualId = mapSkinCfg.MonsterManual
      local mapManualCfg = (ConfigTable.GetData)("MonsterManual", nManualId)
      if mapManualCfg ~= nil then
        return mapManualCfg
      end
    end
  end
end

PlayerJointDrillData_2.GetMonsterMaxHp = function(self, nMonsterId, nDifficulty)
  -- function num : 0_6 , upvalues : _ENV, ConfigData
  local nMaxHp = 0
  local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
  if mapMonsterCfg == nil then
    return 0
  end
  local mapAdjustCfg = (ConfigTable.GetData)("MonsterValueTempleteAdjust", mapMonsterCfg.Templete)
  if mapAdjustCfg == nil then
    return 0
  end
  do
    if next((CacheTable.Get)("_MonsterValueTemplete")) == nil then
      local funcForeachMonsterValueTemplete = function(line)
    -- function num : 0_6_0 , upvalues : _ENV
    (CacheTable.SetField)("_MonsterValueTemplete", line.TemplateId, line.Lv, line.Hp)
  end

      ForEachTableLine((ConfigTable.Get)("MonsterValueTemplete"), funcForeachMonsterValueTemplete)
    end
    local mapCfgList = (CacheTable.GetData)("_MonsterValueTemplete", mapAdjustCfg.TemplateId)
    if mapCfgList == nil then
      return 0
    end
    local nValue = mapCfgList[nDifficulty]
    if nValue == nil then
      return 0
    end
    local nRatio = mapAdjustCfg.HpRatio
    local nFix = mapAdjustCfg.HpFix
    nMaxHp = (math.floor)(nValue * (1 + nRatio * ConfigData.IntFloatPrecision) + nFix)
    return nMaxHp
  end
end

PlayerJointDrillData_2.InitBossInfo = function(self, nGroupId, nDifficulty)
  -- function num : 0_7 , upvalues : _ENV
  self.mapBossInfo = {}
  local mapCfg = (ConfigTable.GetData)("JointDrill_2_MonsterGroup", nGroupId)
  if mapCfg ~= nil then
    local nLevelCount = 4
    local nIndexCount = 3
    for i = 1, nLevelCount do
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R10 in 'UnsetPending'

      (self.mapBossInfo)[i] = {}
      for j = 1, nIndexCount do
        local nCfgId = mapCfg["MateId_" .. (i - 1) * nIndexCount + j]
        if nCfgId == 0 then
          nCfgId = mapCfg["MateId_" .. j]
        end
        local nHp = 0
        local nHpMax = 0
        if i == 1 and nCfgId ~= 0 then
          nHpMax = self:GetMonsterMaxHp(nCfgId, nDifficulty)
          nHp = nHpMax
        end
        -- DECOMPILER ERROR at PC52: Confused about usage of register: R17 in 'UnsetPending'

        ;
        ((self.mapBossInfo)[i])[j] = {nBossCfgId = nCfgId, nHp = nHp, nHpMax = nHpMax}
      end
    end
  end
end

PlayerJointDrillData_2.UpdateBossInfo = function(self, mapBossInfo)
  -- function num : 0_8 , upvalues : _ENV
  if mapBossInfo == nil then
    return 
  end
  local nCount = mapBossInfo.Count
  for index = 0, nCount - 1 do
    local bossData = mapBossInfo[index]
    local nIndex = bossData.nIndex
    local nFloor = bossData.nFloor
    local nBossCfgId = bossData.nDataId
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R11 in 'UnsetPending'

    if (self.mapBossInfo)[nFloor] ~= nil and ((self.mapBossInfo)[nFloor])[nIndex] ~= nil then
      (((self.mapBossInfo)[nFloor])[nIndex]).nHp = bossData.nHp
      -- DECOMPILER ERROR at PC30: Confused about usage of register: R11 in 'UnsetPending'

      ;
      (((self.mapBossInfo)[nFloor])[nIndex]).nHpMax = bossData.nHpMax
    else
      traceback((string.format)("【总力战】更新boss血量信息失败！！！floor = %s, bossId = %s", nFloor, nBossCfgId))
    end
  end
end

PlayerJointDrillData_2.ResetBossInfo = function(self, mapBossInfo)
  -- function num : 0_9 , upvalues : _ENV
  self.mapBossInfo = clone(mapBossInfo)
end

PlayerJointDrillData_2.GetCurBossInfo = function(self)
  -- function num : 0_10
  if (self.mapBossInfo)[self.nCurLevel] ~= nil then
    return (self.mapBossInfo)[self.nCurLevel]
  end
end

PlayerJointDrillData_2.GetBossInfo = function(self)
  -- function num : 0_11
  return self.mapBossInfo
end

PlayerJointDrillData_2.IsJointDrillUnlock = function(self, nLevelId)
  -- function num : 0_12 , upvalues : _ENV
  local mapLevelCfg = (ConfigTable.GetData)("JointDrill_2_Level", nLevelId)
  if mapLevelCfg == nil then
    return false
  end
  local nPreLevelId = mapLevelCfg.PreLevelId
  if nPreLevelId == 0 then
    return true
  end
  return (self.actDataIns):CheckPassedId(nPreLevelId)
end

PlayerJointDrillData_2.StartChallengeTime = function(self)
  -- function num : 0_13 , upvalues : _ENV, TimerManager
  if self.challengeTimer ~= nil then
    (self.challengeTimer):Cancel()
    self.challengeTimer = nil
  end
  local nOpenTime = self.nStartTime
  local refreshTime = function()
    -- function num : 0_13_0 , upvalues : _ENV, self, nOpenTime
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    local nTime = self.nMaxChallengeTime - (nCurTime - nOpenTime)
    if nTime >= 0 then
      (EventManager.Hit)("RefreshChallengeTime", nTime)
    end
    return nTime
  end

  local nTime = refreshTime()
  if nTime > 0 then
    self.challengeTimer = (TimerManager.Add)(0, 1, nil, function()
    -- function num : 0_13_1 , upvalues : refreshTime, self
    local nTime = refreshTime()
    if nTime <= 0 then
      (self.challengeTimer):Cancel()
      self.challengeTimer = nil
      if self.curLevel ~= nil then
        (self.curLevel):JointDrillTimeOut()
      end
    end
  end
, true, true, true)
  end
end

PlayerJointDrillData_2.EnterJointDrill = function(self, nLevelId, nBuildId, bSimulate, nStartType, nCurLevel)
  -- function num : 0_14 , upvalues : _ENV, LocalData
  local mapLevelCfg = (ConfigTable.GetData)("JointDrill_2_Level", nLevelId)
  if mapLevelCfg == nil then
    return 
  end
  local enterLevel = function(mapNetData)
    -- function num : 0_14_0 , upvalues : self, _ENV, nLevelId, bSimulate, nCurLevel, LocalData, nBuildId, nStartType
    do
      if self.curLevel == nil then
        local luaClass = require("Game.Adventure.JointDrill.JointDrillLevelData_2")
        if luaClass == nil then
          return 
        end
        self.curLevel = luaClass
        if type((self.curLevel).BindEvent) == "function" then
          (self.curLevel):BindEvent()
        end
      end
      self.nCurLevelId = nLevelId
      self.bInBattle = true
      self.bSimulate = bSimulate
      if nCurLevel == nil then
        nCurLevel = self.nCurLevel
      end
      if mapNetData ~= nil then
        self.nStartTime = mapNetData.StarTime
        self._EntryTime = mapNetData.StarTime
        local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
        if sKey ~= nil and sKey ~= "" then
          (NovaAPI.DeleteRecFile)(sKey)
        end
        sKey = tostring(mapNetData.StarTime)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordKey", sKey)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordFloorId", 0)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordExcludeId", 0)
        self:EventUpload(1)
      end
      do
        self:StartChallengeTime()
        if type((self.curLevel).Init) == "function" then
          (self.curLevel):Init(self, nLevelId, nBuildId, nCurLevel, nStartType)
        end
      end
    end
  end

  local netCallback = function(_, netMsg)
    -- function num : 0_14_1 , upvalues : enterLevel
    enterLevel(netMsg)
  end

  if nStartType == (AllEnum.JointDrillLevelStartType).Continue then
    self:ContinueJointDrill(nBuildId, enterLevel)
  else
    if nStartType == (AllEnum.JointDrillLevelStartType).Start then
      self:InitBossInfo(mapLevelCfg.MonsterGroupId, mapLevelCfg.Difficulty)
      local tbBossHp = {}
      local tbBossHpMax = {}
      for _,v in ipairs(mapLevelCfg.BossId) do
        local nHp = self:GetMonsterMaxHp(v, mapLevelCfg.Difficulty)
        if nHp == 0 then
          printError((string.format)("[总力战]获取boss血量失败！！！ levelId = %s, bossId = %s", nLevelId, mapLevelCfg.BossId))
          return 
        end
        ;
        (table.insert)(tbBossHp, {Id = v, Hp = nHp})
        ;
        (table.insert)(tbBossHpMax, {Id = v, Hp = nHp})
      end
      local msg = {LevelId = nLevelId, BuildId = nBuildId, BossHps = tbBossHp, BossHpMaxes = tbBossHpMax, Simulate = bSimulate}
      ;
      (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_apply_req, msg, nil, netCallback)
    else
      do
        enterLevel()
      end
    end
  end
end

PlayerJointDrillData_2.ChangeLevel = function(self, nLevel)
  -- function num : 0_15 , upvalues : _ENV
  self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, (AllEnum.JointDrillLevelStartType).ChangeLevel, nLevel)
end

PlayerJointDrillData_2.RestartBattle = function(self)
  -- function num : 0_16 , upvalues : _ENV
  self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, (AllEnum.JointDrillLevelStartType).Restart, self.nCurLevel)
end

PlayerJointDrillData_2.ContinueJointDrill = function(self, nBuildId, callback)
  -- function num : 0_17 , upvalues : LocalData, _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_17_0 , upvalues : LocalData, _ENV, self, callback
    local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
    if sKey == "" or sKey ~= tostring(self.nStartTime) then
      if sKey ~= "" then
        (NovaAPI.DeleteRecFile)(sKey)
      end
      ;
      (LocalData.SetPlayerLocalData)("JointDrillRecordKey", self.nStartTime)
      ;
      (LocalData.SetPlayerLocalData)("JointDrillRecordFloorId", 0)
      ;
      (LocalData.SetPlayerLocalData)("JointDrillRecordExcludeId", 0)
    end
    if callback ~= nil then
      callback()
    end
  end

  local msg = {BuildId = nBuildId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_continue_req, msg, nil, NetCallback)
end

PlayerJointDrillData_2.JointDrillGameOver = function(self, callback, bSettle)
  -- function num : 0_18 , upvalues : ClientManager, _ENV
  self:SetRecorderExcludeIds()
  self:StopRecord()
  self._EndTime = ClientManager.serverTimeStamp
  local NetCallback = function(_, netMsg)
    -- function num : 0_18_0 , upvalues : self, _ENV, callback, bSettle
    local nScoreOld = 0
    if self.mapSelfRankData ~= nil then
      nScoreOld = (self.mapSelfRankData).Score
    end
    if netMsg.Old ~= netMsg.New then
      self:SendJointDrillRankMsg()
    end
    self:UploadRecordFile(netMsg.Token)
    if not self.bSimulate then
      self.nTotalScore = self.nTotalScore + netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
    end
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList_2)
    self.bResetLevelSelect = true
    if callback ~= nil then
      callback(netMsg)
    end
    if bSettle then
      local nResultType = (AllEnum.JointDrillResultType).ChallengeEnd
      local mapScore = {}
      local nTotalScore = self.nTotalScore
      local mapChange, mapItems = {}, {}
      local nOld, nNew = 0, 0
      if netMsg ~= nil then
        if not netMsg.Change then
          mapChange = {}
        end
        if not netMsg.Items then
          mapItems = {}
        end
        local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
        mapScore = {FightScore = netMsg.FightScore, HpScore = netMsg.HpScore, DifficultyScore = netMsg.DifficultyScore, nTotalScore = nTotalScore, nScore = nScore, nScoreOld = nScoreOld}
        nOld = netMsg.Old
        nNew = netMsg.New
      end
      do
        do
          local mapBossInfo = (self.mapBossInfo)[self.nCurLevel]
          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult_2, nResultType, self.nCurLevel, 0, self.nCurLevelId, mapBossInfo, mapScore, mapItems, mapChange, nOld, nNew, self.bSimulate, #self.tbTeams)
          self:EventUpload(4, 0)
          self:ChallengeEnd()
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_game_over_req, {}, nil, NetCallback)
end

PlayerJointDrillData_2.JointDrillGiveUp = function(self, nLevel, nTime, nDamage, sRecord, callback)
  -- function num : 0_19 , upvalues : _ENV
  self:SetRecorderExcludeIds()
  self:StopRecord()
  local NetCallback = function(_, netMsg)
    -- function num : 0_19_0 , upvalues : self, sRecord, nLevel, callback
    self.record = sRecord
    self.nCurLevel = nLevel
    if callback ~= nil then
      callback(netMsg)
    end
    if netMsg.Old ~= netMsg.New then
      self:SendJointDrillRankMsg()
    end
  end

  local tbBossHps = {}
  local mapBoss = (self.mapBossInfo)[nLevel]
  if mapBoss ~= nil then
    for nIndex,v in ipairs(mapBoss) do
      if v.nBossCfgId ~= 0 then
        (table.insert)(tbBossHps, {Id = v.nBossCfgId, Hp = v.nHp})
      end
    end
  end
  do
    local msg = {Floor = nLevel, Time = nTime, Damage = nDamage, BossHps = tbBossHps, Record = sRecord}
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_give_up_req, msg, nil, NetCallback)
  end
end

PlayerJointDrillData_2.JointDrillRetreat = function(self, mapBuild, callback)
  -- function num : 0_20 , upvalues : _ENV
  self:SetRecorderExcludeIds(true)
  self:StopRecord()
  local NetCallback = function(_, netMsg)
    -- function num : 0_20_0 , upvalues : self, mapBuild, callback
    self:RemoveJointDrillTeam(mapBuild)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_retreat_req, {}, nil, NetCallback)
end

PlayerJointDrillData_2.JointDrillSettle = function(self, mapBuild, nTime, nDamage, callback)
  -- function num : 0_21 , upvalues : ClientManager, _ENV, LocalData
  self:SetRecorderExcludeIds()
  self:StopRecord()
  self:AddJointDrillTeam(mapBuild, nTime, nDamage)
  self._EndTime = ClientManager.serverTimeStamp
  local NetCallback = function(_, netMsg)
    -- function num : 0_21_0 , upvalues : self, _ENV, callback
    self:UploadRecordFile(netMsg.Token)
    do
      if not self.bSimulate then
        local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
        self.nTotalScore = self.nTotalScore + nScore
        ;
        (self.actDataIns):PassedLevel(self.nCurLevelId, nScore)
      end
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList_2)
      self.bResetLevelSelect = true
      if callback ~= nil then
        callback(netMsg)
      end
      if netMsg.Old ~= netMsg.New then
        self:SendJointDrillRankMsg()
      end
      self:EventUpload(4, 1)
    end
  end

  local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
  local tbSamples = (UTILS.GetBattleSamples)(sKey)
  local bSuccess, nCheckSum = (NovaAPI.GetRecorderKey)(sKey)
  local tbSendSample = {Sample = tbSamples, Checksum = nCheckSum}
  local msg = {Time = nTime, Damage = nDamage, Sample = tbSendSample, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).JointDrill, true)}
}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_settle_req, msg, nil, NetCallback)
end

PlayerJointDrillData_2.JointDrillSync = function(self, nLevel, nTime, nDamage, sRecord, callback)
  -- function num : 0_22 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_22_0 , upvalues : self, sRecord, callback
    self.record = sRecord
    if callback ~= nil then
      callback()
    end
  end

  local tbBossHp = {}
  local tbBossHpMax = {}
  if (self.mapBossInfo)[nLevel] ~= nil then
    for nIndex,v in ipairs((self.mapBossInfo)[nLevel]) do
      if v.nBossCfgId ~= 0 then
        (table.insert)(tbBossHp, {Id = v.nBossCfgId, Hp = v.nHp})
        ;
        (table.insert)(tbBossHpMax, {Id = v.nBossCfgId, Hp = v.nHpMax})
      end
    end
  end
  do
    local msg = {Floor = nLevel, Time = nTime, Damage = nDamage, BossHps = tbBossHp, BossHpMaxes = tbBossHpMax, Record = sRecord}
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_2_sync_req, msg, nil, NetCallback)
  end
end

PlayerJointDrillData_2.LevelEnd = function(self, nType)
  -- function num : 0_23 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
  self.nGameTime = 0
  self.mapCurBossInfo = {}
  if nType ~= (AllEnum.JointDrillResultType).Retreat then
    self.nSelectBuildId = 0
  end
end

PlayerJointDrillData_2.ChallengeEnd = function(self)
  -- function num : 0_24 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.bInBattle = false
  self.curLevel = nil
  self.nCurLevelId = 0
  self.nCurLevel = 1
  self.nStartTime = 0
  self.nGameTime = 0
  self.bSimulate = false
  self.record = nil
  self.tbTeams = {}
  self.nSelectBuildId = 0
  self.tbRecordFloors = {}
  self.mapCurBossInfo = {}
  self.mapBossInfo = {}
  if self.challengeTimer ~= nil then
    (self.challengeTimer):Cancel()
    self.challengeTimer = nil
  end
  self._EntryTime = 0
  self._EndTime = 0
end

PlayerJointDrillData_2.ResetRecord = function(self, sRecord)
  -- function num : 0_25
  self.record = sRecord
end

PlayerJointDrillData_2.GetJointDrillLevelId = function(self)
  -- function num : 0_26
  return self.nCurLevelId
end

PlayerJointDrillData_2.GetJointDrillCurLevel = function(self)
  -- function num : 0_27
  return self.nCurLevel
end

PlayerJointDrillData_2.GetJointDrillStartTime = function(self)
  -- function num : 0_28
  return self.nStartTime
end

PlayerJointDrillData_2.GetJointDrillBuildList = function(self)
  -- function num : 0_29
  return self.tbTeams
end

PlayerJointDrillData_2.GetJointDrillBattleCount = function(self)
  -- function num : 0_30
  return #self.tbTeams
end

PlayerJointDrillData_2.CheckChallengeCount = function(self)
  -- function num : 0_31 , upvalues : _ENV
  do
    if self.nCurLevelId ~= 0 then
      local mapLevelCfg = (ConfigTable.GetData)("JointDrill_2_Level", self.nCurLevelId)
      if mapLevelCfg ~= nil then
        if #self.tbTeams < mapLevelCfg.MaxBattleNum then
          return true
        else
          self:JointDrillGameOver()
          return false
        end
      end
      return false
    end
    return true
  end
end

PlayerJointDrillData_2.CheckJointDrillInBattle = function(self)
  -- function num : 0_32
  return self.bInBattle
end

PlayerJointDrillData_2.GetMaxChallengeCount = function(self, nLevelId)
  -- function num : 0_33 , upvalues : _ENV
  local mapLevelCfg = (ConfigTable.GetData)("JointDrill_2_Level", nLevelId)
  if mapLevelCfg ~= nil then
    return mapLevelCfg.MaxBattleNum
  end
  return 0
end

PlayerJointDrillData_2.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_34
  self.nSelectBuildId = nBuildId
end

PlayerJointDrillData_2.GetCachedBuild = function(self)
  -- function num : 0_35
  return self.nSelectBuildId
end

PlayerJointDrillData_2.GetBossHpBarNum = function(self)
  -- function num : 0_36 , upvalues : _ENV
  do
    if self.nCurLevelId ~= nil then
      local mapCfg = (ConfigTable.GetData)("JointDrill_2_Level", self.nCurLevelId)
      if mapCfg ~= nil then
        return mapCfg.HpBarNum
      end
    end
    return 40
  end
end

PlayerJointDrillData_2.AddJointDrillTeam = function(self, mapBuildData, nTime, nDamage)
  -- function num : 0_37 , upvalues : _ENV
  local bInsert = false
  for _,v in ipairs(self.tbTeams) do
    if v.BuildId == mapBuildData.nBuildId then
      bInsert = true
      v.Damage = nDamage
      v.Time = nTime
      break
    end
  end
  do
    if not bInsert then
      local tbChar = {}
      for _,mapChar in ipairs(mapBuildData.tbChar) do
        local nCharId = mapChar.nTid
        local nLv = (PlayerData.Char):GetCharLv(nCharId)
        ;
        (table.insert)(tbChar, {CharId = nCharId, CharLevel = nLv})
      end
      local teamData = {Chars = tbChar, BuildScore = mapBuildData.nScore, Damage = nDamage, Time = nTime, BuildId = mapBuildData.nBuildId}
      ;
      (table.insert)(self.tbTeams, teamData)
    end
  end
end

PlayerJointDrillData_2.RemoveJointDrillTeam = function(self, mapBuildData)
  -- function num : 0_38 , upvalues : _ENV
  local nIndex = 0
  for k,v in ipairs(self.tbTeams) do
    if v.BuildId == mapBuildData.nBuildId then
      nIndex = k
      break
    end
  end
  do
    if nIndex ~= 0 then
      (table.remove)(self.tbTeams, nIndex)
    end
  end
end

PlayerJointDrillData_2.SetGameTime = function(self, nTime)
  -- function num : 0_39
  self.nGameTime = nTime
end

PlayerJointDrillData_2.GetGameTime = function(self)
  -- function num : 0_40
  return self.nGameTime
end

PlayerJointDrillData_2.GetBattleSimulate = function(self)
  -- function num : 0_41
  return self.bSimulate
end

PlayerJointDrillData_2.AddRecordFloorList = function(self)
  -- function num : 0_42 , upvalues : LocalData, _ENV
  local nValue = (LocalData.GetPlayerLocalData)("JointDrillRecordFloorId") or 0
  nValue = nValue + 1
  ;
  (table.insert)(self.tbRecordFloors, nValue)
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordFloorId", nValue)
  ;
  (NovaAPI.SetRecorderFloorId)(nValue)
end

PlayerJointDrillData_2.AddRecordExcludeId = function(self, nId)
  -- function num : 0_43 , upvalues : LocalData
  local nValue = (LocalData.GetPlayerLocalData)("JointDrillRecordExcludeId") or 0
  nValue = 1 << nId - 1 | nValue
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordExcludeId", nValue)
end

PlayerJointDrillData_2.SetRecorderExcludeIds = function(self, bRemove)
  -- function num : 0_44 , upvalues : ListInt, _ENV, LocalData
  local tbFloorId = ListInt()
  if bRemove then
    for _,v in ipairs(self.tbRecordFloors) do
      self:AddRecordExcludeId(v)
    end
  end
  do
    local nExcludeValue = (LocalData.GetPlayerLocalData)("JointDrillRecordExcludeId") or 0
    if nExcludeValue > 0 then
      local tbTemp = {}
      while nExcludeValue > 0 do
        (table.insert)(tbTemp, 1, nExcludeValue % 2)
        nExcludeValue = (math.floor)(nExcludeValue / 2)
      end
      printTable(tbTemp)
      for k,v in ipairs(tbTemp) do
        if v == 1 then
          tbFloorId:Add(#tbTemp - k + 1)
        end
      end
    end
    do
      self.tbRecordFloors = {}
      ;
      (NovaAPI.SetRecorderExcludeIds)(tbFloorId)
    end
  end
end

PlayerJointDrillData_2.StopRecord = function(self)
  -- function num : 0_45 , upvalues : _ENV
  (NovaAPI.StopRecord)()
end

PlayerJointDrillData_2.UploadRecordFile = function(self, sToken)
  -- function num : 0_46 , upvalues : LocalData, _ENV
  local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
  if sKey ~= nil and sKey ~= "" then
    if sToken ~= nil and sToken ~= "" then
      (NovaAPI.UploadStartowerFile)(sToken, sKey)
    else
      ;
      (NovaAPI.DeleteRecFile)(sKey)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordKey", "")
end

PlayerJointDrillData_2.CheckActChallengeTime = function(self)
  -- function num : 0_47 , upvalues : ClientManager
  local nChallengeEndTime = (self.actDataIns):GetChallengeEndTime()
  local nCurTime = ClientManager.serverTimeStamp
  if nChallengeEndTime <= nCurTime then
    return false
  end
  return true
end

PlayerJointDrillData_2.SetResetLevelSelect = function(self, bReset)
  -- function num : 0_48
  self.bResetLevelSelect = bReset
end

PlayerJointDrillData_2.GetResetLevelSelect = function(self)
  -- function num : 0_49
  return self.bResetLevelSelect
end

PlayerJointDrillData_2.SendJointDrillRankMsg = function(self, callback)
  -- function num : 0_50 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_50_0 , upvalues : self, callback
    self.nLastRefreshRankTime = netMsg.LastRefreshTime
    self.mapSelfRankData = netMsg.Self
    self.mapRankList = netMsg.Rank
    self.nTotalRank = netMsg.Total or 0
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_rank_req, {}, nil, NetCallback)
end

PlayerJointDrillData_2.GetSelfRankData = function(self)
  -- function num : 0_51
  return self.mapSelfRankData
end

PlayerJointDrillData_2.GetRankList = function(self)
  -- function num : 0_52
  return self.mapRankList
end

PlayerJointDrillData_2.GetRankRewardCount = function(self)
  -- function num : 0_53
  return self.nRankCount
end

PlayerJointDrillData_2.GetTotalRankCount = function(self)
  -- function num : 0_54
  return self.nTotalRank
end

PlayerJointDrillData_2.GetLastRankRefreshTime = function(self)
  -- function num : 0_55
  return self.nLastRefreshRankTime, self.nRankingRefreshTime
end

PlayerJointDrillData_2.GetTotalRankScore = function(self)
  -- function num : 0_56
  return self.nTotalScore
end

PlayerJointDrillData_2.SendJointDrillSweepMsg = function(self, nLevelId, nCount, callback)
  -- function num : 0_57 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_57_0 , upvalues : self, _ENV, callback
    local mapSelfRank = self:GetSelfRankData()
    local nRank = 0
    local nScoreOld = 0
    if mapSelfRank ~= nil then
      nRank = mapSelfRank.Rank
      nScoreOld = mapSelfRank.Score
    end
    local nTotalScoreOld = self:GetTotalRankScore()
    local nScore = (math.max)(netMsg.Score - nTotalScoreOld, 0)
    local mapScore = {nScore = nScore, nTotalScore = netMsg.Score, nScoreOld = nScoreOld}
    local panelCallback = function()
      -- function num : 0_57_0_0 , upvalues : netMsg, _ENV, callback
      if netMsg.Rewards ~= nil then
        local tabItem = {}
        for k,v in ipairs(netMsg.Rewards) do
          for _,item in ipairs(v.Items) do
            if tabItem[item.Tid] == nil then
              tabItem[item.Tid] = 0
            end
            tabItem[item.Tid] = tabItem[item.Tid] + item.Qty
          end
        end
        local tbShowItem = {}
        for nId,nCount in pairs(tabItem) do
          (table.insert)(tbShowItem, {Tid = nId, Qty = nCount})
        end
        ;
        (UTILS.OpenReceiveByDisplayItem)(tbShowItem, netMsg.Change, callback)
      end
    end

    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillRankUp_2, nRank, nRank, mapScore, (AllEnum.JointDrillResultType).ChallengeEnd, panelCallback)
    self.nTotalScore = netMsg.Score
    self:EventUpload(5)
  end

  local msg = {LevelId = nLevelId, Count = nCount}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_sweep_req, msg, nil, NetCallback)
end

PlayerJointDrillData_2.EventUpload = function(self, action, result)
  -- function num : 0_58 , upvalues : _ENV
  if not result then
    result = ""
  end
  local nCostTime = 0
  if action == 4 then
    nCostTime = self._EndTime - self._EntryTime
  end
  local tabUpLevel = {}
  ;
  (table.insert)(tabUpLevel, {"action", tostring(action)})
  ;
  (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tabUpLevel, {"game_cost_time", tostring(nCostTime)})
  ;
  (table.insert)(tabUpLevel, {"battle_id", tostring(self.nCurLevelId)})
  ;
  (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
  ;
  (table.insert)(tabUpLevel, {"team_num", tostring(#self.tbTeams)})
  ;
  (table.insert)(tabUpLevel, {"simulate", tostring(self.bSimulate and 1 or 0)})
  ;
  (NovaAPI.UserEventUpload)("joint_drill_battle", tabUpLevel)
end

return PlayerJointDrillData_2

