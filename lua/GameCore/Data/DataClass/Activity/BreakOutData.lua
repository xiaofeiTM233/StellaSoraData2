local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local BreakOutData = class("BreakOutData", ActivityDataBase)
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = (CS.ClientManager).Instance
BreakOutData.Init = function(self)
  -- function num : 0_0
  self.allLevelData = {}
  self.cacheEnterLevelList = {}
end

BreakOutData.RefreshBreakOutData = function(self, actId, msgData)
  -- function num : 0_1 , upvalues : LocalData, _ENV
  self:Init()
  self.nActId = actId
  if msgData ~= nil then
    self:CacheAllLevelData(msgData.Levels)
    self:CacheAllCharacterData(msgData.Characters)
  end
  local sJson = (LocalData.GetPlayerLocalData)("BreakOutLevel")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.cacheEnterLevelList = tb
  end
  self:RefreshRedDot()
end

BreakOutData.CacheAllCharacterData = function(self, UnLockedCharacterData)
  -- function num : 0_2 , upvalues : _ENV
  self.tbUnLockedCharacterDataList = {}
  for _,v in pairs(UnLockedCharacterData) do
    local CharacterData = {nId = v.Id, nBattleTimes = v.BattleTimes}
    ;
    (table.insert)(self.tbUnLockedCharacterDataList, CharacterData)
  end
end

BreakOutData.CacheIsUnlocked = function(self, CharacterId)
  -- function num : 0_3 , upvalues : _ENV
  for _,v in pairs(self.tbUnLockedCharacterDataList) do
    if v.nId == CharacterId then
      return true
    end
  end
  return false
end

BreakOutData.GetDataFromBreakOutCharacter = function(self, CharacterId)
  -- function num : 0_4 , upvalues : _ENV
  for _,v in pairs(self.tbUnLockedCharacterDataList) do
    if v.nId == CharacterId then
      return (CacheTable.GetData)("_BreakOutCharacter", CharacterId)
    end
  end
  return nil
end

BreakOutData.GetBattleCount = function(self, CharacterId)
  -- function num : 0_5 , upvalues : _ENV
  for _,v in pairs(self.tbUnLockedCharacterDataList) do
    if v.nId == CharacterId then
      return v.nBattleTimes
    end
  end
  return 0
end

BreakOutData.CacheAllLevelData = function(self, levelListData)
  -- function num : 0_6 , upvalues : _ENV
  self.tbLevelDataList = {}
  for _,v in pairs(levelListData) do
    local levelData = {nId = v.Id, bFirstComplete = v.FirstComplete, nDifficultyType = ((ConfigTable.GetData)("BreakOutLevel", v.Id)).Type, nPreLevelId = ((ConfigTable.GetData)("BreakOutLevel", v.Id)).PreLevelId}
    ;
    (table.insert)(self.tbLevelDataList, levelData)
  end
end

BreakOutData.GetLevelData = function(self)
  -- function num : 0_7
  return self.tbLevelDataList
end

BreakOutData.GetLevelDataById = function(self, nId)
  -- function num : 0_8 , upvalues : _ENV
  local levelData = nil
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == nId then
      levelData = v
      break
    end
  end
  do
    return levelData
  end
end

BreakOutData.GetDetailLevelDataById = function(self, nId)
  -- function num : 0_9 , upvalues : _ENV
  local levelData = nil
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == nId then
      levelData = (ConfigTable.GetData)("BreakOutLevel", nId)
      break
    end
  end
  do
    return levelData
  end
end

BreakOutData.GetDetailFloorDataById = function(self, nId)
  -- function num : 0_10 , upvalues : _ENV
  local FloorData = nil
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == nId then
      nFloorId = ((ConfigTable.GetData)("BreakOutLevel", nId)).FloorId
      FloorData = (ConfigTable.GetData)("BreakOutFloor", nFloorId)
      break
    end
  end
  do
    return FloorData
  end
end

BreakOutData.GetLevelsByTab = function(self, nTabIndex)
  -- function num : 0_11 , upvalues : _ENV
  local levelData = {}
  for _,v in pairs(self.tbLevelDataList) do
    if v.nDifficultyType == nTabIndex then
      (table.insert)(levelData, (ConfigTable.GetData)("BreakOutLevel", v.nId))
    end
  end
  local sortFunc = function(a, b)
    -- function num : 0_11_0 , upvalues : _ENV
    local aConfig = (ConfigTable.GetData)("BreakOutLevel", a.Id)
    local bConfig = (ConfigTable.GetData)("BreakOutLevel", b.Id)
    do return aConfig.Difficulty < bConfig.Difficulty end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ;
  (table.sort)(levelData, sortFunc)
  return levelData
end

