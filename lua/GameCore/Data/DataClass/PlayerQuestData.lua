local LocalData = require("GameCore.Data.LocalData")
local statusOrder = {[0] = 1, [1] = 2, [2] = 0}
local PlayerQuestData = class("PlayerQuestData")
local QuestType = {Unknown = 0, TourGuide = 1, Daily = 2, TravelerDuel = 3, TravelerDuelChallenge = 4, Affinity = 5, BattlePassDaily = 6, BattlePassWeekly = 7, VampireSurvivorNormal = 8, VampireSurvivorSeason = 9, Tower = 10, Demon = 11, TowerEvent = 12, Weekly = 13, Assist = 14}
local QuestRedDotType = {TourGuide = RedDotDefine.Task_Guide, Daily = RedDotDefine.Task_Daily, TravelerDuel = RedDotDefine.Task_Duel, TravelerDuelChallenge = RedDotDefine.Task_Season, Affinity = RedDotDefine.Role_AffinityTask, Tower = RedDotDefine.StarTowerQuest, Weekly = RedDotDefine.Task_Weekly, Assist = RedDotDefine.TaskNewbie_TeamFormation}
PlayerQuestData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self._mapQuest = {}
  self.tbDailyActives = {}
  self.tbWeeklyActives = {}
  self.nCurTourGroupOrderIndex = 0
  self.nMaxTourGroupOrderIndex = 0
  self.nMaxTeamFormationGroupIdx = 0
  self.nMaxTeamFormationGroupIdxInAttr = {}
  self.tbTourGuideGroup = {}
  self.tbTourGuide = {}
  self.tbTeamFormation = {}
  self.tbTeamFormationGroup = {}
  self.tbTeamFormationAttr = {}
  self:InitConfig()
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.HandleExpire)
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.UpdateDailyQuestRedDot)
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.UpdateWeeklyQuestRedDot)
end

PlayerQuestData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.HandleExpire)
  ;
  (EventManager.Remove)(EventId.UpdateWorldClass, self, self.UpdateDailyQuestRedDot)
  ;
  (EventManager.Remove)(EventId.UpdateWorldClass, self, self.UpdateWeeklyQuestRedDot)
end

