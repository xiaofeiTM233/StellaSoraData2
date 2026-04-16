local JointDrillLevelData_1 = class("JointDrillLevelData_1")
local FP = (CS.TrueSync).FP
local PB = require("pb")
local AdventureModuleHelper = CS.AdventureModuleHelper
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", JointDrill_StartTiming = "OnEvent_BattleStart", JointDrill_MonsterSpawn = "OnEvent_MonsterSpawn", JointDrill_BattleLvsToggle = "OnEvent_BattleLvsToggle", ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete", JointDrill_Gameplay_Time = "OnEvent_JointDrill_Gameplay_Time", JointDrill_DamageValue = "OnEvent_DamageValue", JointDrill_CharDamageValue = "OnEvent_CharDamageValue", GiveUpJointDrill = "OnEvent_GiveUpBattle", RestartJointDrill = "OnEvent_RestartJointDrill", RetreatJointDrill = "OnEvent_RetreatJointDrill", JointDrill_Result = "OnEvent_JointDrill_Result", InputEnable = "OnEvent_InputEnable", JointDrill_StopTime = "OnEvent_JointDrill_StopTime", JointDrillChallengeFinishError = "OnEvent_JointDrillChallengeFinishError", Upload_Dodge_Event = "OnEvent_UploadDodgeEvent"}
JointDrillLevelData_1.Init = function(self, parent, nLevelId, nBuildId, nCurLevel, nLevelType)
  -- function num : 0_0 , upvalues : _ENV, AdventureModuleHelper, LocalData
  self.parent = parent
  self.nLevelId = nLevelId
  self.nCurLevel = nCurLevel
  self.nBuildId = nBuildId
  self.nLevelType = nLevelType
  self.bChangeLevel = self.nLevelType == (AllEnum.JointDrillLevelStartType).ChangeLevel
  self.bRestart = self.nLevelType == (AllEnum.JointDrillLevelStartType).Restart
  self.mapLevel = nil
  self.tbFloor = {}
  self.mapFloor = nil
  self.nGameTime = (self.parent):GetGameTime()
  self.bInResult = false
  if not self.bChangeLevel then
    self.nDamageValue = 0
    self.tbCharDamage = {}
    self.mapActorInfo = nil
  end
  self.mapTempData = {}
  if (self.parent).record ~= nil and (self.parent).record ~= "" then
    self.mapTempData = (self.parent):DecodeTempDataJson()
    if not self.bChangeLevel then
      self.mapInitTempData = clone(self.mapTempData)
    end
  end
  if self.mapInitTempData == nil then
    self.mapInitTempData = {}
  end
  local mapJointDrillLevelData_1 = (ConfigTable.GetData)("JointDrillLevel", nLevelId)
  if mapJointDrillLevelData_1 == nil then
    return 
  end
  self.mapLevel = mapJointDrillLevelData_1
  local nFloorGroup = mapJointDrillLevelData_1.FloorId
  self.tbFloor = (CacheTable.GetData)("_JointDrillFloor", nFloorGroup)
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
      local mapParams = {tostring(self.nCurLevel), tostring(self.bChangeLevel), tostring(self.nGameTime)}
      if not self.bChangeLevel and not self.bRestart then
        (AdventureModuleHelper.EnterDynamic)(self.nLevelId, self.tbCharId, (GameEnum.dynamicLevelType).JointDrill, mapParams)
        ;
        (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
      else
        self:StartJointDrill()
        ;
        (AdventureModuleHelper.EnterDynamic)(self.nLevelId, self.tbCharId, (GameEnum.dynamicLevelType).JointDrill, mapParams)
      end
      local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
      safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, sKey)
    end
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

JointDrillLevelData_1.BindEvent = function(self)
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

JointDrillLevelData_1.UnBindEvent = function(self)
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

JointDrillLevelData_1.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_3 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

JointDrillLevelData_1.SetPersonalPerk = function(self)
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

JointDrillLevelData_1.SetDiscInfo = function(self)
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

JointDrillLevelData_1.GetSyncGameTime = function(self, nTime)
  -- function num : 0_6 , upvalues : _ENV
  return (math.floor)(tonumber((string.format)("%.3f", nTime)) * 1000)
