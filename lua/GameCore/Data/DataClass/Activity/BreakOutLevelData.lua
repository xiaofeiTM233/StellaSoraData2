local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local BreakOutLevelData = class("BreakOutLevelData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete", InputEnable = "OnEvent_InputEnable", BreakOut_Complete = "SetBreakOut_Complete", SetPlayFinishState = "SetPlayFinishState"}
BreakOutLevelData.InitData = function(self, nLevelId, nCharacterNid, nActId)
  -- function num : 0_0 , upvalues : _ENV, LocalData
  self.nLevelId = nLevelId
  self.tbSkillData = {}
  self.cacheHasDicList = {}
  self.nActId = nActId
  self.nCharacterNid = nCharacterNid
  self.bRestart = false
  self:BindEvent()
  self.tbDropCollect = {}
  self.FloorId = ((ConfigTable.GetData)("BreakOutLevel", nLevelId)).FloorId
  self.bIsEnd = true
  self.bIsFinishGame = false
  local sJson = (LocalData.GetPlayerLocalData)("BreakOutFloorDicId")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.cacheHasDicList = tb
  end
end

BreakOutLevelData.RefreshCharSkillCd = function(self, nCharacterId, nCD)
  -- function num : 0_1
  if self.tbCharacterNid == nil then
    return 
  end
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self.tbCharacterData)[nCharacterId]).nCD = nCD
end

BreakOutLevelData.GetCurrentFloorDrops = function(self, FloorData)
  -- function num : 0_2 , upvalues : _ENV
  if FloorData == nil then
    return 
  end
  for _,DropsId in pairs(FloorData.Drops) do
    local DropData = {Id = DropsId, Count = 0}
    ;
    (table.insert)(self.tbDropCollect, DropData)
  end
  return self.tbDropCollect
end

BreakOutLevelData.IsTrueDrops = function(self, ItemId)
  -- function num : 0_3 , upvalues : _ENV
  if self.tbDropCollect ~= nil then
    for _,v in pairs(self.tbDropCollect) do
      if ItemId == v.Id then
        return true
      end
    end
  end
  do
    return false
  end
end

BreakOutLevelData.BindEvent = function(self)
  -- function num : 0_4 , upvalues : _ENV, mapEventConfig
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

BreakOutLevelData.UnBindEvent = function(self)
  -- function num : 0_5 , upvalues : _ENV, mapEventConfig
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

BreakOutLevelData.OnEvent_UnloadComplete = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if not self.bIsEnd then
    local tempData = {curChar = self.nCharacterNid, nLevelId = self.nLevelId, nActId = self.nActId, FloorId = self.FloorId}
    ;
    (EventManager.Hit)("BreakOutRestart")
    ;
    (EventManager.Hit)("Event_ReStartBreakOut", tempData)
    self.bIsEnd = true
  else
    do
      ;
      (NovaAPI.EnterModule)("MainMenuModuleScene", true)
      self:UnBindEvent()
    end
  end
end

BreakOutLevelData.SetBreakOut_Complete = function(self, bIsEnd)
  -- function num : 0_7
  self.bIsEnd = bIsEnd
end

BreakOutLevelData.GetIsBreakOut_Complete = function(self)
  -- function num : 0_8
  return self.bIsEnd
end

BreakOutLevelData.SetPlayFinishState = function(self, bIsFinishGame)
  -- function num : 0_9
  self.bIsFinishGame = bIsFinishGame
end

BreakOutLevelData.GetIsFinishGame = function(self)
  -- function num : 0_10
  return self.bIsFinishGame
end

BreakOutLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_11 , upvalues : _ENV
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BreakOutPlayPanel, self.nActId, self.nLevelId, self.nCharacterNid)
end

BreakOutLevelData.GetFloorHasDic = function(self, nFloorId)
  -- function num : 0_12 , upvalues : _ENV
  local bResult = true
  if (table.indexof)(self.cacheHasDicList, nFloorId) == 0 then
    bResult = false
  end
  return bResult
end

BreakOutLevelData.OnEvent_SetFloorHasDic = function(self, nFloorId)
  -- function num : 0_13 , upvalues : _ENV, LocalData, RapidJson
  if (table.indexof)(self.cacheHasDicList, nFloorId) == 0 then
    (table.insert)(self.cacheHasDicList, nFloorId)
    local tbLocalSave = {}
    for _,v in ipairs(self.cacheHasDicList) do
      (table.insert)(tbLocalSave, v)
    end
    ;
    (LocalData.SetPlayerLocalData)("BreakOutFloorDicId", (RapidJson.encode)(tbLocalSave))
  end
end

return BreakOutLevelData