PlayerQuestData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local foreachDailyActive = function(mapData)
    -- function num : 0_2_0 , upvalues : self
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

    (self.tbDailyActives)[mapData.Id] = {bReward = false, nActive = mapData.Active}
  end

  ForEachTableLine(DataTable.DailyQuestActive, foreachDailyActive)
  local foreachTourGroup = function(mapData)
    -- function num : 0_2_1 , upvalues : _ENV, self
    (table.insert)(self.tbTourGuideGroup, mapData)
  end

  ForEachTableLine(DataTable.TourGuideQuestGroup, foreachTourGroup)
  ;
  (table.sort)(self.tbTourGuideGroup, function(a, b)
    -- function num : 0_2_2
    do return a.Order < b.Order end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  self.nMaxTourGroupOrderIndex = #self.tbTourGuideGroup
  local foreachTourQuest = function(mapData)
    -- function num : 0_2_3 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbTourGuide)[mapData.Order] == nil then
      (self.tbTourGuide)[mapData.Order] = {}
    end
    ;
    (table.insert)((self.tbTourGuide)[mapData.Order], mapData)
  end

  ForEachTableLine(DataTable.TourGuideQuest, foreachTourQuest)
  local foreachDemonQuest = function(line)
    -- function num : 0_2_4 , upvalues : _ENV
    if (CacheTable.GetData)("_DemonQuest", line.AdvanceGroup) == nil then
      (CacheTable.SetData)("_DemonQuest", line.AdvanceGroup, {})
    end
    ;
    (CacheTable.InsertData)("_DemonQuest", line.AdvanceGroup, line)
  end

  ForEachTableLine((ConfigTable.Get)("DemonQuest"), foreachDemonQuest)
  local foreachWeeklyActive = function(mapData)
    -- function num : 0_2_5 , upvalues : self
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

    (self.tbWeeklyActives)[mapData.Id] = {bReward = false, nActive = mapData.Active}
  end

  ForEachTableLine(DataTable.WeeklyQuestActive, foreachWeeklyActive)
  local foreachTeamFormationGroup = function(mapData)
    -- function num : 0_2_6 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if (self.nMaxTeamFormationGroupIdxInAttr)[mapData.AttributeId] == nil then
      (self.nMaxTeamFormationGroupIdxInAttr)[mapData.AttributeId] = 0
    end
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (self.nMaxTeamFormationGroupIdxInAttr)[mapData.AttributeId] = (self.nMaxTeamFormationGroupIdxInAttr)[mapData.AttributeId] + 1
    ;
    (table.insert)(self.tbTeamFormationGroup, mapData)
  end

  ForEachTableLine(DataTable.AssistQuestGroup, foreachTeamFormationGroup)
  ;
  (table.sort)(self.tbTeamFormationGroup, function(a, b)
    -- function num : 0_2_7
    do return a.Id < b.Id end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  self.nMaxTeamFormationGroupIdx = #self.tbTeamFormationGroup
  local foreachTeamFormation = function(mapData)
    -- function num : 0_2_8 , upvalues : _ENV, self
    (table.insert)(self.tbTeamFormation, mapData)
  end

  ForEachTableLine(DataTable.AssistQuest, foreachTeamFormation)
  local foreachTeamFormationAttr = function(mapData)
    -- function num : 0_2_9 , upvalues : _ENV, self
    (table.insert)(self.tbTeamFormationAttr, mapData)
  end

  ForEachTableLine(DataTable.AssistAttribute, foreachTeamFormationAttr)
end

PlayerQuestData.GetAllQuestData = function(self)
  -- function num : 0_3 , upvalues : statusOrder, _ENV, QuestType
  local retDaily = {}
  local sortDaily = function(a, b)
    -- function num : 0_3_0 , upvalues : statusOrder, _ENV
    if statusOrder[b.nStatus] >= statusOrder[a.nStatus] then
      do return a.nStatus == b.nStatus end
      local mapQuestA = (ConfigTable.GetData)("DailyQuest", a.nTid)
      local mapQuestB = (ConfigTable.GetData)("DailyQuest", b.nTid)
      do return mapQuestA.Order < mapQuestB.Order end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

  if (self._mapQuest)[2] ~= nil then
    for _,mapQuest in pairs((self._mapQuest)[2]) do
      (table.insert)(retDaily, mapQuest)
    end
    if #retDaily > 0 then
      (table.sort)(retDaily, sortDaily)
    end
  end
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R3 in 'UnsetPending'

  if (self._mapQuest)[QuestType.TourGuide] == nil and self.nMaxTourGroupOrderIndex <= self.nCurTourGroupOrderIndex then
    (self._mapQuest)[QuestType.TourGuide] = {}
    local nGroupId = ((self.tbTourGuideGroup)[self.nMaxTourGroupOrderIndex]).Id
    local tbQuest = (self.tbTourGuide)[nGroupId]
    if tbQuest ~= nil then
      for _,v in ipairs(tbQuest) do
        -- DECOMPILER ERROR at PC62: Confused about usage of register: R10 in 'UnsetPending'

        ((self._mapQuest)[QuestType.TourGuide])[v.Id] = {nTid = v.Id, nGoal = 1, nCurProgress = 1, nStatus = 2, nExpire = 0}
      end
    end
  end
  do
    local retWeekly = {}
    local sortWeekly = function(a, b)
    -- function num : 0_3_1 , upvalues : statusOrder, _ENV
    if statusOrder[b.nStatus] >= statusOrder[a.nStatus] then
      do return a.nStatus == b.nStatus end
      local mapQuestA = (ConfigTable.GetData)("WeeklyQuest", a.nTid)
      local mapQuestB = (ConfigTable.GetData)("WeeklyQuest", b.nTid)
      do return mapQuestA.Order < mapQuestB.Order end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

    if (self._mapQuest)[QuestType.Weekly] ~= nil then
      for _,mapQuest in pairs((self._mapQuest)[QuestType.Weekly]) do
        (table.insert)(retWeekly, mapQuest)
      end
      if #retWeekly > 0 then
        (table.sort)(retWeekly, sortWeekly)
      end
    end
    -- DECOMPILER ERROR at PC101: Confused about usage of register: R5 in 'UnsetPending'

    if (self._mapQuest)[QuestType.Assist] == nil then
      (self._mapQuest)[QuestType.Assist] = {}
      local nGroupId = ((self.tbTeamFormationGroup)[self.nMaxTeamFormationGroupIdx]).Id
      local tbQuest = (self.tbTeamFormation)[nGroupId]
      if tbQuest ~= nil then
        for _,v in ipairs(tbQuest) do
          -- DECOMPILER ERROR at PC125: Confused about usage of register: R12 in 'UnsetPending'

          ((self._mapQuest)[QuestType.Assist])[v.Id] = {nTid = v.Id, nGoal = 1, nCurProgress = 1, nStatus = 2, nExpire = 0}
        end
      end
    end
    do
      return retDaily, (self._mapQuest)[QuestType.TourGuide], retWeekly, (self._mapQuest)[QuestType.Assist]
    end
  end
end

PlayerQuestData.CheckTourGroupReward = function(self, nIndex)
  -- function num : 0_4
  do return nIndex <= self.nCurTourGroupOrderIndex end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerQuestData.CheckTeamFormationGroupReward = function(self, nAttributeId, nIndex)
  -- function num : 0_5
  if (self.tbCurTeamFormationGroupIndex)[nAttributeId] == nil then
    return false
  end
  do return nIndex <= (self.tbCurTeamFormationGroupIndex)[nAttributeId] end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerQuestData.CheckTeamFormationAllCompleted = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local nCompletedGroupCount = 0
  for nAttributeId,nGroupCount in pairs(self.tbCurTeamFormationGroupIndex) do
    nCompletedGroupCount = nCompletedGroupCount + nGroupCount
  end
  do return #self.tbTeamFormationGroup <= nCompletedGroupCount end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerQuestData.GetTourGuideQuestRewardId = function(self)
  -- function num : 0_7 , upvalues : QuestType, _ENV
  local tbQuest = (self._mapQuest)[QuestType.TourGuide]
  if tbQuest ~= nil then
    for nId,v in pairs(tbQuest) do
      if v.nStatus == 1 then
        return nId
      end
    end
  end
  do
    return 0
  end
end

PlayerQuestData.GetMaxTourGroupOrderIndex = function(self)
  -- function num : 0_8
  return self.nMaxTourGroupOrderIndex
end

PlayerQuestData.CheckDailyActiveReceive = function(self, nActiveId)
  -- function num : 0_9
  if (self.tbDailyActives)[nActiveId] ~= nil then
    return ((self.tbDailyActives)[nActiveId]).bReward
  end
  return false
end

PlayerQuestData.CheckWeeklyActiveReceive = function(self, nActiveId)
  -- function num : 0_10
  if (self.tbWeeklyActives)[nActiveId] ~= nil then
    return ((self.tbWeeklyActives)[nActiveId]).bReward
  end
  return false
end

PlayerQuestData.GetTravelerDuelQuestData = function(self)
  -- function num : 0_11
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

  if (self._mapQuest)[3] == nil then
    (self._mapQuest)[3] = {}
  end
  return (self._mapQuest)[3], (self._mapQuest)[4]
end

PlayerQuestData.GetBattlePassQuestData = function(self)
  -- function num : 0_12
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

  if (self._mapQuest)[6] == nil then
    (self._mapQuest)[6] = {}
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

  if (self._mapQuest)[7] == nil then
    (self._mapQuest)[7] = {}
  end
  return (self._mapQuest)[6], (self._mapQuest)[7]
end

PlayerQuestData.GetStarTowerBookQuestData = function(self)
  -- function num : 0_13
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

  if (self._mapQuest)[12] == nil then
    (self._mapQuest)[12] = {}
  end
  return (self._mapQuest)[12]
end

PlayerQuestData.GetOngoingAttributeId = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local nLastestAttributeId = 0
  for k,v in pairs(self.tbTeamFormationAttr) do
    local bComplete = self:CheckTeamFormationAttributeCompleted(v.Id)
    if not bComplete then
      nLastestAttributeId = v.Id
      break
    end
  end
  do
    return nLastestAttributeId
  end
end

PlayerQuestData.GetAttributeIdByGroupId = function(self, nGroupId)
  -- function num : 0_15 , upvalues : _ENV
  for nGroupIdx,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.Id == nGroupId then
      return mapGroup.AttributeId
    end
  end
  return 0
end

PlayerQuestData.GetTeamFormationGroupIndexInAttribute = function(self, nGroupId)
  -- function num : 0_16 , upvalues : _ENV
  local nAttributeId = self:GetAttributeIdByGroupId(nGroupId)
  if nAttributeId == 0 then
    return 0
  end
  local nIdx = 0
  for nGroupIdx,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == nAttributeId then
      nIdx = nIdx + 1
      if mapGroup.Id == nGroupId then
        return nIdx
      end
    end
  end
  return 0
end

PlayerQuestData.GetCurTeamFormationQuestGroup = function(self, nAttributeId)
  -- function num : 0_17 , upvalues : QuestType, _ENV
  if (self._mapQuest)[QuestType.Assist] == nil or (self.tbCurTeamFormationGroupIndex)[nAttributeId] == nil then
    local mapFirstGroup = nil
    for nGroupIdx,mapGroup in pairs(self.tbTeamFormationGroup) do
      if mapGroup.AttributeId == nAttributeId then
        mapFirstGroup = mapGroup
        break
      end
    end
    do
      do
        if mapFirstGroup == nil then
          return 0
        end
        do return mapFirstGroup.Id end
        local nCurIndex = (math.min)((self.tbCurTeamFormationGroupIndex)[nAttributeId] + 1, (self.nMaxTeamFormationGroupIdxInAttr)[nAttributeId])
        local nCurAttriCount = 0
        for i = 1, #self.tbTeamFormationGroup do
          if ((self.tbTeamFormationGroup)[i]).AttributeId == nAttributeId then
            nCurAttriCount = nCurAttriCount + 1
            if nCurAttriCount == nCurIndex then
              return ((self.tbTeamFormationGroup)[i]).Id
            end
          end
        end
      end
    end
  end
end

PlayerQuestData.GetTeamFormationQuestData = function(self)
  -- function num : 0_18 , upvalues : QuestType
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

  if (self._mapQuest)[QuestType.Assist] == nil then
    (self._mapQuest)[QuestType.Assist] = {}
  end
  return (self._mapQuest)[QuestType.Assist]
end

PlayerQuestData.GetTeamFormationGroupById = function(self, nGroupId)
  -- function num : 0_19 , upvalues : _ENV
  local tbTeamFormation = self:GetTeamFormationQuestData()
  if tbTeamFormation == nil then
    return nil
  end
  local tbGroupData = {}
  for k,v in pairs(self.tbTeamFormation) do
    if nGroupId == v.QuestGroup then
      (table.insert)(tbGroupData, tbTeamFormation[v.Id])
    end
  end
  return tbGroupData
end

PlayerQuestData.GetTeamFormationGroupStartIndex = function(self, nAttrId)
  -- function num : 0_20 , upvalues : _ENV
  local nStartIndex = 0
  for nGroupIndex,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == nAttrId then
      nStartIndex = nGroupIndex
      break
    end
  end
  do
    return nStartIndex
  end
end

PlayerQuestData.GetTeamFormationGroupEndIndex = function(self, nAttrId)
  -- function num : 0_21 , upvalues : _ENV
  local nEndIndex = 0
  local nLastestGroupId = self:GetCurTeamFormationQuestGroup(nAttrId)
  for nGroupIndex,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == nAttrId and mapGroup.Id == nLastestGroupId then
      nEndIndex = nGroupIndex
    end
  end
  return nEndIndex
end

PlayerQuestData.CheckTeamFormationAttributeCompleted = function(self, nAttrId)
  -- function num : 0_22 , upvalues : _ENV
  local bCompleted = true
  local tbIndexInAttr = {}
  for nGroupIndex,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == nAttrId then
      if tbIndexInAttr[nAttrId] == nil then
        tbIndexInAttr[nAttrId] = 0
      end
      tbIndexInAttr[nAttrId] = tbIndexInAttr[nAttrId] + 1
      local bGroupCompleted = self:CheckTeamFormationGroupReward(nAttrId, tbIndexInAttr[nAttrId])
      if bCompleted then
        bCompleted = bGroupCompleted
      end
      if bCompleted == false then
        return false
      end
    end
  end
  return bCompleted
end

PlayerQuestData.CheckTeamFormationGroupCompleted = function(self, nGroupId)
  -- function num : 0_23 , upvalues : _ENV
  local tbGroupData = self:GetTeamFormationGroupById(nGroupId)
  if tbGroupData == nil then
    return false
  end
  for k,questData in pairs(tbGroupData) do
    if questData.nStatus ~= 1 then
      return false
    end
  end
  return true
end

PlayerQuestData.CheckTeamFormationAttributeUnlocked = function(self, nAttrId)
  -- function num : 0_24 , upvalues : _ENV
  local mapAttr = (ConfigTable.GetData)("AssistAttribute", nAttrId)
  if mapAttr == nil then
    return false
  end
  if mapAttr.Pre == nil or mapAttr.Pre == 0 then
    return true
  end
  local bCompleted = true
  local nGroupIdxInAttr = 0
  for nGroupIndex,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == mapAttr.Pre then
      nGroupIdxInAttr = nGroupIdxInAttr + 1
      local bGroupCompleted = self:CheckTeamFormationGroupReward(mapAttr.Pre, nGroupIdxInAttr)
      if bCompleted then
        bCompleted = bGroupCompleted
      end
      if bCompleted == false then
        return false
      end
    end
  end
  return bCompleted
end

PlayerQuestData.GetTeamFormationAttributeProgress = function(self, nAttrId)
  -- function num : 0_25 , upvalues : _ENV
  local nTotalCount = 0
  local nReceivedCount = 0
  local tbIndexInAttr = {}
  for nGroupIndex,mapGroup in pairs(self.tbTeamFormationGroup) do
    if mapGroup.AttributeId == nAttrId then
      if tbIndexInAttr[nAttrId] == nil then
        tbIndexInAttr[nAttrId] = 0
      end
      tbIndexInAttr[nAttrId] = tbIndexInAttr[nAttrId] + 1
      nTotalCount = nTotalCount + 1
      local bGroupCompleted = self:CheckTeamFormationGroupReward(nAttrId, tbIndexInAttr[nAttrId])
      if bGroupCompleted then
        nReceivedCount = nReceivedCount + 1
      end
    end
  end
  return nReceivedCount, nTotalCount
end

PlayerQuestData.GetCurTourGroup = function(self)
  -- function num : 0_26 , upvalues : QuestType, _ENV
  if (self._mapQuest)[QuestType.TourGuide] == nil then
    return 0
  end
  local nCurIndex = (math.min)(self.nCurTourGroupOrderIndex + 1, self.nMaxTourGroupOrderIndex)
  local mapCurGroup = (self.tbTourGuideGroup)[nCurIndex]
  return mapCurGroup.Id
end

PlayerQuestData.GetCurTourGroupOrder = function(self)
  -- function num : 0_27 , upvalues : QuestType, _ENV
  if (self._mapQuest)[QuestType.TourGuide] == nil then
    return 0
  end
  local nCurIndex = (math.min)(self.nCurTourGroupOrderIndex + 1, self.nMaxTourGroupOrderIndex)
  local mapCurGroup = (self.tbTourGuideGroup)[nCurIndex]
  return mapCurGroup.Order
end

PlayerQuestData.GetMaxTourGroup = function(self)
  -- function num : 0_28
  return ((self.tbTourGuideGroup)[self.nMaxTourGroupOrderIndex]).Id
end

PlayerQuestData.GetAffinityQuestData = function(self, questId)
  -- function num : 0_29 , upvalues : QuestType
  if (self._mapQuest)[QuestType.Affinity] ~= nil and ((self._mapQuest)[QuestType.Affinity])[questId] ~= nil then
    return ((self._mapQuest)[QuestType.Affinity])[questId]
  end
  return nil
end

PlayerQuestData.GetStarTowerQuestData = function(self)
  -- function num : 0_30 , upvalues : QuestType, _ENV, statusOrder
  local tbCore, tbNormal = {}, {}
  if not (self._mapQuest)[QuestType.Tower] then
    return tbCore, tbNormal
  end
  for nId,v in pairs((self._mapQuest)[QuestType.Tower]) do
    local mapCfg = (ConfigTable.GetData)("StarTowerQuest", nId)
    if mapCfg and v.nStatus ~= 2 then
      if mapCfg.TowerQuestType == (GameEnum.TowerQuestType).Core then
        (table.insert)(tbCore, v)
      else
        if mapCfg.TowerQuestType == (GameEnum.TowerQuestType).Normal then
          (table.insert)(tbNormal, v)
        end
      end
    end
  end
  local sort = function(a, b)
    -- function num : 0_30_0 , upvalues : statusOrder
    if statusOrder[b.nStatus] >= statusOrder[a.nStatus] then
      do return a.nStatus == b.nStatus end
      if a.nTid >= b.nTid then
        do return a.nTid == b.nTid end
        -- DECOMPILER ERROR: 4 unprocessed JMP targets
      end
    end
  end

  if #tbNormal > 0 then
    (table.sort)(tbNormal, sort)
  end
  return tbCore, tbNormal
end

PlayerQuestData.ReceiveDemonQuest = function(self, nGroupId)
  -- function num : 0_31 , upvalues : QuestType, _ENV
  if (self._mapQuest)[QuestType.Demon] ~= nil then
    for nId,v in pairs((self._mapQuest)[QuestType.Demon]) do
      local mapCfg = (ConfigTable.GetData)("DemonQuest", nId)
      if mapCfg ~= nil and mapCfg.AdvanceGroup == nGroupId then
        v.nStatus = 2
      end
    end
  end
end

PlayerQuestData.GetDemonQuestData = function(self, nGroupId, nStageId)
  -- function num : 0_32 , upvalues : QuestType, _ENV
  local tbQuest = {}
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R4 in 'UnsetPending'

  if (self._mapQuest)[QuestType.Demon] == nil then
    (self._mapQuest)[QuestType.Demon] = {}
  end
  for nId,v in pairs((self._mapQuest)[QuestType.Demon]) do
    local mapCfg = (ConfigTable.GetData)("DemonQuest", nId)
    if mapCfg ~= nil and mapCfg.AdvanceGroup == nGroupId then
      (table.insert)(tbQuest, v)
    end
  end
  if #tbQuest == 0 then
    local nCurStageId = (PlayerData.Base):GetCurWorldClassStageId()
    local tbAllQuest = (CacheTable.GetData)("_DemonQuest", nGroupId)
    if tbAllQuest ~= nil and #tbAllQuest > 0 then
      for _,v in ipairs(tbAllQuest) do
        ;
        (table.insert)(tbQuest, {nTid = v.Id, nGoal = 1, nCurProgress = 0, nStatus = nStageId < nCurStageId and 2 or 0, nExpire = 0})
      end
    end
  end
  do
    ;
    (table.sort)(tbQuest, function(a, b)
    -- function num : 0_32_0
    if a.nTid >= b.nTid then
      do return a.nStatus ~= b.nStatus end
      do return a.nStatus < b.nStatus end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
    return tbQuest
  end
end

PlayerQuestData.OnQuestProgressChanged = function(self, mapData)
  -- function num : 0_33 , upvalues : _ENV, QuestType
  if (mapData.Progress)[1] ~= nil or not 0 then
    local nCur = ((mapData.Progress)[1]).Cur
  end
  print((string.format)("任务进度变更 ID:%d 当前进度:%d 当前状态:%d", mapData.Id, nCur, mapData.Status))
  if QuestType[mapData.Type] == nil then
    return 
  end
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R3 in 'UnsetPending'

  if (self._mapQuest)[QuestType[mapData.Type]] == nil then
    (self._mapQuest)[QuestType[mapData.Type]] = {}
  end
  if #mapData.Progress == 0 then
    printError("没有任务进度：" .. mapData.Id)
    return 
  end
  -- DECOMPILER ERROR at PC73: Confused about usage of register: R3 in 'UnsetPending'

  if mapData.Status == 2 or not ((mapData.Progress)[1]).Cur then
    ((self._mapQuest)[QuestType[mapData.Type]])[mapData.Id] = {nTid = mapData.Id, nGoal = ((mapData.Progress)[1]).Max, nCurProgress = ((mapData.Progress)[1]).Max, nStatus = mapData.Status, nExpire = mapData.Expire}
    ;
    (EventManager.Hit)(EventId.QuestDataRefresh, mapData.Type)
  end
end

PlayerQuestData.ReceiveTourReward = function(self, nTid, callback)
  -- function num : 0_34 , upvalues : _ENV, QuestType
  local msg = {Value = nTid}
  local tbReceivedId = {}
  if nTid == 0 then
    for nId,mapQuestData in pairs((self._mapQuest)[QuestType.TourGuide]) do
      if mapQuestData.nStatus == 1 then
        (table.insert)(tbReceivedId, nId)
      end
    end
  end
  do
    local Callback = function(_, mapMsgData)
    -- function num : 0_34_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nQuestId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC11: Confused about usage of register: R7 in 'UnsetPending'

        (((self._mapQuest)[QuestType.TourGuide])[nQuestId]).nStatus = 2
        -- DECOMPILER ERROR at PC16: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TourGuide])[nQuestId]).nCurProgress = 1
        -- DECOMPILER ERROR at PC21: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TourGuide])[nQuestId]).nGoal = 1
      end
    else
      do
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TourGuide])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC36: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TourGuide])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TourGuide])[nTid]).nGoal = 1
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        if callback ~= nil then
          callback(mapMsgData)
        end
        ;
        (EventManager.Hit)(EventId.TourQuestReceived, mapMsgData.Rewards, mapMsgData.Change)
        self:UpdateQuestRedDot("TourGuide")
      end
    end
  end

    ;
    (PlayerData.State):SetMailOverflow(false)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_tour_guide_reward_receive_req, msg, nil, Callback)
  end
