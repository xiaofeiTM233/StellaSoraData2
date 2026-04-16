local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local BreakOutData = class("BreakOutData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = (CS.ClientManager).Instance
local BreakOutLevelData = require("GameCore.Data.DataClass.Activity.BreakOutLevelData")
BreakOutData.Init = function(self)
  -- function num : 0_0 , upvalues : BreakOutLevelData
  self.allLevelData = {}
  self.cacheEnterLevelList = {}
  self.BreakOutLevelData = (BreakOutLevelData.new)()
  self.tempData = nil
  self.ActEnd = self:IsActTimeEnd()
  self:AddListeners()
end

BreakOutData.AddListeners = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Add)("MilkoutCharacterUnlock", self, self.On_BreakoutCharacter_Unlock)
  ;
  (EventManager.Add)("ClearAllLevels", self, self.OnEvent_GMClearAllLevels)
end

BreakOutData.RefreshBreakOutData = function(self, actId, msgData)
  -- function num : 0_2 , upvalues : _ENV, LocalData
  self:Init()
  self.nActId = actId
  self.mapActData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not (self.mapActData):GetActEndTime() then
    self.nEndTime = self.mapActData == nil or 0
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
end

BreakOutData.CacheAllCharacterData = function(self, UnLockedCharacterData)
  -- function num : 0_3 , upvalues : _ENV
  self.tbUnLockedCharacterDataList = {}
  self.tbUnLockedCharacterDataMap = {}
  for _,v in pairs(UnLockedCharacterData) do
    local CharacterData = {nId = v.Id, nBattleTimes = v.BattleTimes}
    ;
    (table.insert)(self.tbUnLockedCharacterDataList, CharacterData)
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbUnLockedCharacterDataMap)[v.Id] = CharacterData
  end
end

BreakOutData.CacheIsUnlocked = function(self, CharacterNid)
  -- function num : 0_4
  if (self.tbUnLockedCharacterDataMap)[CharacterNid] then
    return true
  end
  return false
end

BreakOutData.GetDataFromBreakOutCharacter = function(self, CharacterNid)
  -- function num : 0_5 , upvalues : _ENV
  if (self.tbUnLockedCharacterDataMap)[CharacterNid] then
    return (ConfigTable.GetData)("BreakOutCharacter", CharacterNid)
  end
  return nil
end

BreakOutData.GetSkillData = function(self, CharacterNid)
  -- function num : 0_6
  local tbCharacterData = self:GetDataFromBreakOutCharacter(CharacterNid)
  if tbCharacterData == nil then
    return nil
  else
    return tbCharacterData.SkillId
  end
end

BreakOutData.GetBattleCount = function(self, CharacterNid)
  -- function num : 0_7
  if (self.tbUnLockedCharacterDataMap)[CharacterNid] ~= nil then
    return ((self.tbUnLockedCharacterDataMap)[CharacterNid]).nBattleTimes
  else
    return 0
  end
end

BreakOutData.CacheAllLevelData = function(self, levelListData)
  -- function num : 0_8 , upvalues : _ENV
  self.tbLevelDataList = {}
  self.tbLevelDataMap = {}
  for _,v in pairs(levelListData) do
    local config = (ConfigTable.GetData)("BreakOutLevel", v.Id)
    local levelData = {nId = v.Id, bFirstComplete = v.FirstComplete, nDifficultyType = config.Type, nPreLevelId = config.PreLevelId}
    ;
    (table.insert)(self.tbLevelDataList, levelData)
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbLevelDataMap)[v.Id] = levelData
  end
end

BreakOutData.IsAllLevelComplete = function(self)
  -- function num : 0_9 , upvalues : _ENV
  for _,v in pairs(self.tbLevelDataList) do
    if not v.bFirstComplete then
      return false
    end
  end
  return true
end

BreakOutData.GetLevelData = function(self)
  -- function num : 0_10
  return self.tbLevelDataList
end

BreakOutData.GetLevelDataById = function(self, nId)
  -- function num : 0_11 , upvalues : _ENV
  if (self.tbLevelDataMap)[nId] ~= nil then
    return (self.tbLevelDataMap)[nId]
  else
    printLog(nId .. ":Id不存在对应关卡数据")
    return nil
  end
end

BreakOutData.UpdateLevelData = function(self, levelData)
  -- function num : 0_12 , upvalues : _ENV
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == levelData.Id then
      v.bFirstComplete = levelData.FirstComplete
      break
    end
  end
  do
    local levelConfig = (ConfigTable.GetData)("BreakOutLevel", levelData.Id)
    if levelConfig == nil then
      return 
    end
    if not self:GetPlayState() or self:IsLevelUnlocked(levelData.Id) then
    end
  end
end

BreakOutData.UpdateCharacterData = function(self, CharacterData)
  -- function num : 0_13 , upvalues : _ENV
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbUnLockedCharacterDataMap)[CharacterData.CharacterNid] ~= nil then
    ((self.tbUnLockedCharacterDataMap)[CharacterData.CharacterNid]).nBattleTimes = ((self.tbUnLockedCharacterDataMap)[CharacterData.CharacterNid]).nBattleTimes + 1
    ;
    (EventManager.Hit)("RefreshCharacterBattleTimes")
  end
