local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local GoldenSpyData = class("GoldenSpyData", ActivityDataBase)
local GoldenSpyLevelData = require("Game.UI.Activity.GoldenSpy.GoldenSpyLevelData")
local ClientManager = (CS.ClientManager).Instance
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
GoldenSpyData.Init = function(self)
  -- function num : 0_0 , upvalues : GoldenSpyLevelData
  self.GoldenSpyLevelData = (GoldenSpyLevelData.new)()
  self.cacheEnterGroupList = {}
  self.tbLevelGroupData = {}
  self.tbLevelData = {}
  self.cacheEnterFloorList = {}
  self:AddListeners()
end

GoldenSpyData.AddListeners = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

GoldenSpyData.OnEvent_NewDay = function(self)
  -- function num : 0_2
end

GoldenSpyData.RefreshGoldenSpyActData = function(self, actId, msgData)
  -- function num : 0_3 , upvalues : LocalData, _ENV
  self:Init()
  self.nActId = actId
  self.tbLevelGroupData = {}
  self.tbLevelData = {}
  local sJson = (LocalData.GetPlayerLocalData)("GoldenSpyGroupData")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.cacheEnterGroupList = tb
  end
  local sfloorJson = (LocalData.GetPlayerLocalData)("GoldenSpyFloorData")
  local tbFloor = decodeJson(sfloorJson)
  if type(tbFloor) == "table" then
    self.cacheEnterFloorList = tbFloor
  end
  self:CacheAllLevelData(msgData.Levels)
end

GoldenSpyData.CacheAllLevelData = function(self, msgData)
  -- function num : 0_4 , upvalues : _ENV
  local controllCfg = (ConfigTable.GetData)("GoldenSpyControl", self.nActId)
  if controllCfg == nil then
    return 
  end
  for _,v in ipairs(controllCfg.LevelGroupList) do
    local levelGroupCfg = (ConfigTable.GetData)("GoldenSpyLevelGroup", v)
    if levelGroupCfg ~= nil then
      local levelGroupData = {nId = levelGroupCfg.Id, nStartTime = self:GetGroupStartTime(levelGroupCfg.Id)}
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (self.tbLevelGroupData)[levelGroupCfg.Id] = levelGroupData
      for _,v in ipairs(levelGroupCfg.LevelList) do
        local levelCfg = (ConfigTable.GetData)("GoldenSpyLevel", v)
        if levelCfg ~= nil then
          local levelData = {nId = levelCfg.Id, nMaxScore = 0, bFirstComplete = false}
          self:UpdateLevelData(levelData)
        end
      end
    end
  end
  if msgData ~= nil then
    for _,v in ipairs(msgData) do
      local levelData = {nId = v.LevelId, nMaxScore = v.MaxScore or 0, bFirstComplete = v.FirstComplete}
      self:UpdateLevelData(levelData)
    end
  end
  do
    self:RefreshRedDot()
  end
end

GoldenSpyData.UpdateLevelData = function(self, levelData)
  -- function num : 0_5
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.tbLevelData)[levelData.nId] = levelData
end

GoldenSpyData.GetLevelDataById = function(self, levelId)
  -- function num : 0_6
  return (self.tbLevelData)[levelId]
end

GoldenSpyData.CheckPreLevelPassById = function(self, levelId)
  -- function num : 0_7 , upvalues : _ENV
  local levelCfg = (ConfigTable.GetData)("GoldenSpyLevel", levelId)
  if levelCfg == nil then
    return false
  end
  local preLevelId = levelCfg.PreLevelId
  if preLevelId == 0 then
    return true
  end
  local preLevelData = self:GetLevelDataById(preLevelId)
  if preLevelData == nil then
    return true
  end
  return preLevelData.bFirstComplete
end

GoldenSpyData.GetGroupIsNew = function(self, groupId)
  -- function num : 0_8 , upvalues : _ENV
  if (table.indexof)(self.cacheEnterGroupList, groupId) == 0 then
    return true
  end
  return false
end

GoldenSpyData.EnterGroupSelect = function(self, groupId)
  -- function num : 0_9 , upvalues : _ENV, LocalData, RapidJson, RedDotManager
  local actGroupId = ((ConfigTable.GetData)("Activity", self.nActId)).MidGroupId
  if (table.indexof)(self.cacheEnterGroupList, groupId) == 0 then
    (table.insert)(self.cacheEnterGroupList, groupId)
    ;
    (LocalData.SetPlayerLocalData)("GoldenSpyGroupData", (RapidJson.encode)(self.cacheEnterGroupList))
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_GoldenSpy_Group, {actGroupId, groupId}, false)
    self:RefreshRedDot()
  end
end

GoldenSpyData.GetLevelGroupDataById = function(self, groupId)
  -- function num : 0_10
  return (self.tbLevelGroupData)[groupId]
end

GoldenSpyData.GetAllLevelGroupData = function(self)
  -- function num : 0_11
  return self.tbLevelGroupData
end