end

PlayerQuestData.ReceiveTourGroupReward = function(self, callback)
  -- function num : 0_35 , upvalues : _ENV
  local Callback = function(_, mapMsgData)
    -- function num : 0_35_0 , upvalues : self, _ENV, callback
    self.nCurTourGroupOrderIndex = self.nCurTourGroupOrderIndex + 1
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    if callback ~= nil then
      callback(mapMsgData)
    end
    ;
    (EventManager.Hit)(EventId.TourGroupReceived, mapMsgData.Rewards, mapMsgData.Change)
    self:UpdateQuestRedDot("TourGuide")
  end

  ;
  (PlayerData.State):SetMailOverflow(false)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_tour_guide_group_reward_receive_req, {}, nil, Callback)
end

PlayerQuestData.ReceiveTeamFormationReward = function(self, nTid, nGroupId, callback)
  -- function num : 0_36 , upvalues : _ENV, QuestType
  local msg = {Group = nGroupId, Quest = nTid}
  local tbReceivedId = {}
  if nTid == 0 and nGroupId ~= 0 then
    for _,mapData in pairs(self.tbTeamFormation) do
      if mapData.QuestGroup == nGroupId then
        local mapQuestData = ((self._mapQuest)[QuestType.Assist])[mapData.Id]
        if mapQuestData.nStatus == 1 then
          (table.insert)(tbReceivedId, mapData.Id)
        end
      end
    end
  end
  do
    local Callback = function(_, mapMsgData)
    -- function num : 0_36_0 , upvalues : nTid, nGroupId, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 and nGroupId ~= 0 then
      for _,nQuestId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC14: Confused about usage of register: R7 in 'UnsetPending'

        (((self._mapQuest)[QuestType.Assist])[nQuestId]).nStatus = 2
        -- DECOMPILER ERROR at PC19: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Assist])[nQuestId]).nCurProgress = 1
        -- DECOMPILER ERROR at PC24: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Assist])[nQuestId]).nGoal = 1
      end
    else
      do
        -- DECOMPILER ERROR at PC39: Confused about usage of register: R2 in 'UnsetPending'

        if nTid ~= 0 and nGroupId == 0 then
          (((self._mapQuest)[QuestType.Assist])[nTid]).nStatus = 2
          -- DECOMPILER ERROR at PC45: Confused about usage of register: R2 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Assist])[nTid]).nCurProgress = 1
          -- DECOMPILER ERROR at PC51: Confused about usage of register: R2 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Assist])[nTid]).nGoal = 1
        end
        local tbItem = {}
        if #tbReceivedId > 0 then
          for _,nQuestId in pairs(tbReceivedId) do
            local mapQuestData = (ConfigTable.GetData)("AssistQuest", nQuestId)
            if mapQuestData ~= nil then
              for i = 1, 4 do
                local nItemId = mapQuestData["Item" .. i]
                local nQty = mapQuestData["Qty" .. i]
                if nItemId ~= 0 and nQty > 0 then
                  local bFoundInTable = false
                  for k,dataItem in pairs(tbItem) do
                    if dataItem.Tid == nItemId then
                      dataItem.Qty = dataItem.Qty + nQty
                      bFoundInTable = true
                      break
                    end
                  end
                  do
                    do
                      if not bFoundInTable then
                        (table.insert)(tbItem, {Tid = nItemId, Qty = nQty})
                      end
                      -- DECOMPILER ERROR at PC108: LeaveBlock: unexpected jumping out DO_STMT

                      -- DECOMPILER ERROR at PC108: LeaveBlock: unexpected jumping out IF_THEN_STMT

                      -- DECOMPILER ERROR at PC108: LeaveBlock: unexpected jumping out IF_STMT

                    end
                  end
                end
              end
            end
          end
        else
          do
            do
              local mapQuestData = (ConfigTable.GetData)("AssistQuest", nTid)
              if mapQuestData ~= nil then
                for i = 1, 4 do
                  local nItemId = mapQuestData["Item" .. i]
                  local nQty = mapQuestData["Qty" .. i]
                  if nItemId ~= 0 and nQty > 0 then
                    local bFoundInTable = false
                    for k,dataItem in pairs(tbItem) do
                      if dataItem.Tid == nItemId then
                        dataItem.Qty = dataItem.Qty + nQty
                        bFoundInTable = true
                        break
                      end
                    end
                    do
                      do
                        if not bFoundInTable then
                          (table.insert)(tbItem, {Tid = nItemId, Qty = nQty})
                        end
                        -- DECOMPILER ERROR at PC159: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC159: LeaveBlock: unexpected jumping out IF_THEN_STMT

                        -- DECOMPILER ERROR at PC159: LeaveBlock: unexpected jumping out IF_STMT

                      end
                    end
                  end
                end
              end
              local cb = function()
      -- function num : 0_36_0_0 , upvalues : _ENV
      (EventManager.Hit)("UpdateTeamFormationGroup")
    end

              ;
              (UTILS.OpenReceiveByDisplayItem)(tbItem, mapMsgData, cb)
              self:UpdateQuestRedDot("Assist")
              if callback ~= nil then
                callback(mapMsgData)
              end
            end
          end
        end
      end
    end
  end

    ;
    (PlayerData.State):SetMailOverflow(false)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_assist_reward_receive_req, msg, nil, Callback)
  end