end

BreakOutData.GetDetailLevelDataById = function(self, nId)
  -- function num : 0_14 , upvalues : _ENV
  if (self.tbLevelDataMap)[nId] then
    return (ConfigTable.GetData)("BreakOutLevel", nId)
  end
  return nil
end

BreakOutData.GetDetailFloorDataById = function(self, nId)
  -- function num : 0_15 , upvalues : _ENV
  do
    if (self.tbLevelDataMap)[nId] then
      local nFloorId = ((ConfigTable.GetData)("BreakOutLevel", nId)).FloorId
      return (ConfigTable.GetData)("BreakOutFloor", nFloorId)
    end
    return nil
  end
end

BreakOutData.GetLevelsByTab = function(self, nTabIndex)
  -- function num : 0_16 , upvalues : _ENV
  local levelData = {}
  for _,v in pairs(self.tbLevelDataList) do
    if v.nDifficultyType == nTabIndex then
      (table.insert)(levelData, (ConfigTable.GetData)("BreakOutLevel", v.nId))
    end
  end
  ;
  (table.sort)(levelData, function(a, b)
    -- function num : 0_16_0
    do return a.Difficulty < b.Difficulty end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return levelData
end

BreakOutData.GetBreakoutLevelTypeNum = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local nNum = 0
  for _,_ in pairs(GameEnum.ActivityBreakoutLevelType) do
    nNum = nNum + 1
  end
  return nNum
end

BreakOutData.GetBreakoutPreLevelIdName = function(self, nLevelId)
  -- function num : 0_18 , upvalues : _ENV
  local LevelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if LevelData == nil then
    return 
  else
    local nPreLevelId = ((ConfigTable.GetData)("BreakOutLevel", nLevelId)).PreLevelId
    local PreLevelIdName = ((ConfigTable.GetData)("BreakOutLevel", nPreLevelId)).Name
    return PreLevelIdName
  end
end

BreakOutData.GetBreakoutLevelDifficult = function(self, nLevelId)
  -- function num : 0_19 , upvalues : _ENV
  local LevelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if LevelData == nil then
    return 
  else
    return LevelData.Type
  end
end

BreakOutData.GetCurrentSelectedTabIndex = function(self)
  -- function num : 0_20 , upvalues : _ENV
  local EasyDifficultyType = (GameEnum.ActivityBreakoutLevelType).Expert
  for _,levelData in ipairs(self.tbLevelDataList) do
    if not levelData.bFirstComplete and levelData.nDifficultyType <= EasyDifficultyType then
      EasyDifficultyType = levelData.nDifficultyType
    end
  end
  return EasyDifficultyType
end

BreakOutData.RefreshRedDot = function(self)
  -- function num : 0_21 , upvalues : _ENV, RedDotManager
  if self.tbLevelDataList == nil then
    return 
  end
  local bRedDot = false
  local nActivityGroupId = ((ConfigTable.GetData)("Activity", self.nActId)).MidGroupId
  for _,levelData in ipairs(self.tbLevelDataList) do
    if self:IsLevelTimeUnlocked(levelData.nId) then
      if self.ActEnd then
        bRedDot = false
      else
        bRedDot = self:GetLevelIsNew(levelData.nId)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, levelData.nId}, bRedDot)
    end
  end
end

BreakOutData.IsActTimeEnd = function(self)
  -- function num : 0_22 , upvalues : _ENV
  local isEnd = false
  local LevelEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((ConfigTable.GetConfigValue)("BreakOut_LevelClosed"))
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  if LevelEndTime >= nCurTime then
    do return LevelEndTime == nil end
    printError("config 表：" .. "BreakOut_LevelClosed" .. " Value数据为空")
    do return isEnd end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

BreakOutData.GetLevelIsNew = function(self, levelId)
  -- function num : 0_23 , upvalues : _ENV
  local bResult = false
  local levelData = self:GetLevelDataById(levelId)
  if levelData ~= nil and levelData.bFirstComplete == false and (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
    bResult = true
  end
  return bResult
end

BreakOutData.EnterLevelSelect = function(self, nLevelId)
  -- function num : 0_24 , upvalues : _ENV, RedDotManager, LocalData, RapidJson
  local levelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if levelData == nil then
    return 
  end
  local nActivityGroupId = ((ConfigTable.GetData)("Activity", levelData.ActivityId)).MidGroupId
  if (table.indexof)(self.cacheEnterLevelList, nLevelId) == 0 or (RedDotManager.GetValid)(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, nLevelId}) then
    (table.insert)(self.cacheEnterLevelList, nLevelId)
    local tbLocalSave = {}
    for _,v in ipairs(self.cacheEnterLevelList) do
      (table.insert)(tbLocalSave, v)
    end
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, nLevelId}, false)
    ;
    (LocalData.SetPlayerLocalData)("BreakOutLevel", (RapidJson.encode)(tbLocalSave))
    self:RefreshRedDot()
  end
end

