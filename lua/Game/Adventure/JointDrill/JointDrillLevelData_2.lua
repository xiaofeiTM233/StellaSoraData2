local JointDrillLevelData_2 = class("JointDrillLevelData_2")
local FP = (CS.TrueSync).FP
local PB = require("pb")
local AdventureModuleHelper = CS.AdventureModuleHelper
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", JointDrill_StartTiming = "OnEvent_BattleStart", JointDrill_MonsterSpawn_Type2 = "OnEvent_MonsterSpawn", JointDrill_BossDeath_Type2 = "OnEvent_BossDeath", JointDrill_BattleLvsToggle_Type2 = "OnEvent_BattleLvsToggle", ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete", JointDrill_Gameplay_Time = "OnEvent_JointDrill_Gameplay_Time", JointDrill_DamageValue = "OnEvent_DamageValue", JointDrill_CharDamageValue = "OnEvent_CharDamageValue", GiveUpJointDrill = "OnEvent_GiveUpBattle", RestartJointDrill = "OnEvent_RestartJointDrill", RetreatJointDrill = "OnEvent_RetreatJointDrill", JointDrill_Result = "OnEvent_JointDrill_Result", InputEnable = "OnEvent_InputEnable", JointDrill_StopTime = "OnEvent_JointDrill_StopTime", JointDrillChallengeFinishError = "OnEvent_JointDrillChallengeFinishError", Upload_Dodge_Event = "OnEvent_UploadDodgeEvent", JointDrill_CacheTempData_Suc = "OnEvent_CacheTempData"}
JointDrillLevelData_2.Init = function(self, parent, nLevelId, nBuildId, nCurLevel, nLevelType)
  -- function num : 0_0 , upvalues : _ENV, AdventureModuleHelper, LocalData
  self.parent = parent
  self.nLevelId = nLevelId
  self.nCurLevel = nCurLevel
  self.nBuildId = nBuildId
  self.nLevelType = nLevelType
  self.recordCallback = nil
  self.mapLevel = nil
  self.tbFloor = {}
  self.mapFloor = nil
  self.nGameTime = (self.parent):GetGameTime()
  self.bInResult = false
  self.bChangeLevel = self.nLevelType == (AllEnum.JointDrillLevelStartType).ChangeLevel
  self.bRestart = self.nLevelType == (AllEnum.JointDrillLevelStartType).Restart
  if not self.bChangeLevel then
    self.nDamageValue = 0
    self.tbCharDamage = {}
    self.mapInitBossInfo = clone((self.parent):GetBossInfo())
    self.nInitLevel = self.nCurLevel
    if (self.parent).record ~= nil and (self.parent).record ~= "" then
      self.initRecord = (self.parent).record
    end
  end
  local mapJointDrillLevelCfg = (ConfigTable.GetData)("JointDrill_2_Level", nLevelId)
  if mapJointDrillLevelCfg == nil then
    return 
  end
  self.mapLevel = mapJointDrillLevelCfg
  local nFloorGroup = mapJointDrillLevelCfg.FloorId
  self.tbFloor = (CacheTable.GetData)("_JointDrill_2_Floor", nFloorGroup)
  self.mapFloor = (self.tbFloor)[nCurLevel]
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, AdventureModuleHelper, LocalData
    self.mapBuildData = mapBuildData
    ;
    (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
    self.tbCharId = {}
    for _,mapChar in ipairs((self.mapBuildData).tbChar) do
      (table.insert)(self.tbCharId, mapChar.nTid)
    end
    self.tbDiscId = {}
    for _,nDiscId in pairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    if #self.tbCharDamage == 0 then
      for _,v in ipairs(self.tbCharId) do
        (table.insert)(self.tbCharDamage, {nCharId = v, nDamage = 0})
      end
    end
    do
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R1 in 'UnsetPending'

      PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).JointDrill
      local sRecord = (self.parent).record or ""
      local mapParams = {tostring(self.nCurLevel), tostring(self.bChangeLevel), tostring(self.nGameTime), sRecord}
      if not self.bChangeLevel and not self.bRestart then
        (AdventureModuleHelper.EnterDynamic)(self.nLevelId, self.tbCharId, (GameEnum.dynamicLevelType).JointDrill_2, mapParams)
        ;
        (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
      else
        self:StartJointDrill()
        ;
        (AdventureModuleHelper.EnterDynamic)(self.nLevelId, self.tbCharId, (GameEnum.dynamicLevelType).JointDrill_2, mapParams)
      end
      local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
      safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, sKey)
    end
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