end

PlayerQuestData.ReceiveTeamFormationGroupReward = function(self, nGroupId, nAttributeIdx, callback)
  -- function num : 0_37 , upvalues : _ENV
  local msg = {Value = nGroupId}
  local Callback = function(_, mapMsgData)
    -- function num : 0_37_0 , upvalues : _ENV, self, nGroupId, nAttributeIdx, callback
    if mapMsgData.BuildInfo ~= nil then
      if (mapMsgData.BuildInfo).Brief ~= nil then
        (PlayerData.Build):CacheRogueBuild(mapMsgData.BuildInfo)
      else
        if (mapMsgData.BuildInfo).BuildCoin ~= nil and (mapMsgData.BuildInfo).BuildCoin > 0 then
          local checkLimitCb = function()
      -- function num : 0_37_0_0 , upvalues : _ENV, mapMsgData
      local nLimit = (PlayerData.StarTower):GetStarTowerRewardLimit()
      local nCur = (PlayerData.StarTower):GetStarTowerTicket()
      do
        if nLimit < (mapMsgData.BuildInfo).BuildCoin + nCur then
          local sTip = (ConfigTable.GetUIText)("BUILD_12")
          ;
          (EventManager.Hit)(EventId.OpenMessageBox, sTip)
        end
        local encodeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
        if encodeInfo["proto.Res"] ~= nil then
          for _,mapCoin in ipairs(encodeInfo["proto.Res"]) do
            if mapCoin.Tid == (AllEnum.CoinItemId).FRRewardCurrency then
              (PlayerData.StarTower):AddStarTowerTicket(mapCoin.Qty)
            end
          end
        end
      end
    end

          ;
          (PlayerData.StarTower):SendTowerGrowthDetailReq(checkLimitCb)
        end
      end
    end
    do
      local nNextGroupIdx = self:GetTeamFormationGroupIndexInAttribute(nGroupId)
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (self.tbCurTeamFormationGroupIndex)[nAttributeIdx] = nNextGroupIdx
      local bAttributeComplete = self:CheckTeamFormationAttributeCompleted(nAttributeIdx)
      local nNextGroupId = 0
      for i = 1, #self.tbTeamFormationGroup do
        if ((self.tbTeamFormationGroup)[i]).PreGroup == nGroupId then
          nNextGroupId = ((self.tbTeamFormationGroup)[i]).Id
          break
        end
      end
      do
        local tbItem = {}
        local mapQuest = (ConfigTable.GetData)("AssistQuestGroup", nGroupId)
        if mapQuest ~= nil then
          for i = 1, 5 do
            local nItemId = mapQuest["Item" .. i]
            local nQty = mapQuest["Qty" .. i]
            if nItemId ~= 0 and nQty > 0 then
              local bFoundInTable = false
              for k,dataItem in pairs(tbItem) do
                if dataItem.Tid == nItemId then
                  dataItem.Qty = dataItem.Qty + nQty
                  bFoundInTable = true
                  break
                end
              end
              do
                do
                  if not bFoundInTable then
                    (table.insert)(tbItem, {Tid = nItemId, Qty = nQty})
                  end
                  -- DECOMPILER ERROR at PC103: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC103: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC103: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
          if mapMsgData.BuildInfo ~= nil and (mapMsgData.BuildInfo).Brief ~= nil then
            (table.insert)(tbItem, {Tid = mapQuest.ShowBuildId, Qty = 1})
          end
        end
        local cb = function()
      -- function num : 0_37_0_1 , upvalues : _ENV, bAttributeComplete, nNextGroupId
      (EventManager.Hit)("UpdateTeamFormationGroup", bAttributeComplete, nNextGroupId)
    end

        ;
        (UTILS.OpenReceiveByDisplayItem)(tbItem, mapMsgData.Change, cb)
        self:UpdateQuestRedDot("Assist")
        if callback ~= nil then
          callback(mapMsgData)
        end
      end
    end
  end

  ;
  (PlayerData.State):SetMailOverflow(false)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_assist_group_reward_receive_req, msg, nil, Callback)
end