BreakOutData.IsLevelUnlocked = function(self, nLevelId)
  -- function num : 0_25 , upvalues : _ENV
  local bTimeUnlock, bPreComplete = false, false
  local mapData = self:GetDetailLevelDataById(nLevelId)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local openTime = ((CS.ClientManager).Instance):GetNextRefreshTime(self.nOpenTime) - 86400
  local remainTime = openTime + mapData.DayOpen * 86400 - curTime
  local nPreLevelId = mapData.PreLevelId or 0
  local bIsLevelComplete = self:IsLevelComplete(nPreLevelId)
  bTimeUnlock = remainTime <= 0
  if nPreLevelId ~= nil then
    bPreComplete = bIsLevelComplete
    bPreComplete = bPreComplete
    do return bTimeUnlock, bPreComplete end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

BreakOutData.IsLevelTimeUnlocked = function(self, nLevelId)
  -- function num : 0_26
  local bTimeUnlock = false
  local remainTime = self:GetLevelStartTime(nLevelId)
  bTimeUnlock = not remainTime or remainTime <= 0
  do return bTimeUnlock end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

BreakOutData.GetLevelStartTime = function(self, nLevelId)
  -- function num : 0_27 , upvalues : _ENV
  local mapData = self:GetDetailLevelDataById(nLevelId)
  if mapData == nil then
    return nil
  end
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local openTime = ((CS.ClientManager).Instance):GetNextRefreshTime(self.nOpenTime) - 86400
  local remainTime = openTime + mapData.DayOpen * 86400 - curTime
  return remainTime
end

BreakOutData.IsPreLevelComplete = function(self, nLevelId)
  -- function num : 0_28 , upvalues : _ENV
  local tbLevelData = (ConfigTable.GetData)("BreakOutLevel", nLevelId)
  if tbLevelData == nil then
    printLog(nLevelId .. ":Id不存在对应关卡数据")
    return false
  end
  local nPreLevelId = tbLevelData.PreLevelId
  if nPreLevelId == 0 then
    return true
  end
  return (self:GetLevelDataById(nPreLevelId)).bFirstComplete
end

BreakOutData.IsLevelComplete = function(self, nLevelId)
  -- function num : 0_29
  if nLevelId == 0 then
    return true
  end
  local nLevelData = self:GetLevelDataById(nLevelId)
  if nLevelData == nil then
    return false
  end
  return nLevelData.bFirstComplete
end

BreakOutData.GetUnFinishEasyLevel = function(self)
  -- function num : 0_30 , upvalues : _ENV
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

BreakOutData.RequestFinishLevel = function(self, arrayData, cb)
  -- function num : 0_31 , upvalues : _ENV
  self:UpdateCharacterData({CharacterNid = arrayData.CharId})
  ;
  (EventManager.Hit)("SetPlayFinishState", true)
  if not arrayData.Win then
    local mapMsg = arrayData
    local failCallback = function()
    -- function num : 0_31_0 , upvalues : cb
    if cb ~= nil then
      cb()
    end
  end

    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.BreakOutLevelDetailPanel)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).milkout_settle_req, mapMsg, nil, failCallback)
    return 
  end
  do
    self:CreateTempData(arrayData.LevelId, arrayData.Win)
    local mapMsg = arrayData
    local successCallback = function(_, mapMainData)
    -- function num : 0_31_1 , upvalues : cb, self, arrayData
    cb(mapMainData)
    self:UpdateLevelData({Id = arrayData.LevelId, FirstComplete = arrayData.Win})
  end

    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.BreakOutLevelDetailPanel)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).milkout_settle_req, mapMsg, nil, successCallback)
  end
end

BreakOutData.CreateTempData = function(self, nLevelId, bResult)
  -- function num : 0_32
  self.tempData = {nLevelId = nLevelId, bResult = bResult}
end

BreakOutData.GetTempData = function(self)
  -- function num : 0_33
  return self.tempData
end

BreakOutData.ClearTempData = function(self)
  -- function num : 0_34
  self.tempData = nil
end

BreakOutData.On_BreakoutCharacter_Unlock = function(self, mapMsgData)
  -- function num : 0_35
  if self.nActId ~= mapMsgData.ActivityId then
    return 
  end
  self:RefreshCharacterData(mapMsgData.CharId)
end

BreakOutData.RefreshCharacterData = function(self, charId)
  -- function num : 0_36 , upvalues : _ENV
  local bIsLock = true
  for _,v in pairs(self.tbUnLockedCharacterDataList) do
    if v.nId == charId then
      bIsLock = false
      break
    end
  end
  do
    if bIsLock then
      local CharacterData = {nId = charId, nBattleTimes = 0}
      ;
      (table.insert)(self.tbUnLockedCharacterDataList, CharacterData)
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (self.tbUnLockedCharacterDataMap)[charId] = CharacterData
    end
  end
end

BreakOutData.OnEvent_GMClearAllLevels = function(self, mapMsgData)
  -- function num : 0_37
  if mapMsgData ~= nil then
    self:CacheAllLevelData(mapMsgData.Levels)
  end
end

return BreakOutData