end

JointDrillLevelData_1.CacheTempData = function(self, bCharacter, bBoss, bChangeTeam, bChangeLevel, bLockBossHp)
  -- function num : 0_7 , upvalues : AdventureModuleHelper, _ENV, FP, PB
  if not bCharacter and not bBoss then
    return 
  end
  self.mapTempData = {}
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.mapTempData).mapCharacterTempData = {}
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.mapTempData).mapBossTempData = {}
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R6 in 'UnsetPending'

  if bCharacter then
    ((self.mapTempData).mapCharacterTempData).hpInfo = {}
    -- DECOMPILER ERROR at PC22: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).skillInfo = {}
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).effectInfo = {}
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).buffInfo = {}
    -- DECOMPILER ERROR at PC34: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).stateInfo = {}
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).ammoInfo = {}
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).sommonInfo = (AdventureModuleHelper.GetSummonMonsterInfos)()
    self.mapActorInfo = self:GetActorHp()
    -- DECOMPILER ERROR at PC50: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapTempData).mapCharacterTempData).hpInfo = self.mapActorInfo
    local playerids = (AdventureModuleHelper.GetCurrentGroupPlayers)()
    local Count = playerids.Count - 1
    for i = 0, Count do
      local charTid = (AdventureModuleHelper.GetCharacterId)(playerids[i])
      local clsSkillId = (AdventureModuleHelper.GetPlayerSkillCd)(playerids[i])
      local nStatus = (AdventureModuleHelper.GetPlayerActorStatus)(playerids[i])
      local nStatusTime = (AdventureModuleHelper.GetPlayerActorSpecialStatusTime)(playerids[i])
      local tbAmmo = (AdventureModuleHelper.GetPlayerActorAmmoCount)(playerids[i])
      local nAmmoType = (AdventureModuleHelper.GetPlayerActorAmmoType)(playerids[i])
      local jsonString = (AdventureModuleHelper.GetPlayerActorLocalDataJson)(playerids[i])
      print((string.format)("Status:%d,Time:%d", nStatus, nStatusTime))
      if clsSkillId ~= nil then
        local tbSkillInfos = clsSkillId.skillInfos
        local nSkillCount = tbSkillInfos.Count - 1
        for j = 0, nSkillCount do
          local clsSkillInfo = tbSkillInfos[j]
          local mapSkill = (ConfigTable.GetData_Skill)(clsSkillInfo.skillId)
          if mapSkill == nil then
            return 
          end
          if not mapSkill.IsCleanSkillCD then
            (table.insert)(((self.mapTempData).mapCharacterTempData).skillInfo, {nCharId = charTid, nSkillId = clsSkillInfo.skillId, nCd = (FP.ToInt)(clsSkillInfo.currentUseInterval), nSectionAmount = clsSkillInfo.currentSectionAmount, nSectionResumeTime = (FP.ToInt)(clsSkillInfo.currentResumeTime), nUseTimeHint = (FP.ToInt)(clsSkillInfo.currentUseTimeHint), nEnergy = (FP.ToInt)(clsSkillInfo.currentEnergy)})
          end
        end
      end
      do
        -- DECOMPILER ERROR at PC143: Confused about usage of register: R19 in 'UnsetPending'

        ;
        (((self.mapTempData).mapCharacterTempData).effectInfo)[charTid] = {
mapEffect = {}
}
        local tbClsEfts = (AdventureModuleHelper.GetEffectList)(playerids[i])
        if tbClsEfts ~= nil then
          local nEftCount = tbClsEfts.Count - 1
          for k = 0, nEftCount do
            local eftInfo = tbClsEfts[k]
            local mapEft = (ConfigTable.GetData_Effect)((eftInfo.effectConfig).Id)
            if mapEft == nil then
              return 
            end
            local nCd = (eftInfo.CD).RawValue
            -- DECOMPILER ERROR at PC179: Confused about usage of register: R28 in 'UnsetPending'

            if mapEft.Remove then
              (((((self.mapTempData).mapCharacterTempData).effectInfo)[charTid]).mapEffect)[(eftInfo.effectConfig).Id] = {nCount = 0, nCd = nCd}
            end
          end
        end
        do
          if self.mapEffectTriggerCount ~= nil then
            for nEftId,nCount in pairs(self.mapEffectTriggerCount) do
              -- DECOMPILER ERROR at PC204: Confused about usage of register: R25 in 'UnsetPending'

              if (((((self.mapTempData).mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] == nil then
                (((((self.mapTempData).mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] = {nCount = nCount, nCd = 0}
              else
                -- DECOMPILER ERROR at PC212: Confused about usage of register: R25 in 'UnsetPending'

                ;
                ((((((self.mapTempData).mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId]).nCount = nCount
              end
            end
          end
          do
            local tbBuffInfo = (AdventureModuleHelper.GetEntityBuffList)(playerids[i])
            -- DECOMPILER ERROR at PC222: Confused about usage of register: R21 in 'UnsetPending'

            ;
            (((self.mapTempData).mapCharacterTempData).buffInfo)[charTid] = {}
            if tbBuffInfo ~= nil then
              local nBuffCount = tbBuffInfo.Count - 1
              for l = 0, nBuffCount do
                local eftInfo = tbBuffInfo[l]
                local mapBuff = (ConfigTable.GetData_Buff)((eftInfo.buffConfig).Id)
                if mapBuff == nil then
                  return 
                end
                if mapBuff.NotRemove then
                  (table.insert)((((self.mapTempData).mapCharacterTempData).buffInfo)[charTid], {Id = (eftInfo.buffConfig).Id, CD = (eftInfo:GetBuffLeftTime()).RawValue, nNum = eftInfo:GetBuffNum()})
                end
              end
            end
            do
              do
                -- DECOMPILER ERROR at PC269: Confused about usage of register: R21 in 'UnsetPending'

                ;
                (((self.mapTempData).mapCharacterTempData).stateInfo)[charTid] = {nState = nStatus, nStateTime = nStatusTime, jsonStr = jsonString}
                -- DECOMPILER ERROR at PC276: Confused about usage of register: R21 in 'UnsetPending'

                if tbAmmo ~= nil then
                  (((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid] = {}
                  -- DECOMPILER ERROR at PC281: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nCurAmmo = nAmmoType
                  -- DECOMPILER ERROR at PC287: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmo1 = tbAmmo[0]
                  -- DECOMPILER ERROR at PC293: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmo2 = tbAmmo[1]
                  -- DECOMPILER ERROR at PC299: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmo3 = tbAmmo[2]
                  -- DECOMPILER ERROR at PC305: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax1 = tbAmmo[3]
                  -- DECOMPILER ERROR at PC311: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax2 = tbAmmo[4]
                  -- DECOMPILER ERROR at PC317: Confused about usage of register: R21 in 'UnsetPending'

                  ;
                  ((((self.mapTempData).mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax3 = tbAmmo[5]
                end
                -- DECOMPILER ERROR at PC327: Confused about usage of register: R21 in 'UnsetPending'

                if charTid == (self.tbCharId)[1] then
                  ((self.mapTempData).mapCharacterTempData).shieldList = (AdventureModuleHelper.GetEntityShieldList)(playerids[i])
                end
                -- DECOMPILER ERROR at PC328: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC328: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC328: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC328: LeaveBlock: unexpected jumping out DO_STMT

              end
            end
          end
        end
      end
    end
  end
  do
    if bBoss then
      local bSaveEnergyValue = false
      local bSaveResilience = false
      if bChangeLevel then
        bSaveEnergyValue = (self.mapFloor).SaveEnergyValue
        bSaveResilience = (self.mapFloor).SaveResilience
      else
        if bChangeTeam then
          bSaveEnergyValue = (self.mapFloor).TeamSaveEnergyValue
          bSaveResilience = (self.mapFloor).TeamSaveResilience
        end
      end
      ;
      (EventManager.HitEntityEvent)("RefreshBossEnergyValueHUD", self.nBossId, bSaveEnergyValue)
      -- DECOMPILER ERROR at PC359: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self.mapTempData).mapBossTempData = (AdventureModuleHelper.GetJointDrillBossData)(self.nBossId, bChangeTeam, bSaveEnergyValue, bSaveResilience)
      -- DECOMPILER ERROR at PC369: Confused about usage of register: R8 in 'UnsetPending'

      if bLockBossHp then
        if ((self.mapTempData).mapBossTempData).nHp <= 0 then
          ((self.mapTempData).mapBossTempData).nHp = 1
        end
        -- DECOMPILER ERROR at PC377: Confused about usage of register: R8 in 'UnsetPending'

        if ((self.mapTempData).mapBossTempData).nHpMax <= 0 then
          ((self.mapTempData).mapBossTempData).nHpMax = 1
        end
      end
    end
    do
      local data, nDataLength = (self.parent):EncodeTempDataJson(self.mapTempData)
      print("temp数据长度�?" .. #data)
      local msgInt = "proto.I32"
      local msgLength = {Value = #data}
      local dataLength = assert((PB.encode)(msgInt, msgLength))
      local dataNew = dataLength .. data
      print("temp数据total长度�?" .. #dataNew)
      return data, nDataLength
    end
  end
end

JointDrillLevelData_1.SetActorHP = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local tbActorInfo = {}
  if self.mapActorInfo == nil then
    return 
  end
  for nTid,nHp in pairs(self.mapActorInfo) do
    local stCharInfo = (CS.Lua2CSharpInfo_ActorAttribute)()
    stCharInfo.actorID = nTid
    stCharInfo.curHP = nHp
    ;
    (table.insert)(tbActorInfo, stCharInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).ResetActorAttributes, tbActorInfo)
end

JointDrillLevelData_1.ResetBuff = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local ret = {}
  if (self.mapTempData).mapCharacterTempData ~= nil and ((self.mapTempData).mapCharacterTempData).buffInfo ~= nil then
    for nCharId,mapBuff in pairs(((self.mapTempData).mapCharacterTempData).buffInfo) do
      for _,mapBuffInfo in ipairs(mapBuff) do
        local stBuffInfo = (CS.Lua2CSharpInfo_ResetBuffInfo)()
        stBuffInfo.Id = mapBuffInfo.Id
        stBuffInfo.Cd = mapBuffInfo.CD
        stBuffInfo.buffNum = mapBuffInfo.nNum
        if ret[nCharId] == nil then
          ret[nCharId] = {}
        end
        ;
        (table.insert)(ret[nCharId], stBuffInfo)
      end
    end
  end
  do
    safe_call_cs_func((CS.AdventureModuleHelper).ResetBuff, ret)
  end
end

JointDrillLevelData_1.ResetSkill = function(self)
  -- function num : 0_10 , upvalues : _ENV, FP
  local ret = {}
  if (self.mapTempData).mapCharacterTempData ~= nil and ((self.mapTempData).mapCharacterTempData).skillInfo ~= nil then
    for _,skillInfo in ipairs(((self.mapTempData).mapCharacterTempData).skillInfo) do
      local stSkillInfo = (CS.Lua2CSharpInfo_ResetSkillInfo)()
      stSkillInfo.skillId = skillInfo.nSkillId
      stSkillInfo.currentSectionAmount = skillInfo.nSectionAmount
      stSkillInfo.cd = ((FP.FromFloat)(skillInfo.nCd)).RawValue
      stSkillInfo.currentResumeTime = ((FP.FromFloat)(skillInfo.nSectionResumeTime)).RawValue
      stSkillInfo.currentUseTimeHint = ((FP.FromFloat)(skillInfo.nUseTimeHint)).RawValue
      stSkillInfo.energy = ((FP.FromFloat)(skillInfo.nEnergy)).RawValue
      if ret[skillInfo.nCharId] == nil then
        ret[skillInfo.nCharId] = {}
      end
      ;
      (table.insert)(ret[skillInfo.nCharId], stSkillInfo)
    end
  end
  do
    safe_call_cs_func((CS.AdventureModuleHelper).ResetActorSkillInfo, ret)
  end
end

JointDrillLevelData_1.ResetAmmo = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if (self.mapTempData).mapCharacterTempData ~= nil and ((self.mapTempData).mapCharacterTempData).ammoInfo ~= nil then
    local ret = {}
    for nCharId,mapAmmo in pairs(((self.mapTempData).mapCharacterTempData).ammoInfo) do
      local stInfo = (CS.Lua2CSharpInfo_ActorAmmoInfo)()
      local tbAmmoCount = {mapAmmo.nAmmo1, mapAmmo.nAmmo2, mapAmmo.nAmmo3}
      stInfo.actorID = nCharId
      stInfo.ammoCount = tbAmmoCount
      stInfo.ammoType = mapAmmo.nCurAmmo
      ;
      (table.insert)(ret, stInfo)
    end
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAmmoInfos, ret)
  end
end

JointDrillLevelData_1.ResetSommon = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if (self.mapTempData).mapCharacterTempData ~= nil and ((self.mapTempData).mapCharacterTempData).sommonInfo ~= nil then
    safe_call_cs_func((CS.AdventureModuleHelper).SetSummonMonsters, ((self.mapTempData).mapCharacterTempData).sommonInfo)
  end
end

JointDrillLevelData_1.ResetCharacter = function(self)
  -- function num : 0_13
end

JointDrillLevelData_1.GetActorHp = function(self)
  -- function num : 0_14 , upvalues : AdventureModuleHelper, _ENV
  local logStr = ""
  local tbActorEntity = (AdventureModuleHelper.GetCurrentGroupPlayers)()
  local mapCurCharInfo = {}
  local count = tbActorEntity.Count - 1
  for i = 0, count do
    local nCharId = (AdventureModuleHelper.GetCharacterId)(tbActorEntity[i])
    local hp = (AdventureModuleHelper.GetEntityHp)(tbActorEntity[i])
    mapCurCharInfo[nCharId] = hp
    logStr = logStr .. (string.format)("EntityID:%d\t角色Id�?%d\t角色血量：%d\n", tbActorEntity[i], nCharId, hp)
  end
  print(logStr)
  return mapCurCharInfo
end

JointDrillLevelData_1.JointDrillSuccess = function(self, netMsg)
  -- function num : 0_15 , upvalues : _ENV, AdventureModuleHelper
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
    -- function num : 0_15_0
  end

  local levelEndCallback = function()
    -- function num : 0_15_1 , upvalues : _ENV, self, levelEndCallback, AdventureModuleHelper, tbSkin, func_SettlementFinish
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
    -- function num : 0_15_2 , upvalues : _ENV, self, openBattleResultPanel, netMsg, nScoreOld
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    local nResultType = (AllEnum.JointDrillResultType).Success
    local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
    local mapScore = {FightScore = netMsg.FightScore, HpScore = netMsg.HpScore, DifficultyScore = netMsg.DifficultyScore, nTotalScore = (self.parent).nTotalScore, nScore = nScore, nScoreOld = nScoreOld}
    local bSimulate = (self.parent):GetBattleSimulate()
    local nBattleCount = (self.parent):GetJointDrillBattleCount()
    if netMsg.Items or not netMsg.Change then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult_1, nResultType, self.nCurLevel, 0, self.nLevelId, {}, mapScore, {}, {}, netMsg.Old, netMsg.New, bSimulate, nBattleCount, self.tbCharDamage)
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

JointDrillLevelData_1.CheckJointDrillGameOver = function(self)
  -- function num : 0_16 , upvalues : _ENV
  local nChallengeCount = (self.parent):GetJointDrillBattleCount()
  local nAllChallengeCount = (self.parent):GetMaxChallengeCount(self.nLevelId)
  if nAllChallengeCount <= nChallengeCount then
    local nHp, nHpMax = 0, 0
    local data, nDataLength = self:CacheTempData(false, true, true)
    if self.mapTempData ~= nil and (self.mapTempData).mapBossTempData ~= nil then
      nHp = ((self.mapTempData).mapBossTempData).nHp
      nHpMax = ((self.mapTempData).mapBossTempData).nHpMax
    end
    local syncCallback = function()
    -- function num : 0_16_0 , upvalues : self, _ENV
    local callback = function(netMsg)
      -- function num : 0_16_0_0 , upvalues : self, _ENV
      self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd, netMsg)
    end

    ;
    (self.parent):JointDrillGameOver(callback)
  end

    ;
    (self.parent):JointDrillSync(self.nCurLevel, self.nGameTime, self.nDamageValue, nHp, nHpMax, data, syncCallback)
  else
    do
      local bBossFloor = (self.mapFloor).FloorType == (GameEnum.JointDrillFloorType).Boss
      local data, nDataLength = self:CacheTempData(false, bBossFloor, true, false, true)
      local mapBossInfo = (self.mapTempData).mapBossTempData
      do
        local callback = function(netMsg)
    -- function num : 0_16_1 , upvalues : self, _ENV
    self:JointDrillFail((AllEnum.JointDrillResultType).BattleEnd, netMsg)
  end

        ;
        (self.parent):JointDrillGiveUp(self.nCurLevel, self.nGameTime, self.nDamageValue, mapBossInfo.nHp, data, self.mapBuildData, callback)
        -- DECOMPILER ERROR: 2 unprocessed JMP targets
      end
    end
  end
end

JointDrillLevelData_1.JointDrillFail = function(self, nResultType, netMsg)
  -- function num : 0_17 , upvalues : _ENV
  local bossInfo = {}
  local tempBossData = (self.mapTempData).mapBossTempData
  if nResultType == (AllEnum.JointDrillResultType).Retreat then
    tempBossData = (self.mapInitTempData).mapBossTempData
  end
  if tempBossData ~= nil then
    bossInfo.nHp = tempBossData.nHp
    bossInfo.nHpMax = tempBossData.nHpMax
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
    (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult_1, nResultType, self.nCurLevel, self.nGameTime, self.nLevelId, bossInfo, mapScore, mapReward, mapChange, nOld, nNew, bSimulate, nBattleCount, self.tbCharDamage)
    ;
    (self.parent):LevelEnd(nResultType)
  end
end

JointDrillLevelData_1.SyncGameTime = function(self, nTime)
  -- function num : 0_18 , upvalues : _ENV
  if not nTime then
    nTime = 0
  end
  self.nGameTime = (math.min)(self:GetSyncGameTime(nTime), (self.mapLevel).BattleTime * 1000)
  ;
  (self.parent):SetGameTime(self.nGameTime)
  ;
  (EventManager.Hit)("RefreshJointDrillGameTime", self.nGameTime)
end

JointDrillLevelData_1.ResetGameTimer = function(self)
  -- function num : 0_19
  if self.gameTimer ~= nil then
    (self.gameTimer):Cancel()
    self.gameTimer = nil
  end
  self.bTimerStart = false
end

JointDrillLevelData_1.StartJointDrill = function(self)
  -- function num : 0_20 , upvalues : _ENV, AdventureModuleHelper
  (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillBattlePanel, self.tbCharId, (self.mapLevel).Id, (self.mapLevel).BattleTime, (GameEnum.JointDrillMode).JointDrill_Mode_1)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func(AdventureModuleHelper.SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

JointDrillLevelData_1.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_21 , upvalues : _ENV, AdventureModuleHelper
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func(AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  self:ResetBuff()
  self:SetActorHP()
  self:ResetSkill()
  ;
  (self.parent):AddRecordFloorList()
  ;
  (PlayerData.Build):SetBuildReportInfo((self.mapBuildData).nBuildId)
end

JointDrillLevelData_1.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_22
  self:StartJointDrill()
end

JointDrillLevelData_1.OnEvent_BattleStart = function(self, nTime)
  -- function num : 0_23
  self.bTimerStart = true
  self:SyncGameTime(nTime)
end

JointDrillLevelData_1.OnEvent_MonsterSpawn = function(self, nBossId)
  -- function num : 0_24 , upvalues : _ENV, AdventureModuleHelper
  self.nBossId = nBossId
  local bBoss = (self.mapFloor).FloorType == (GameEnum.JointDrillFloorType).Boss
  if bBoss and self.mapTempData ~= nil and (self.mapTempData).mapBossTempData ~= nil then
    (AdventureModuleHelper.SetJointDrillBossData)(nBossId, (self.mapTempData).mapBossTempData)
  end
  if self.bChangeLevel then
    return 
  end
  local data, nDataLength = self:CacheTempData(false, bBoss, true)
  local nHp, nHpMax = 1, 1
  if self.mapTempData ~= nil and (self.mapTempData).mapBossTempData ~= nil then
    nHp = ((self.mapTempData).mapBossTempData).nHp
    nHpMax = ((self.mapTempData).mapBossTempData).nHpMax
  end
  ;
  (self.parent):JointDrillSync(self.nCurLevel, self.nGameTime, self.nDamageValue, nHp, nHpMax, data)
  self.mapInitTempData = clone(self.mapTempData)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

JointDrillLevelData_1.OnEvent_BattleLvsToggle = function(self, nBattleLv, nTotalTime, nDamageValue)
  -- function num : 0_25 , upvalues : _ENV, AdventureModuleHelper
  if nBattleLv < self.nCurLevel then
    return 
  end
  self.bChangeLevel = true
  self.bRestart = false
  nTotalTime = (math.min)((self.mapLevel).BattleTime * 1000, self:GetSyncGameTime(nTotalTime))
  self.nCurLevel = nBattleLv + 1
  self.nDamageValue = self.nDamageValue + nDamageValue
  self.mapFloor = (self.tbFloor)[self.nCurLevel]
  local bBoss = (self.mapFloor).FloorType == (GameEnum.JointDrillFloorType).Boss
  self:CacheTempData(true, bBoss, false, true, true)
  ;
  (self.parent):AddJointDrillTeam(self.mapBuildData, nTotalTime, self.nDamageValue)
  ;
  (PanelManager.InputDisable)()
  ;
  (self.parent):StopRecord()
  local func = function()
    -- function num : 0_25_0 , upvalues : _ENV, AdventureModuleHelper, self, nTotalTime
    local syncCallback = function()
      -- function num : 0_25_0_0 , upvalues : _ENV, AdventureModuleHelper
      (PanelManager.InputEnable)()
      ;
      (EventManager.Hit)("CloseJointDrillPause")
      local wait = function()
        -- function num : 0_25_0_0_0 , upvalues : _ENV, AdventureModuleHelper
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        (AdventureModuleHelper.LevelStateChanged)(false)
      end

      ;
      (cs_coroutine.start)(wait)
      ;
      (EventManager.Hit)("ResetBossHUD")
    end

    local data, nDataLength = (self.parent):EncodeTempDataJson(self.mapTempData)
    local nHp, nHpMax = 1, 1
    local tempBossData = (self.mapTempData).mapBossTempData
    if tempBossData ~= nil then
      nHp = (math.max)(tempBossData.nHp, 1)
      nHpMax = (math.max)(tempBossData.nHpMax, 1)
    end
    ;
    (self.parent):JointDrillSync(self.nCurLevel, nTotalTime, self.nDamageValue, nHp, nHpMax, data, syncCallback)
  end

  ;
  (EventManager.Hit)(EventId.SetTransition, 3, func)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

JointDrillLevelData_1.OnEvent_UnloadComplete = function(self)
  -- function num : 0_26
  if self.bInResult == true then
    return 
  end
  if self.bRestart then
    (self.parent):RestartBattle()
  else
    ;
    (self.parent):ChangeLevel(self.nCurLevel)
  end
  self:ResetCharacter()
end

JointDrillLevelData_1.OnEvent_JointDrill_Gameplay_Time = function(self, nTime)
  -- function num : 0_27
  self:SyncGameTime(nTime)
end

JointDrillLevelData_1.OnEvent_Pause = function(self)
  -- function num : 0_28 , upvalues : _ENV
  (EventManager.Hit)("OpenJointDrillPause", self.nLevelId, self.tbCharId, self.nGameTime)
end

JointDrillLevelData_1.OnEvent_DamageValue = function(self, nDamageValue)
  -- function num : 0_29
  self.nDamageValue = self.nDamageValue + nDamageValue
end

JointDrillLevelData_1.OnEvent_GiveUpBattle = function(self)
  -- function num : 0_30
  (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
  self:CheckJointDrillGameOver()
end

JointDrillLevelData_1.OnEvent_RestartJointDrill = function(self)
  -- function num : 0_31 , upvalues : AdventureModuleHelper, _ENV
  self.bRestart = true
  self.bChangeLevel = false
  ;
  (self.parent):SetGameTime(0)
  ;
  (AdventureModuleHelper.ClearCharacterDamageRecord)(true)
  local sRecord = (self.parent):EncodeTempDataJson(self.mapInitTempData)
  ;
  (self.parent):ResetRecord(sRecord)
  ;
  (self.parent):SetRecorderExcludeIds(true)
  ;
  (AdventureModuleHelper.LevelStateChanged)(false)
  ;
  (EventManager.Hit)("ResetBossHUD")
  ;
  (EventManager.Hit)("JointDrillReset")
end

JointDrillLevelData_1.OnEvent_RetreatJointDrill = function(self)
  -- function num : 0_32 , upvalues : _ENV
  local callback = function()
    -- function num : 0_32_0 , upvalues : self, _ENV
    local sRecord = (self.parent):EncodeTempDataJson(self.mapInitTempData)
    ;
    (self.parent):ResetRecord(sRecord)
    self:JointDrillFail((AllEnum.JointDrillResultType).Retreat)
  end

  local nHp = 1
  if self.mapInitTempData ~= nil and (self.mapInitTempData).mapBossTempData ~= nil then
    nHp = ((self.mapInitTempData).mapBossTempData).nHp
  end
  ;
  (self.parent):JointDrillRetreat(self.mapBuildData, nHp, callback)
end

JointDrillLevelData_1.OnEvent_JointDrill_Result = function(self, nLevelState, nTotalTime, nDamageValue)
  -- function num : 0_33 , upvalues : _ENV
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
    -- function num : 0_33_0 , upvalues : self
    self:JointDrillSuccess(netMsg)
  end

      ;
      (self.parent):JointDrillSettle(self.mapBuildData, self.nGameTime, self.nDamageValue, callback)
    end
  end
end

JointDrillLevelData_1.JointDrillTimeOut = function(self)
  -- function num : 0_34 , upvalues : _ENV
  if self.bInResult then
    return 
  end
  self.bInResult = true
  ;
  (NovaAPI.DispatchEventWithData)("JointDrill_Level_TimeOut")
  local nHp, nHpMax = 0, 0
  local data, nDataLength = self:CacheTempData(false, true, true)
  if self.mapTempData ~= nil and (self.mapTempData).mapBossTempData ~= nil then
    nHp = ((self.mapTempData).mapBossTempData).nHp
    nHpMax = ((self.mapTempData).mapBossTempData).nHpMax
  end
  local syncCallback = function()
    -- function num : 0_34_0 , upvalues : self, _ENV
    local callback = function(netMsg)
      -- function num : 0_34_0_0 , upvalues : self, _ENV
      self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd, netMsg)
    end

    ;
    (self.parent):AddJointDrillTeam(self.mapBuildData, self.nGameTime, self.nDamageValue)
    ;
    (self.parent):JointDrillGameOver(callback)
  end

  ;
  (self.parent):JointDrillSync(self.nCurLevel, self.nGameTime, self.nDamageValue, nHp, nHpMax, data, syncCallback)
end

JointDrillLevelData_1.OnEvent_CharDamageValue = function(self, charDamageValue)
  -- function num : 0_35 , upvalues : _ENV
  for nCharId,nValue in pairs(charDamageValue) do
    for _,v in ipairs(self.tbCharDamage) do
      if v.nCharId == nCharId then
        v.nDamage = v.nDamage + nValue
        break
      end
    end
  end
end

JointDrillLevelData_1.OnEvent_InputEnable = function(self, bEnable)
  -- function num : 0_36
end

JointDrillLevelData_1.OnEvent_JointDrill_StopTime = function(self)
  -- function num : 0_37
end

JointDrillLevelData_1.OnEvent_JointDrillChallengeFinishError = function(self)
  -- function num : 0_38 , upvalues : _ENV
  self:JointDrillFail((AllEnum.JointDrillResultType).ChallengeEnd)
  ;
  (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList_1)
  ;
  (self.parent):ChallengeEnd()
end

JointDrillLevelData_1.OnEvent_UploadDodgeEvent = function(self, padMode)
  -- function num : 0_39 , upvalues : _ENV
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

return JointDrillLevelData_1