PlayerQuestData.ReceiveDailyReward = function(self, nTid, callback)
  -- function num : 0_38 , upvalues : _ENV, QuestType
  local msg = {Value = nTid}
  local tbReceivedId = {}
  for nId,mapQuestData in pairs((self._mapQuest)[QuestType.Daily]) do
    local questCfg = (ConfigTable.GetData)("DailyQuest", nId)
    if questCfg ~= nil and nTid == 0 and mapQuestData.nStatus == 1 then
      (table.insert)(tbReceivedId, nId)
    end
  end
  local Callback = function(_, mapMsgData)
    -- function num : 0_38_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

        if (((self._mapQuest)[QuestType.Daily])[nId]).nStatus == 1 then
          (((self._mapQuest)[QuestType.Daily])[nId]).nStatus = 2
          -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Daily])[nId]).nCurProgress = 1
          -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Daily])[nId]).nGoal = 1
        end
      end
    else
      do
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Daily])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Daily])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Daily])[nTid]).nGoal = 1
        ;
        (table.insert)(tbReceivedId, nTid)
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        if callback ~= nil then
          callback()
        end
        ;
        (EventManager.Hit)(EventId.DailyQuestReceived, mapMsgData)
        self:UpdateQuestRedDot("Daily")
      end
    end
  end

  ;
  (PlayerData.State):SetMailOverflow(false)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_daily_reward_receive_req, msg, nil, Callback)
end

PlayerQuestData.ReceiveDailyActiveReward = function(self, callBack)
  -- function num : 0_39 , upvalues : _ENV
  local callback = function(_, mapMsgData)
    -- function num : 0_39_0 , upvalues : _ENV, self, callBack
    local tbReward = {}
    for _,v in ipairs(mapMsgData.ActiveIds) do
      -- DECOMPILER ERROR at PC7: Confused about usage of register: R8 in 'UnsetPending'

      ((self.tbDailyActives)[v]).bReward = true
      local mapCfg = (ConfigTable.GetData)("DailyQuestActive", v)
      if mapCfg ~= nil then
        for i = 1, 2 do
          if mapCfg["ItemTid" .. i] ~= 0 then
            if tbReward[mapCfg["ItemTid" .. i]] == nil then
              tbReward[mapCfg["ItemTid" .. i]] = 0
            end
            tbReward[mapCfg["ItemTid" .. i]] = tbReward[mapCfg["ItemTid" .. i]] + mapCfg["Number" .. i]
          end
        end
      end
    end
    self:UpdateDailyQuestRedDot()
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    if callBack ~= nil then
      callBack()
    end
    local tbShowReward = {}
    for id,count in pairs(tbReward) do
      (table.insert)(tbShowReward, {id = id, count = count})
    end
    ;
    (EventManager.Hit)(EventId.DailyQuestActiveReceived, tbShowReward)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_daily_active_reward_receive_req, {}, nil, callback)
end

PlayerQuestData.ReceiveWeeklyReward = function(self, nTid, callback)
  -- function num : 0_40 , upvalues : _ENV, QuestType
  local msg = {Value = nTid}
  local tbReceivedId = {}
  for nId,mapQuestData in pairs((self._mapQuest)[QuestType.Weekly]) do
    local questCfg = (ConfigTable.GetData)("WeeklyQuest", nId)
    if questCfg ~= nil and nTid == 0 and mapQuestData.nStatus == 1 then
      (table.insert)(tbReceivedId, nId)
    end
  end
  local Callback = function(_, mapMsgData)
    -- function num : 0_40_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

        if (((self._mapQuest)[QuestType.Weekly])[nId]).nStatus == 1 then
          (((self._mapQuest)[QuestType.Weekly])[nId]).nStatus = 2
          -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Weekly])[nId]).nCurProgress = 1
          -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Weekly])[nId]).nGoal = 1
        end
      end
    else
      do
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Weekly])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Weekly])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Weekly])[nTid]).nGoal = 1
        ;
        (table.insert)(tbReceivedId, nTid)
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        if callback ~= nil then
          callback()
        end
        ;
        (EventManager.Hit)(EventId.WeeklyQuestReceived, mapMsgData)
        self:UpdateQuestRedDot("Weekly")
      end
    end
  end

  ;
  (PlayerData.State):SetMailOverflow(false)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_weekly_reward_receive_req, msg, nil, Callback)
end

PlayerQuestData.ReceiveWeeklyActiveReward = function(self, callBack)
  -- function num : 0_41 , upvalues : _ENV
  local callback = function(_, mapMsgData)
    -- function num : 0_41_0 , upvalues : _ENV, self, callBack
    local tbReward = {}
    for _,v in ipairs(mapMsgData.ActiveIds) do
      -- DECOMPILER ERROR at PC7: Confused about usage of register: R8 in 'UnsetPending'

      ((self.tbWeeklyActives)[v]).bReward = true
      local mapCfg = (ConfigTable.GetData)("WeeklyQuestActive", v)
      if mapCfg ~= nil then
        for i = 1, 2 do
          if mapCfg["ItemTid" .. i] ~= 0 then
            if tbReward[mapCfg["ItemTid" .. i]] == nil then
              tbReward[mapCfg["ItemTid" .. i]] = 0
            end
            tbReward[mapCfg["ItemTid" .. i]] = tbReward[mapCfg["ItemTid" .. i]] + mapCfg["Number" .. i]
          end
        end
      end
    end
    self:UpdateWeeklyQuestRedDot()
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    if callBack ~= nil then
      callBack()
    end
    local tbShowReward = {}
    for id,count in pairs(tbReward) do
      (table.insert)(tbShowReward, {id = id, count = count})
    end
    ;
    (EventManager.Hit)(EventId.WeeklyQuestActiveReceived, tbShowReward)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_weekly_active_reward_receive_req, {}, nil, callback)
end

PlayerQuestData.ReceiveTravelerDuelReward = function(self, nTid, callback)
  -- function num : 0_42 , upvalues : _ENV, QuestType
  local msg = {Id = nTid, Type = 3}
  local tbReceivedId = {}
  if nTid == 0 then
    for nId,mapQuestData in pairs((self._mapQuest)[QuestType.TravelerDuel]) do
      if mapQuestData.nStatus == 1 then
        (table.insert)(tbReceivedId, nId)
      end
    end
  end
  do
    local Callback = function(_, mapMsgData)
    -- function num : 0_42_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

        if (((self._mapQuest)[QuestType.TravelerDuel])[nId]).nStatus == 1 then
          (((self._mapQuest)[QuestType.TravelerDuel])[nId]).nStatus = 2
          -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.TravelerDuel])[nId]).nCurProgress = 1
          -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.TravelerDuel])[nId]).nGoal = 1
        end
      end
    else
      do
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuel])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuel])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuel])[nTid]).nGoal = 1
        ;
        (table.insert)(tbReceivedId, nTid)
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        if callback ~= nil then
          callback()
        end
        ;
        (EventManager.Hit)(EventId.TRNormalQusetReceived, mapMsgData.QuestRewards, tbReceivedId, mapMsgData.Change)
        self:UpdateQuestRedDot("TravelerDuel")
      end
    end
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_quest_reward_receive_req, msg, nil, Callback)
  end
end

PlayerQuestData.ReceiveTravelerDuelChallengeReward = function(self, nTid, callback)
  -- function num : 0_43 , upvalues : _ENV, QuestType
  local msg = {Id = nTid, Type = 4}
  local tbReceivedId = {}
  if nTid == 0 then
    for nId,mapQuestData in pairs((self._mapQuest)[QuestType.TravelerDuelChallenge]) do
      if mapQuestData.nStatus == 1 then
        (table.insert)(tbReceivedId, nId)
      end
    end
  end
  do
    local Callback = function(_, mapMsgData)
    -- function num : 0_43_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

        if (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nId]).nStatus == 1 then
          (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nId]).nStatus = 2
          -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nId]).nCurProgress = 1
          -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nId]).nGoal = 1
        end
      end
    else
      do
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.TravelerDuelChallenge])[nTid]).nGoal = 1
        ;
        (table.insert)(tbReceivedId, nTid)
        local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
        ;
        (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
        if callback ~= nil then
          callback()
        end
        ;
        (EventManager.Hit)(EventId.TRChallengeQusetReceived, mapMsgData.QuestRewards, tbReceivedId, mapMsgData.Change)
        self:UpdateQuestRedDot("TravelerDuelChallenge")
      end
    end
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_quest_reward_receive_req, msg, nil, Callback)
  end
end