GoldenSpyData.CheckPreGroupPassByGroupId = function(self, groupId)
  -- function num : 0_12 , upvalues : _ENV
  local tbGroupList = ((ConfigTable.GetData)("GoldenSpyControl", self.nActId)).LevelGroupList
  local nIndex = (table.indexof)(tbGroupList, groupId)
  if nIndex == 1 then
    return true
  end
  local preGroupId = tbGroupList[nIndex - 1]
  local preGroupData = self:GetLevelGroupDataById(preGroupId)
  if preGroupData == nil then
    return false
  end
  local groupCfg = (ConfigTable.GetData)("GoldenSpyLevelGroup", preGroupId)
  if groupCfg == nil then
    return false
  end
  local bAllLevelPass = true
  for _,levelId in ipairs(groupCfg.LevelList) do
    local levelData = self:GetLevelDataById(levelId)
    local levelCfg = (ConfigTable.GetData)("GoldenSpyLevel", levelId)
    if levelData == nil then
      bAllLevelPass = false
      break
    end
    if not levelData.bFirstComplete then
      bAllLevelPass = false
      break
    end
  end
  do
    return bAllLevelPass
  end
end

GoldenSpyData.GetGroupStartTime = function(self, groupId)
  -- function num : 0_13 , upvalues : _ENV, ClientManager
  local groupConfig = (ConfigTable.GetData)("GoldenSpyLevelGroup", groupId)
  if groupConfig == nil then
    return 0
  end
  local openActDayNextTime = ClientManager:GetNextRefreshTime(self.nOpenTime)
  local nTempDay = 0
  if self.nOpenTime < openActDayNextTime then
    nTempDay = 1
  end
  local nDay = (ClientManager.serverTimeStamp - openActDayNextTime) // 86400 + nTempDay
  if groupConfig.DayOpen <= nDay then
    return 0
  end
  local openDayNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  return openDayNextTime + (groupConfig.DayOpen - nDay - 1) * 86400
end

GoldenSpyData.GetGoldenSpyLevelData = function(self)
  -- function num : 0_14
  return self.GoldenSpyLevelData
end

GoldenSpyData.GetGoldenSpyFloorData = function(self)
  -- function num : 0_15
  return (self.GoldenSpyLevelData):GetFloorData()
end

GoldenSpyData.RefreshRedDot = function(self)
  -- function num : 0_16 , upvalues : _ENV, RedDotManager
  if not self:GetPlayState() then
    return 
  end
  local actGroupId = ((ConfigTable.GetData)("Activity", self.nActId)).MidGroupId
  for _,groupData in pairs(self.tbLevelGroupData) do
    if ((CS.ClientManager).Instance).serverTimeStamp < groupData.nStartTime and groupData.nStartTime ~= 0 then
      (RedDotManager.SetValid)(RedDotDefine.Activity_GoldenSpy_Group, {actGroupId, groupData.nId}, false)
    else
      if not self:CheckPreGroupPassByGroupId(groupData.nId) then
        (RedDotManager.SetValid)(RedDotDefine.Activity_GoldenSpy_Group, {actGroupId, groupData.nId}, false)
      else
        ;
        (RedDotManager.SetValid)(RedDotDefine.Activity_GoldenSpy_Group, {actGroupId, groupData.nId}, self:GetGroupIsNew(groupData.nId))
      end
    end
  end
end

GoldenSpyData.StartLevel = function(self, groupId, levelId)
  -- function num : 0_17 , upvalues : _ENV
  self.nGroupId = groupId
  ;
  (self.GoldenSpyLevelData):InitData()
  ;
  (self.GoldenSpyLevelData):StartLevel(levelId)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.GoldenSpyPanel, self.nActId, self.nGroupId, levelId)
end

GoldenSpyData.FinishLevel = function(self, levelId, data, callback)
  -- function num : 0_18 , upvalues : _ENV
  local items = {}
  for _,v in pairs(data.tbItems) do
    local data = {ItemId = v.itemId, PickCount = v.itemCount}
    ;
    (table.insert)(items, data)
  end
  local skills = {}
  for k,v in pairs(data.tbSkills) do
    local data = {SkillId = k, UseCount = v}
    ;
    (table.insert)(skills, data)
  end
  local mapMsg = {ActivityId = self.nActId, LevelId = levelId, Floor = data.nFloor, Score = data.nScore, CompletedTaskCount = data.nTaskCompleteCount, Items = items, Skills = skills}
  local callback = function(_, msgData)
    -- function num : 0_18_0 , upvalues : self, levelId, _ENV, data, callback
    local oldLevelData = self:GetLevelDataById(levelId)
    local levelCfg = (ConfigTable.GetData)("GoldenSpyLevel", levelId)
    local levelData = {nId = levelId, nMaxScore = (math.max)(oldLevelData.nMaxScore, data.nScore), bFirstComplete = oldLevelData.bFirstComplete or levelCfg.Score <= data.nScore}
    self:UpdateLevelData(levelData)
    if callback ~= nil then
      callback()
    end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_gds_settle_req, mapMsg, nil, callback)
end

GoldenSpyData.EnterFloor = function(self, floorId)
  -- function num : 0_19 , upvalues : _ENV, LocalData, RapidJson
  if (table.indexof)(self.cacheEnterFloorList, floorId) == 0 then
    (table.insert)(self.cacheEnterFloorList, floorId)
    ;
    (LocalData.SetPlayerLocalData)("GoldenSpyFloorData", (RapidJson.encode)(self.cacheEnterFloorList))
  end
end

GoldenSpyData.GetFloorIsNew = function(self, floorId)
  -- function num : 0_20 , upvalues : _ENV
  if (table.indexof)(self.cacheEnterFloorList, floorId) == 0 then
    return true
  end
  return false
end

return GoldenSpyData