JointDrillLevelData_2.BindEvent = function(self)
  -- function num : 0_1 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

JointDrillLevelData_2.UnBindEvent = function(self)
  -- function num : 0_2 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

JointDrillLevelData_2.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_3 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

JointDrillLevelData_2.SetPersonalPerk = function(self)
  -- function num : 0_4 , upvalues : _ENV, AdventureModuleHelper
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapAddLevel = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
      local tbPerkInfo = {}
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nAddLv = mapAddLevel[mapPerkInfo.nPotentialId] or 0
        local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
        stPerkInfo.perkId = mapPerkInfo.nPotentialId
        stPerkInfo.nCount = mapPerkInfo.nLevel + nAddLv
        ;
        (table.insert)(tbPerkInfo, stPerkInfo)
      end
      safe_call_cs_func(AdventureModuleHelper.ChangePersonalPerkIds, tbPerkInfo, nCharId)
    end
  end
end

JointDrillLevelData_2.SetDiscInfo = function(self)
  -- function num : 0_5 , upvalues : _ENV, AdventureModuleHelper
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = (PlayerData.Disc):CalcDiscInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func(AdventureModuleHelper.SetDiscInfo, tbDiscInfo)
end

JointDrillLevelData_2.GetSyncGameTime = function(self, nTime)
  -- function num : 0_6 , upvalues : _ENV
  return (math.floor)(tonumber((string.format)("%.3f", nTime)) * 1000)
end

JointDrillLevelData_2.JointDrillSuccess = function(self, netMsg)
  -- function num : 0_7 , upvalues : _ENV, AdventureModuleHelper
  local tbSkin = {}
  for _,nCharId in ipairs(self.tbCharId) do
    local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
    ;
    (table.insert)(tbSkin, nSkinId)
  end
  local nScoreOld = 0
  local mapSelfRank = (self.parent):GetSelfRankData()
  if mapSelfRank ~= nil then
    nScoreOld = mapSelfRank.Score
  end
  local func_SettlementFinish = function()
    -- function num : 0_7_0
  end

  local levelEndCallback = function()
    -- function num : 0_7_1 , upvalues : _ENV, self, levelEndCallback, AdventureModuleHelper, tbSkin, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nType = (self.mapFloor).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    print("sceneName:" .. sName)
    ;
    (AdventureModuleHelper.PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  local openBattleResultPanel = function()
    -- function num : 0_7_2 , upvalues : _ENV, self, openBattleResultPanel, netMsg, nScoreOld
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    local nResultType = (AllEnum.JointDrillResultType).Success
    local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
    local mapScore = {FightScore = netMsg.FightScore, HpScore = netMsg.HpScore, DifficultyScore = netMsg.DifficultyScore, nTotalScore = (self.parent).nTotalScore, nScore = nScore, nScoreOld = nScoreOld}
    local bSimulate = (self.parent):GetBattleSimulate()
    local nBattleCount = (self.parent):GetJointDrillBattleCount()
    if netMsg.Items or not netMsg.Change then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult_2, nResultType, self.nCurLevel, 0, self.nLevelId, {}, mapScore, {}, {}, netMsg.Old, netMsg.New, bSimulate, nBattleCount, self.tbCharDamage)
      ;
      (self.parent):ChallengeEnd()
    end
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  (AdventureModuleHelper.LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

JointDrillLevelData_2.CheckJointDrillGameOver = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local nChallengeCount = (self.parent):GetJointDrillBattleCount()
  local nAllChallengeCount = (self.parent):GetMaxChallengeCount(self.nLevelId)
  if nAllChallengeCount <= nChallengeCount then
    local callback = function(netMsg)
    -- function num : 0_8_0 , upvalues : self, _ENV
    self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd, netMsg, self.nCurLevel)
  end

    ;
    (self.parent):JointDrillGameOver(callback)
  else
    do
      self.recordCallback = function(sRecord)
    -- function num : 0_8_1 , upvalues : self, _ENV
    local callback = function(netMsg)
      -- function num : 0_8_1_0 , upvalues : self, _ENV
      self:JointDrillFail((AllEnum.JointDrillResultType).BattleEnd, netMsg, self.nCurLevel)
    end

    ;
    (self.parent):JointDrillGiveUp(self.nCurLevel, self.nGameTime, self.nDamageValue, sRecord, callback)
  end

      ;
      (NovaAPI.DispatchEventWithData)("JointDrill_CacheTempData_Start", nil, {false, true, true, false, 0, 0})
    end
  end