PlayerQuestData.ReceiveBattlePassQuestData = function(self, nTid, callback)
  -- function num : 0_44 , upvalues : _ENV
  local msgCallback = function(_, msgData)
    -- function num : 0_44_0 , upvalues : nTid, _ENV, self, callback
    if nTid == 0 then
      for _,mapQuest in pairs((self._mapQuest)[6]) do
        if mapQuest.nStatus == 1 then
          mapQuest.nStatus = 2
        end
      end
      for _,mapQuest in pairs((self._mapQuest)[7]) do
        if mapQuest.nStatus == 1 then
          mapQuest.nStatus = 2
        end
      end
    else
      do
        do
          local mapQuestCfgData = (ConfigTable.GetData)("BattlePassQuest", nTid)
          -- DECOMPILER ERROR at PC49: Confused about usage of register: R3 in 'UnsetPending'

          -- DECOMPILER ERROR at PC49: Unhandled construct in 'MakeBoolean' P1

          -- DECOMPILER ERROR at PC49: Unhandled construct in 'MakeBoolean' P1

          if mapQuestCfgData ~= nil and mapQuestCfgData.Type == (GameEnum.battlePassQuestType).DAY and ((self._mapQuest)[6])[nTid] ~= nil then
            (((self._mapQuest)[6])[nTid]).nStatus = 2
          end
          -- DECOMPILER ERROR at PC61: Confused about usage of register: R3 in 'UnsetPending'

          if ((self._mapQuest)[7])[nTid] ~= nil then
            (((self._mapQuest)[7])[nTid]).nStatus = 2
          end
          ;
          (EventManager.Hit)("BattlePassQuestReceive", msgData)
          if callback ~= nil and type(callback) == "function" then
            callback()
          end
          self:UpdateBattlePassRedDot()
        end
      end
    end
  end

  local msg = {Value = nTid}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_quest_reward_receive_req, msg, nil, msgCallback)
end

PlayerQuestData.ReceiveAffinityReward = function(self, questIds, curCharId, callback)
  -- function num : 0_45 , upvalues : QuestType, _ENV
  local msg = {CharId = curCharId, QuestId = 0}
  local Callback = function(_, mapMsgData)
    -- function num : 0_45_0 , upvalues : self, QuestType, _ENV, questIds, callback
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    if (self._mapQuest)[QuestType.Affinity] == nil then
      (self._mapQuest)[QuestType.Affinity] = {}
    end
    for k,v in ipairs(questIds) do
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

      if ((self._mapQuest)[QuestType.Affinity])[v] ~= nil then
        (((self._mapQuest)[QuestType.Affinity])[v]).nStatus = 2
      else
        local data = {nTid = v, nGoal = 1, nCurProgress = 1, nStatus = 2}
        -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

        ;
        ((self._mapQuest)[QuestType.Affinity])[v] = data
      end
    end
    if callback ~= nil then
      callback()
    end
    self:UpdateCharAffinityRedDot()
    ;
    (EventManager.Hit)(EventId.AffinityQuestReceived)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_affinity_quest_reward_receive_req, msg, nil, Callback)
end

PlayerQuestData.ReceiveStarTowerReward = function(self, nTid, callback)
  -- function num : 0_46 , upvalues : _ENV, QuestType
  local msg = {Value = nTid}
  local tbReceivedId = {}
  if nTid == 0 then
    for nId,mapQuestData in pairs((self._mapQuest)[QuestType.Tower]) do
      if mapQuestData.nStatus == 1 then
        (table.insert)(tbReceivedId, nId)
      end
    end
  end
  do
    local Callback = function(_, mapMsgData)
    -- function num : 0_46_0 , upvalues : nTid, _ENV, tbReceivedId, self, QuestType, callback
    if nTid == 0 then
      for _,nId in ipairs(tbReceivedId) do
        -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

        if (((self._mapQuest)[QuestType.Tower])[nId]).nStatus == 1 then
          (((self._mapQuest)[QuestType.Tower])[nId]).nStatus = 2
          -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Tower])[nId]).nCurProgress = 1
          -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (((self._mapQuest)[QuestType.Tower])[nId]).nGoal = 1
        end
      end
    else
      do
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Tower])[nTid]).nStatus = 2
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Tower])[nTid]).nCurProgress = 1
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._mapQuest)[QuestType.Tower])[nTid]).nGoal = 1
        ;
        (table.insert)(tbReceivedId, nTid)
        ;
        (UTILS.OpenReceiveByChangeInfo)(mapMsgData, function()
      -- function num : 0_46_0_0 , upvalues : callback, _ENV
      if callback ~= nil then
        callback()
      end
      ;
      (EventManager.Hit)("StarTowerQuestReceived")
    end
)
        self:UpdateQuestRedDot("Tower")
      end
    end
  end

    ;
    (PlayerData.State):SetMailOverflow(false)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).quest_tower_reward_receive_req, msg, nil, Callback)
  end
end

PlayerQuestData.ReceiveStarTowerEventReward = function(self, nTid, callback)
  -- function num : 0_47 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_47_0 , upvalues : _ENV, self, callback
    for _,v in ipairs(mapMsgData.ReceivedIds) do
      -- DECOMPILER ERROR at PC16: Confused about usage of register: R7 in 'UnsetPending'

      if (self._mapQuest)[12] ~= nil and ((self._mapQuest)[12])[v] ~= nil then
        (((self._mapQuest)[12])[v]).nStatus = 2
        -- DECOMPILER ERROR at PC20: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[12])[v]).nCurProgress = 0
        -- DECOMPILER ERROR at PC24: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (((self._mapQuest)[12])[v]).nGoal = 0
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Event_Reward, v, false)
    end
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData.Change, callback)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_book_event_reward_receive_req, {Value = nTid}, nil, sucCall)
end

PlayerQuestData.CacheAllQuest = function(self, tbQuests)
  -- function num : 0_48 , upvalues : _ENV
  local tbQuestType = {}
  for _,mapQuest in pairs(tbQuests) do
    self:OnQuestProgressChanged(mapQuest)
    if tbQuestType[mapQuest.Type] == nil then
      tbQuestType[mapQuest.Type] = 1
    end
  end
  for questType,v in pairs(tbQuestType) do
    self:UpdateQuestRedDot(questType)
  end
end

PlayerQuestData.CacheDailyActiveIds = function(self, tbIds)
  -- function num : 0_49 , upvalues : _ENV
  for _,v in ipairs(tbIds) do
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R7 in 'UnsetPending'

    ((self.tbDailyActives)[v]).bReward = true
  end
  self:UpdateDailyQuestRedDot()
end

PlayerQuestData.CacheWeeklyActiveIds = function(self, tbIds)
  -- function num : 0_50 , upvalues : _ENV
  self.nextWeekRefreshTime = GetNextWeekRefreshTime()
  for _,v in ipairs(tbIds) do
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R7 in 'UnsetPending'

    ((self.tbWeeklyActives)[v]).bReward = true
  end
  self:UpdateWeeklyQuestRedDot()
end

PlayerQuestData.CacheTourGroupOrder = function(self, nIndex)
  -- function num : 0_51
  self.nCurTourGroupOrderIndex = nIndex
end

PlayerQuestData.CacheTeamFormation = function(self, mapData)
  -- function num : 0_52 , upvalues : _ENV
  self.tbCurTeamFormationGroupIndex = {}
  for k,v in pairs(mapData) do
    local nIdxInGroup = 0
    for nGroupIdx,mapGroup in pairs(self.tbTeamFormationGroup) do
      if v.Attribute == mapGroup.AttributeId then
        nIdxInGroup = nIdxInGroup + 1
      end
    end
    do
      -- DECOMPILER ERROR at PC24: Confused about usage of register: R8 in 'UnsetPending'

      if mapGroup.Id ~= v.Group then
        do
          (self.tbCurTeamFormationGroupIndex)[v.Attribute] = nIdxInGroup
          -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_STMT

          -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
end

PlayerQuestData.CheckClientType = function(self, nEventType)
  -- function num : 0_53 , upvalues : _ENV, QuestType
  local tbQuestId = {}
  for nQuestType,tbQuestList in pairs(self._mapQuest) do
    for _,mapQuest in pairs(tbQuestList) do
      local nClientType = nil
      do
        do
          if nQuestType == QuestType.Daily then
            local mapQuestCfg = (ConfigTable.GetData)("DailyQuest", mapQuest.nTid)
            if mapQuestCfg ~= nil then
              nClientType = mapQuestCfg.CompleteCondClient
            end
          end
          if nClientType == nEventType and mapQuest.nStatus == 0 then
            (table.insert)(tbQuestId, mapQuest.nTid)
          end
          -- DECOMPILER ERROR at PC31: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  return tbQuestId
end