BreakOutData.GetBreakoutLevelTypeNum = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local nNum = 0
  for _,_ in pairs(GameEnum.ActivityBreakoutLevelType) do
    nNum = nNum + 1
  end
  return nNum
end

BreakOutData.GetBreakoutLevelDifficult = function(self, nLevelId)
  -- function num : 0_13 , upvalues : _ENV
  local LevelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if LevelData == nil then
    return 
  else
    return LevelData.Type
  end
end

BreakOutData.GetCurrentSelectedTabIndex = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local EasyDifficultyType = (GameEnum.ActivityBreakoutLevelType).Expert
  for _,levelData in ipairs(self.tbLevelDataList) do
    if not levelData.bFirstComplete and levelData.nDifficultyType <= EasyDifficultyType then
      EasyDifficultyType = levelData.nDifficultyType
    end
  end
  return EasyDifficultyType
end

BreakOutData.GetLevelIsNew = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local bResult = false
  local levelData = self:GetLevelData(levelId)
  if levelData ~= nil and levelData.bFirstComplete == false and (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
    bResult = true
  end
  return bResult
end

BreakOutData.EnterLevelSelect = function(self, nLevelId)
  -- function num : 0_16 , upvalues : _ENV, RedDotManager, LocalData, RapidJson
  local levelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if levelData == nil then
    return 
  end
  local nActivityGroupId = ((ConfigTable.GetData)("Activity", levelData.ActivityId)).MidGroupId
  if (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
    (table.insert)(self.cacheEnterLevelList, levelId)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, levelId}, false)
    ;
    (LocalData.SetPlayerLocalData)("BreakOutLevel", (RapidJson.encode)(self.cacheEnterLevelList))
    self:RefreshRedDot()
  end
end

BreakOutData.IsLevelUnlocked = function(self, nLevelId)
  -- function num : 0_17 , upvalues : _ENV
  local bTimeUnlock, bPreComplete = false, false
  local mapData = self:GetLevelDataById(nLevelId)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  if not self.nOpenTime then
    local remainTime = curTime - (0 + mapData.DayOpen * 86400)
    local nPreLevelId = mapData.nPreLevelId or 0
    local bIsLevelComplete = self:IsLevelComplete(nPreLevelId)
    bTimeUnlock = remainTime >= 0
    if nPreLevelId ~= nil then
      bPreComplete = bIsLevelComplete
      bPreComplete = bPreComplete
      do return bTimeUnlock, bPreComplete end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
end

BreakOutData.IsLevelTimeUnlocked = function(self, nLevelId)
  -- function num : 0_18 , upvalues : _ENV
  local bTimeUnlock = false
  local mapData = self:GetLevelDataById(nLevelId)
  if mapData == nil then
    return false
  end
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  if not self.nOpenTime then
    local remainTime = curTime - (0 + mapData.DayOpen * 86400)
    bTimeUnlock = remainTime >= 0
    do return bTimeUnlock end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
end

BreakOutData.GetLevelStartTime = function(self, nLevelId)
  -- function num : 0_19 , upvalues : _ENV, ClientManager
  local levelConfig = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if levelConfig == nil then
    return 0
  end
  local openDayNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  return openDayNextTime + (levelConfig.DayOpen - 1) * 86400
end

BreakOutData.IsPreLevelComplete = function(self, nLevelId)
  -- function num : 0_20 , upvalues : _ENV
  local nPreLevelId = ((ConfigTable.GetData)("BreakOutLevel", nLevelId)).PreLevelId
  if nPreLevelId == 0 then
    return true
  end
  return (self:GetLevelDataById(nPreLevelId)).bFirstComplete
end

BreakOutData.IsLevelComplete = function(self, nLevelId)
  -- function num : 0_21
  if nLevelId == 0 then
    return true
  end
  local nLevelData = self:GetLevelDataById(nLevelId)
  return nLevelData.bFirstComplete
end

BreakOutData.GetActCloseTime = function(self, nLevelId)
  -- function num : 0_22 , upvalues : _ENV
  local nActivityId = ((ConfigTable.GetData)("BreakOutLevel", nLevelId)).ActivityId
  nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(((ConfigTable.GetData)("Activity", nActivityId)).EndTime)
  return nEndTime
end

BreakOutData.GetUnFinishEasyLevel = function(self)
  -- function num : 0_23 , upvalues : _ENV
  local EasyDifficultyType = (GameEnum.ActivityBreakoutLevelType).Expert
  local levelId = nil
  for _,levelData in ipairs(self.tbLevelDataList) do
    if not levelData.bFirstComplete and levelData.nDifficultyType <= EasyDifficultyType then
      EasyDifficultyType = levelData.nDifficultyType
      levelId = levelData.nId
    end
  end
  return levelId
end

return BreakOutData