end

JointDrillLevelData_2.JointDrillFail = function(self, nResultType, netMsg, nLevel)
  -- function num : 0_9 , upvalues : _ENV
  local bossInfo = {}
  local mapAllBossInfo = (self.parent):GetBossInfo()
  local mapCurBossInfo = mapAllBossInfo[nLevel]
  for nIndex,v in ipairs(mapCurBossInfo) do
    if v.nBossCfgId ~= 0 then
      (table.insert)(bossInfo, {nBossId = v.nBossCfgId, nHp = v.nHp, nHpMax = v.nHpMax})
    end
  end
  local bSimulate = (self.parent):GetBattleSimulate()
  local nBattleCount = (self.parent):GetJointDrillBattleCount()
  local mapScore = {}
  local mapReward = {}
  local mapChange = {}
  local nOld, nNew = 0, 0
  local nScoreOld = 0
  local mapSelfRank = (self.parent):GetSelfRankData()
  if mapSelfRank ~= nil then
    nScoreOld = mapSelfRank.Score
  end
  do
    if netMsg ~= nil then
      local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
      mapScore = {FightScore = netMsg.FightScore, HpScore = netMsg.HpScore, DifficultyScore = netMsg.DifficultyScore, nTotalScore = (self.parent).nTotalScore, nScore = nScore, nScoreOld = nScoreOld}
      nOld = netMsg.Old
      nNew = netMsg.New
      if not netMsg.Items then
        mapReward = {}
      end
      if not netMsg.Change then
        mapChange = {}
      end
    end
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult_2, nResultType, self.nCurLevel, self.nGameTime, self.nLevelId, bossInfo, mapScore, mapReward, mapChange, nOld, nNew, bSimulate, nBattleCount, self.tbCharDamage)
    ;
    (self.parent):LevelEnd(nResultType)
  end
end