PlayerQuestData.HandleExpire = function(self)
  -- function num : 0_54 , upvalues : _ENV
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local tbExpire = {}
  if (self._mapQuest)[2] ~= nil then
    for nTid,mapQuest in pairs((self._mapQuest)[2]) do
      if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
        (table.insert)(tbExpire, nTid)
      end
    end
    for _,nTid in ipairs(tbExpire) do
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

      ((self._mapQuest)[2])[nTid] = nil
    end
  end
  do
    tbExpire = {}
    if (self._mapQuest)[6] ~= nil then
      for nTid,mapQuest in pairs((self._mapQuest)[6]) do
        if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
          (table.insert)(tbExpire, nTid)
        end
      end
      for _,nTid in ipairs(tbExpire) do
        -- DECOMPILER ERROR at PC66: Confused about usage of register: R8 in 'UnsetPending'

        ((self._mapQuest)[6])[nTid] = nil
      end
    end
    do
      tbExpire = {}
      if (self._mapQuest)[7] ~= nil then
        for nTid,mapQuest in pairs((self._mapQuest)[7]) do
          if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
            (table.insert)(tbExpire, nTid)
          end
        end
        for _,nTid in ipairs(tbExpire) do
          -- DECOMPILER ERROR at PC99: Confused about usage of register: R8 in 'UnsetPending'

          ((self._mapQuest)[7])[nTid] = nil
        end
      end
      do
        for _,v in pairs(self.tbDailyActives) do
          v.bReward = false
        end
        if self.nextWeekRefreshTime < curTime then
          for _,v in pairs(self.tbWeeklyActives) do
            v.bReward = false
          end
          self.nextWeekRefreshTime = GetNextWeekRefreshTime()
        end
        self:UpdateDailyQuestRedDot()
        self:UpdateWeeklyQuestRedDot()
        self:UpdateBattlePassRedDot()
        self:UpdateVampireQuestRedDot()
        self:UpdateTeamFormationRedDot()
      end
    end
  end
end

PlayerQuestData.IsQuestHasReceived = function(self, nType, nQuestId)
  -- function num : 0_55 , upvalues : _ENV
  if (self._mapQuest)[nType] == nil then
    printError("没有记录的任务类型数据：" .. nQuestId)
    return false
  end
  if ((self._mapQuest)[nType])[nQuestId] == nil then
    printError("没有记录的任务组数据：" .. nQuestId)
    return false
  end
  do return (((self._mapQuest)[nType])[nQuestId]).nStatus == 2 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerQuestData.SendClientEvent = function(self, nEventType, nCount)
  -- function num : 0_56 , upvalues : _ENV
  if nCount == nil then
    nCount = 1
  end
  local tbQuestId = self:CheckClientType(nEventType)
  if #tbQuestId > 0 then
    local tbSendData = {}
    for _,v in ipairs(tbQuestId) do
      (table.insert)(tbSendData, {Id = (GameEnum.eventTypes).eClient, 
Data = {nCount, v}
})
    end
    local msgData = {List = tbSendData}
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).client_event_report_req, msgData, nil, nil)
  end
end

PlayerQuestData.UpdateServerQuestRedDot = function(self, mapMsgData)
  -- function num : 0_57 , upvalues : QuestRedDotType, _ENV
  if mapMsgData == nil then
    return 
  end
  local redDotType = QuestRedDotType[mapMsgData.Type]
  if redDotType ~= nil then
    (RedDotManager.SetValid)(redDotType, nil, mapMsgData.New)
  end
end

PlayerQuestData.UpdateQuestRedDot = function(self, questType)
  -- function num : 0_58 , upvalues : _ENV
  if questType == nil then
    return 
  end
  if questType == "Daily" then
    self:UpdateDailyQuestRedDot()
  else
    if questType == "TourGuide" then
      self:UpdateTourGuideQuestRedDot()
    else
      if questType == "Affinity" then
        self:UpdateCharAffinityRedDot()
      else
        if questType == "TravelerDuel" or questType == "TravelerDuelChallenge" then
          self:UpdateDuelQuestRedDot(questType)
        else
          if questType == "BattlePassDaily" or questType == "BattlePassWeekly" then
            self:UpdateBattlePassRedDot()
          else
            if questType == "Tower" then
              self:UpdateStarTowerQuestRedDot()
            else
              if questType == "Demon" then
                (PlayerData.Base):RefreshWorldClassRedDot()
              else
                if questType == "VampireSurvivorSeason" or questType == "VampireSurvivorNormal" then
                  self:UpdateVampireQuestRedDot()
                else
                  if questType == "TowerEvent" then
                    self:UpdateStarTowerBookQuestRedDot()
                  else
                    if questType == "Weekly" then
                      self:UpdateWeeklyQuestRedDot()
                    else
                      if questType == "Assist" then
                        self:UpdateTeamFormationRedDot()
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

PlayerQuestData.UpdateDailyQuestRedDot = function(self)
  -- function num : 0_59 , upvalues : QuestType, _ENV
  local bCanReceive = false
  local bActiveReward = false
  local nTotalActiveCount = 0
  local questList = (self._mapQuest)[QuestType.Daily]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        bCanReceive = true
      else
        if v.nStatus == 2 then
          local questCfg = (ConfigTable.GetData)("DailyQuest", v.nTid)
          if questCfg ~= nil then
            nTotalActiveCount = nTotalActiveCount + questCfg.Active
          end
        end
      end
    end
  end
  do
    for _,v in pairs(self.tbDailyActives) do
      bActiveReward = bActiveReward or (v.nActive <= nTotalActiveCount and v.bReward == false)
    end
    local bFuncUnlock = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).DailyQuest, false)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Task_Daily, nil, not bCanReceive and not bActiveReward or bFuncUnlock)
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end
end

PlayerQuestData.UpdateWeeklyQuestRedDot = function(self)
  -- function num : 0_60 , upvalues : QuestType, _ENV
  local bCanReceive = false
  local bActiveReward = false
  local nTotalActiveCount = 0
  local questList = (self._mapQuest)[QuestType.Weekly]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        bCanReceive = true
      else
        if v.nStatus == 2 then
          local questCfg = (ConfigTable.GetData)("WeeklyQuest", v.nTid)
          if questCfg ~= nil then
            nTotalActiveCount = nTotalActiveCount + questCfg.Active
          end
        end
      end
    end
  end
  do
    for _,v in pairs(self.tbWeeklyActives) do
      bActiveReward = bActiveReward or (v.nActive <= nTotalActiveCount and v.bReward == false)
    end
    local bFuncUnlock = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).WeeklyQuest, false)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Task_Weekly, nil, not bCanReceive and not bActiveReward or bFuncUnlock)
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end
end

PlayerQuestData.UpdateTeamFormationRedDot = function(self)
  -- function num : 0_61 , upvalues : _ENV, QuestType, LocalData
  local bCanReceive = false
  local bAllReceive = true
  local nAttr = 1
  local nFinish = 0
  local foreachAttri = function(mapData)
    -- function num : 0_61_0 , upvalues : nFinish
    nFinish = nFinish + 1
  end

  ForEachTableLine(DataTable.AssistAttribute, foreachAttri)
  for i = 1, nFinish do
    local bComp = self:CheckTeamFormationAttributeCompleted(nFinish)
    if not bComp then
      nAttr = nFinish
      break
    end
    if i == nFinish then
      nAttr = nFinish
    end
  end
  do
    local nCurGroupId = self:GetCurTeamFormationQuestGroup(nAttr)
    local questList = (self._mapQuest)[QuestType.Assist]
    if questList ~= nil then
      for _,v in pairs(questList) do
        local questCfg = (ConfigTable.GetData)("AssistQuest", v.nTid)
        if questCfg ~= nil and nCurGroupId == questCfg.QuestGroup then
          if v.nStatus == 1 then
            bCanReceive = true
          end
          if v.nStatus ~= 2 then
            bAllReceive = false
          end
        end
      end
    end
    do
      local bGroupReceived = true
      do
        if nCurGroupId ~= 0 then
          local nIdx = self:GetTeamFormationGroupIndexInAttribute(nCurGroupId)
          bGroupReceived = self:CheckTeamFormationGroupReward(nAttr, nIdx)
        end
        if bAllReceive then
          local bChapterCanReceive = not bGroupReceived
        end
        local nSelectedTeam = (LocalData.GetPlayerLocalData)("TeamFormationQuestSelected")
        local bTeamSelected = nSelectedTeam ~= nil
        if not bCanReceive and not bChapterCanReceive then
          (RedDotManager.SetValid)(RedDotDefine.TaskNewbie_TeamFormation, nil, not bTeamSelected)
          -- DECOMPILER ERROR: 2 unprocessed JMP targets
        end
      end
    end
  end
end

PlayerQuestData.UpdateTourGuideQuestRedDot = function(self)
  -- function num : 0_62 , upvalues : QuestType, _ENV
  local bCanReceive = false
  local bAllReceive = true
  local nCurGroupId = self:GetCurTourGroup()
  local questList = (self._mapQuest)[QuestType.TourGuide]
  if questList ~= nil then
    for _,v in pairs(questList) do
      do
        do
          if v.nStatus == 1 then
            local questCfg = (ConfigTable.GetData)("TourGuideQuest", v.nTid)
            if questCfg ~= nil and nCurGroupId == questCfg.Order then
              bCanReceive = true
              break
            end
          end
          if v.nStatus ~= 2 then
            bAllReceive = false
          end
          -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  local bGroupReceived = self:CheckTourGroupReward(self:GetCurTourGroupOrder())
  if bAllReceive then
    local bChapterCanReceive = not bGroupReceived
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Task_Guide, nil, bCanReceive or bChapterCanReceive)
end