JointDrillLevelData_2.JointDrillTimeOut = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if self.bInResult then
    return 
  end
  self.bInResult = true
  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_Level_TimeOut")
  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_CacheTempData_Start", nil, {false, true, true, true, 0, 0})
  local syncCallback = function()
    -- function num : 0_10_0 , upvalues : self, _ENV
    local callback = function(netMsg)
      -- function num : 0_10_0_0 , upvalues : self, _ENV
      self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd, netMsg, self.nCurLevel)
    end

    ;
    (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
    ;
    (self.parent):JointDrillGameOver(callback)
  end

  ;
  (self.parent):JointDrillSync(self.nCurLevel, self.nGameTime, self.nDamageValue, "", syncCallback)
end

JointDrillLevelData_2.SyncGameTime = function(self, nTime)
  -- function num : 0_11 , upvalues : _ENV
  if not nTime then
    nTime = 0
  end
  self.nGameTime = (math.min)(self:GetSyncGameTime(nTime), (self.mapLevel).BattleTime * 1000)
  ;
  (self.parent):SetGameTime(self.nGameTime)
  ;
  (EventManager.Hit)("RefreshJointDrillGameTime", self.nGameTime)
end

JointDrillLevelData_2.StartJointDrill = function(self)
  -- function num : 0_12 , upvalues : _ENV, AdventureModuleHelper
  (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillBattlePanel, self.tbCharId, (self.mapLevel).Id, (self.mapLevel).BattleTime, (GameEnum.JointDrillMode).JointDrill_Mode_2)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func(AdventureModuleHelper.SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

JointDrillLevelData_2.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_13 , upvalues : _ENV, AdventureModuleHelper
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func(AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  ;
  (self.parent):AddRecordFloorList()
  ;
  (PlayerData.Build):SetBuildReportInfo((self.mapBuildData).nBuildId)
  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_ResetCharacter")
end

JointDrillLevelData_2.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_14
  self:StartJointDrill()
end

JointDrillLevelData_2.OnEvent_BattleStart = function(self, nTime)
  -- function num : 0_15
  self:SyncGameTime(nTime)
end

JointDrillLevelData_2.OnEvent_MonsterSpawn = function(self, nBossId, nCfgId, nIndex, nHp, nHpMax)
  -- function num : 0_16 , upvalues : _ENV
  if self.nLevelType ~= (AllEnum.JointDrillLevelStartType).Start then
    return 
  end
  self.recordCallback = function(sRecord)
    -- function num : 0_16_0 , upvalues : self
    (self.parent):JointDrillSync(self.nCurLevel, self.nGameTime, self.nDamageValue, sRecord)
    self.initRecord = sRecord
  end

  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_CacheTempData_Start", nil, {true, true, true, false, 0, 0})
end

JointDrillLevelData_2.OnEvent_BossDeath = function(self, nBattleLv, nTotalTime, nDamageValue, nParam)
  -- function num : 0_17 , upvalues : _ENV
  if nBattleLv < self.nCurLevel then
    return 
  end
  local nLastLevel = self.nCurLevel
  nTotalTime = (math.min)((self.mapLevel).BattleTime * 1000, self:GetSyncGameTime(nTotalTime))
  self.nCurLevel = nParam
  self.nDamageValue = self.nDamageValue + nDamageValue
  self.mapFloor = (self.tbFloor)[self.nCurLevel]
  ;
  (self.parent):AddJointDrillTeam(self.mapBuildData, nTotalTime, self.nDamageValue)
  ;
  (PanelManager.InputDisable)()
  ;
  (self.parent):StopRecord()
  self.recordCallback = function(sRecord)
    -- function num : 0_17_0 , upvalues : _ENV, self, nTotalTime
    local syncCallback = function()
      -- function num : 0_17_0_0 , upvalues : _ENV
      (PanelManager.InputEnable)()
      local wait = function()
        -- function num : 0_17_0_0_0 , upvalues : _ENV
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        (EventManager.Hit)(EventId.BattleDashboardVisible, false)
      end

      ;
      (cs_coroutine.start)(wait)
    end

    ;
    (self.parent):JointDrillSync(self.nCurLevel, nTotalTime, self.nDamageValue, sRecord, syncCallback)
  end

  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_CacheTempData_Start", nil, {true, true, false, true, nLastLevel, nParam})
end

JointDrillLevelData_2.OnEvent_BattleLvsToggle = function(self)
  -- function num : 0_18 , upvalues : AdventureModuleHelper, _ENV
  self.bChangeLevel = true
  self.bRestart = false
  ;
  (AdventureModuleHelper.LevelStateChanged)(false)
  ;
  (EventManager.Hit)("ResetBossHUD")
end

JointDrillLevelData_2.OnEvent_UnloadComplete = function(self)
  -- function num : 0_19
  if self.bInResult == true then
    return 
  end
  if self.bRestart then
    (self.parent):RestartBattle()
  else
    ;
    (self.parent):ChangeLevel(self.nCurLevel)
  end
end

JointDrillLevelData_2.OnEvent_JointDrill_Gameplay_Time = function(self, nTime)
  -- function num : 0_20
  self:SyncGameTime(nTime)
end

JointDrillLevelData_2.OnEvent_Pause = function(self)
  -- function num : 0_21 , upvalues : _ENV
  (EventManager.Hit)("OpenJointDrillPause", self.nLevelId, self.tbCharId, self.nGameTime)
end

JointDrillLevelData_2.OnEvent_DamageValue = function(self, nDamageValue)
  -- function num : 0_22
  self.nDamageValue = self.nDamageValue + nDamageValue
end

JointDrillLevelData_2.OnEvent_GiveUpBattle = function(self)
  -- function num : 0_23
  (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
  self:CheckJointDrillGameOver()
end

JointDrillLevelData_2.OnEvent_RestartJointDrill = function(self)
  -- function num : 0_24 , upvalues : AdventureModuleHelper, _ENV
  self.bRestart = true
  self.bChangeLevel = false
  ;
  (self.parent):SetGameTime(0)
  ;
  (self.parent):ResetRecord(self.initRecord)
  ;
  (self.parent):ResetBossInfo(self.mapInitBossInfo)
  ;
  (self.parent):SetRecorderExcludeIds(true)
  ;
  (AdventureModuleHelper.LevelStateChanged)(false)
  ;
  (EventManager.Hit)("ResetBossHUD")
end

JointDrillLevelData_2.OnEvent_RetreatJointDrill = function(self)
  -- function num : 0_25 , upvalues : _ENV
  local callback = function()
    -- function num : 0_25_0 , upvalues : self, _ENV
    (self.parent):ResetRecord(self.initRecord)
    ;
    (self.parent):ResetBossInfo(self.mapInitBossInfo)
    self:JointDrillFail((AllEnum.JointDrillResultType).Retreat, nil, self.nInitLevel)
  end

  ;
  (self.parent):JointDrillRetreat(self.mapBuildData, callback)
end

JointDrillLevelData_2.OnEvent_JointDrill_Result = function(self, nLevelState, nTotalTime, nDamageValue)
  -- function num : 0_26 , upvalues : _ENV
  if self.bInResult then
    return 
  end
  nTotalTime = (math.min)((self.mapLevel).BattleTime * 1000, self:GetSyncGameTime(nTotalTime))
  self.bInResult = true
  self.nDamageValue = self.nDamageValue + nDamageValue
  if nLevelState == (GameEnum.levelState).Failed then
    (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
    self:CheckJointDrillGameOver()
  else
    if nLevelState == (GameEnum.levelState).Success then
      local callback = function(netMsg)
    -- function num : 0_26_0 , upvalues : self
    self:JointDrillSuccess(netMsg)
  end

      ;
      (self.parent):JointDrillSettle(self.mapBuildData, self.nGameTime, self.nDamageValue, callback)
    end
  end
end

JointDrillLevelData_2.OnEvent_CharDamageValue = function(self, charDamageValue)
  -- function num : 0_27 , upvalues : _ENV
  for nCharId,nValue in pairs(charDamageValue) do
    for _,v in ipairs(self.tbCharDamage) do
      if v.nCharId == nCharId then
        v.nDamage = v.nDamage + nValue
        break
      end
    end
  end
end

JointDrillLevelData_2.OnEvent_InputEnable = function(self, bEnable)
  -- function num : 0_28
end

JointDrillLevelData_2.OnEvent_JointDrill_StopTime = function(self)
  -- function num : 0_29
end

JointDrillLevelData_2.OnEvent_JointDrillChallengeFinishError = function(self)
  -- function num : 0_30 , upvalues : _ENV
  local callback = function()
    -- function num : 0_30_0 , upvalues : self, _ENV
    if (self.parent):CheckJointDrillInBattle() then
      (self.parent):JointDrillGameOver(nil, true)
    else
      self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd, nil, self.nCurLevel)
      local wait = function()
      -- function num : 0_30_0_0 , upvalues : _ENV, self
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (self.parent):SetResetLevelSelect(true)
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList_2)
    end

      ;
      (cs_coroutine.start)(wait)
      ;
      (self.parent):ChallengeEnd()
    end
  end

  ;
  (PlayerData.Activity):SendActivityDetailMsg(callback, true)
end

JointDrillLevelData_2.OnEvent_UploadDodgeEvent = function(self, padMode)
  -- function num : 0_31 , upvalues : _ENV
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tab, {"pad_mode", padMode})
  ;
  (table.insert)(tab, {"level_type", "JointDrill"})
  ;
  (table.insert)(tab, {"build_id", tostring(self.nBuildId)})
  ;
  (table.insert)(tab, {"level_id", tostring(self.nLevelId)})
  ;
  (table.insert)(tab, {"up_time", tostring(((CS.ClientManager).Instance).serverTimeStamp)})
  ;
  (NovaAPI.UserEventUpload)("use_dodge_key", tab)
end

JointDrillLevelData_2.OnEvent_CacheTempData = function(self, sJson, nLength, mapBossInfo)
  -- function num : 0_32
  (self.parent):ResetRecord(sJson)
  ;
  (self.parent):UpdateBossInfo(mapBossInfo)
  if self.recordCallback ~= nil then
    (self.recordCallback)(sJson)
    self.recordCallback = nil
  end
end

return JointDrillLevelData_2