PlayerQuestData.UpdateDuelQuestRedDot = function(self, questType)
  -- function num : 0_63 , upvalues : QuestType, _ENV, QuestRedDotType
  local bCanReceive = false
  local questList = (self._mapQuest)[QuestType[questType]]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        bCanReceive = true
        break
      end
    end
  end
  do
    ;
    (RedDotManager.SetValid)(QuestRedDotType[questType], nil, bCanReceive)
  end
end

PlayerQuestData.UpdateCharAffinityRedDot = function(self)
  -- function num : 0_64 , upvalues : QuestType, _ENV
  if self.tbCharQuest == nil then
    self.tbCharQuest = {}
  end
  local questList = (self._mapQuest)[QuestType.Affinity]
  if questList ~= nil then
    for k,v in pairs(questList) do
      local data = (ConfigTable.GetData)("AffinityQuest", v.nTid)
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R8 in 'UnsetPending'

      if data ~= nil then
        if (self.tbCharQuest)[data.CharId] == nil then
          (self.tbCharQuest)[data.CharId] = {}
        end
        ;
        (table.insert)((self.tbCharQuest)[data.CharId], v)
      end
    end
    local tbCharList = {}
    for k,list in pairs(self.tbCharQuest) do
      for i = 1, #list do
        local state = (list[i]).nStatus
        if state == 1 then
          tbCharList[k] = true
          break
        else
          tbCharList[k] = false
        end
      end
    end
    for k,v in pairs(tbCharList) do
      (RedDotManager.SetValid)(RedDotDefine.Role_AffinityTask, k, v)
    end
  end
end

PlayerQuestData.UpdateBattlePassRedDot = function(self)
  -- function num : 0_65 , upvalues : _ENV
  local bCanDailyReceive = false
  local bCanWeekReceive = false
  local questList = (self._mapQuest)[6]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        bCanDailyReceive = true
        break
      end
    end
  end
  do
    questList = (self._mapQuest)[7]
    if questList ~= nil then
      for _,v in pairs(questList) do
        if v.nStatus == 1 then
          bCanWeekReceive = true
          break
        end
      end
    end
    do
      ;
      (PlayerData.BattlePass):UpdateQuestRedDot(bCanDailyReceive, bCanWeekReceive)
    end
  end
end

PlayerQuestData.UpdateStarTowerQuestRedDot = function(self)
  -- function num : 0_66 , upvalues : QuestType, _ENV, QuestRedDotType
  local bCanReceive = false
  local questList = (self._mapQuest)[QuestType.Tower]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        bCanReceive = true
        break
      end
    end
  end
  do
    ;
    (RedDotManager.SetValid)(QuestRedDotType.Tower, nil, bCanReceive)
  end
end

PlayerQuestData.UpdateStarTowerBookQuestRedDot = function(self)
  -- function num : 0_67 , upvalues : QuestType, _ENV
  local questList = (self._mapQuest)[QuestType.TowerEvent]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Event_Reward, v.nTid, true)
      else
        ;
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Event_Reward, v.nTid, false)
      end
    end
  end
end

PlayerQuestData.GetVampireQuestData = function(self)
  -- function num : 0_68 , upvalues : QuestType, _ENV
  local tbScore, tbPass = {}, {}
  if (self._mapQuest)[QuestType.VampireSurvivorSeason] ~= nil then
    for nId,v in pairs((self._mapQuest)[QuestType.VampireSurvivorSeason]) do
      (table.insert)(tbScore, v)
    end
  end
  do
    if (self._mapQuest)[QuestType.VampireSurvivorNormal] ~= nil then
      for nId,v in pairs((self._mapQuest)[QuestType.VampireSurvivorNormal]) do
        (table.insert)(tbPass, v)
      end
    end
    do
      return tbScore, tbPass
    end
  end
end

PlayerQuestData.GetVampireQuestStatusById = function(self, nId)
  -- function num : 0_69 , upvalues : QuestType
  if nId == nil then
    return 0
  end
  if (self._mapQuest)[QuestType.VampireSurvivorSeason] ~= nil and ((self._mapQuest)[QuestType.VampireSurvivorSeason])[nId] ~= nil then
    return (((self._mapQuest)[QuestType.VampireSurvivorSeason])[nId]).nStatus
  end
  if (self._mapQuest)[QuestType.VampireSurvivorNormal] ~= nil and ((self._mapQuest)[QuestType.VampireSurvivorNormal])[nId] ~= nil then
    return (((self._mapQuest)[QuestType.VampireSurvivorNormal])[nId]).nStatus
  end
  return 0
end

PlayerQuestData.ReceiveVampireQuest = function(self, nType, tbList, callback)
  -- function num : 0_70 , upvalues : _ENV
  local msg = {QuestType = nType - 7, QuestIds = tbList}
  local Callback = function(_, mapMsgData)
    -- function num : 0_70_0 , upvalues : _ENV, tbList, self, callback
    for _,nTid in ipairs(tbList) do
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R7 in 'UnsetPending'

      if ((self._mapQuest)[8])[nTid] ~= nil then
        (((self._mapQuest)[8])[nTid]).nStatus = 2
      end
      -- DECOMPILER ERROR at PC25: Confused about usage of register: R7 in 'UnsetPending'

      if (self._mapQuest)[9] ~= nil and ((self._mapQuest)[9])[nTid] ~= nil then
        (((self._mapQuest)[9])[nTid]).nStatus = 2
      end
    end
    self:UpdateVampireQuestRedDot()
    ;
    (EventManager.Hit)("VampireQuestRefresh")
    if callback ~= nil then
      callback(mapMsgData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_quest_reward_receive_req, msg, nil, Callback)
end

PlayerQuestData.UpdateVampireQuestRedDot = function(self)
  -- function num : 0_71 , upvalues : _ENV
  local bCanNormalReceive = false
  local bCanHardReceive = false
  local bCanSeasonReceive = false
  local questList = (self._mapQuest)[8]
  if questList ~= nil then
    for _,v in pairs(questList) do
      if v.nStatus == 1 then
        local mapQusetData = (ConfigTable.GetData)("VampireSurvivorQuest", v.nTid)
        if mapQusetData ~= nil then
          if mapQusetData.Type == (GameEnum.vampireSurvivorType).Normal then
            bCanNormalReceive = true
          else
            if mapQusetData.Type == (GameEnum.vampireSurvivorType).Hard then
              bCanHardReceive = true
            else
              if mapQusetData.Type == (GameEnum.vampireSurvivorType).Turn then
                bCanSeasonReceive = true
              end
            end
          end
        end
      end
    end
  end
  do
    questList = (self._mapQuest)[9]
    if questList ~= nil then
      for _,v in pairs(questList) do
        if v.nStatus == 1 then
          local mapQusetData = (ConfigTable.GetData)("VampireSurvivorQuest", v.nTid)
          if mapQusetData ~= nil then
            if mapQusetData.Type == (GameEnum.vampireSurvivorType).Normal then
              bCanNormalReceive = true
            else
              if mapQusetData.Type == (GameEnum.vampireSurvivorType).Hard then
                bCanHardReceive = true
              else
                if mapQusetData.Type == (GameEnum.vampireSurvivorType).Turn then
                  bCanSeasonReceive = true
                end
              end
            end
          end
        end
      end
    end
    do
      ;
      (RedDotManager.SetValid)(RedDotDefine.VampireQuest_Normal, nil, bCanNormalReceive)
      ;
      (RedDotManager.SetValid)(RedDotDefine.VampireQuest_Hard, nil, bCanHardReceive)
      ;
      (RedDotManager.SetValid)(RedDotDefine.VampireQuest_Season, nil, bCanSeasonReceive)
    end
  end
end

PlayerQuestData.ClearVampireSeasonQuest = function(self, nCurSeason)
  -- function num : 0_72 , upvalues : _ENV
  local mapSeasonData = (ConfigTable.GetData)("VampireRankSeason", nCurSeason)
  local tbRemove = {}
  if mapSeasonData ~= nil then
    local nSeasonGroupId = mapSeasonData.QuestGroup
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R5 in 'UnsetPending'

    if (self._mapQuest)[9] == nil then
      (self._mapQuest)[9] = {}
    end
    for nTid,mapQuest in pairs((self._mapQuest)[9]) do
      local mapQuestCfgData = (ConfigTable.GetData)("VampireRankSeason", nTid)
      if mapQuestCfgData ~= nil and mapQuestCfgData.GroupId ~= nSeasonGroupId then
        (table.insert)(tbRemove, nTid)
      end
    end
    for _,nQuestId in ipairs(tbRemove) do
      -- DECOMPILER ERROR at PC49: Confused about usage of register: R10 in 'UnsetPending'

      if ((self._mapQuest)[9])[nQuestId] ~= nil then
        ((self._mapQuest)[9])[nQuestId] = nil
      end
    end
  end
end

return PlayerQuestData

