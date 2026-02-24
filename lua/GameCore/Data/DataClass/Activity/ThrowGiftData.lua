local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ThrowGiftData = class("ThrowGiftData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
ThrowGiftData.Init = function(self)
  -- function num : 0_0
  self.nActId = 0
  self.mapLevels = {}
  self.mapItems = {}
  self.tbNewLevel = {}
end

ThrowGiftData.RefreshQuestData = function(self, questData)
  -- function num : 0_1
end

ThrowGiftData.RefreshThrowGiftData = function(self, nActId, msgData)
  -- function num : 0_2 , upvalues : _ENV
  self:Init()
  self.nActId = nActId
  for _,mapLevel in ipairs(msgData.Levels) do
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R8 in 'UnsetPending'

    (self.mapLevels)[mapLevel.LevelId] = mapLevel
  end
  for _,mapItem in ipairs(msgData.Items) do
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R8 in 'UnsetPending'

    (self.mapItems)[mapItem.ItemId] = mapItem.Count
  end
  self:UpdateNewState()
end

ThrowGiftData.GetActivityData = function(self)
  -- function num : 0_3 , upvalues : _ENV
  return {nActId = self.nActId, mapLevels = clone(self.mapLevels), mapItems = clone(self.mapItems)}
end

ThrowGiftData.SettleLevels = function(self, nLevelId, nThrowGiftCount, nHitGiftCount, nScore, tbUseItems, bWin, callback)
  -- function num : 0_4 , upvalues : _ENV
  local msg = {}
  msg.ActivityId = self.nActId
  msg.LevelId = nLevelId
  msg.ThrowGiftCount = nThrowGiftCount
  msg.HitGiftCount = nHitGiftCount
  msg.Score = nScore
  msg.UseItems = tbUseItems
  msg.Win = bWin
  local msgCallback = function(_, msgData)
    -- function num : 0_4_0 , upvalues : self, nLevelId, nScore, bWin, _ENV, tbUseItems, callback
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R2 in 'UnsetPending'

    if (self.mapLevels)[nLevelId] == nil then
      (self.mapLevels)[nLevelId] = {LevelId = nLevelId, MaxScore = nScore, FirstComplete = bWin}
    else
      -- DECOMPILER ERROR at PC27: Confused about usage of register: R2 in 'UnsetPending'

      if ((self.mapLevels)[nLevelId]).MaxScore < nScore then
        ((self.mapLevels)[nLevelId]).MaxScore = nScore
      end
      -- DECOMPILER ERROR at PC38: Confused about usage of register: R2 in 'UnsetPending'

      if not bWin then
        ((self.mapLevels)[nLevelId]).FirstComplete = ((self.mapLevels)[nLevelId]).FirstComplete
        for k,v in pairs(tbUseItems) do
          -- DECOMPILER ERROR at PC50: Confused about usage of register: R7 in 'UnsetPending'

          if (self.mapItems)[v.ItemId] == nil then
            (self.mapItems)[v.ItemId] = 0
          end
          -- DECOMPILER ERROR at PC58: Confused about usage of register: R7 in 'UnsetPending'

          ;
          (self.mapItems)[v.ItemId] = (self.mapItems)[v.ItemId] + v.Count
        end
        if callback ~= nil then
          callback(msgData)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_throw_gift_settle_req, msg, nil, msgCallback)
end

ThrowGiftData.GetDicFirstIn = function(self, nDicId)
  -- function num : 0_5 , upvalues : _ENV, LocalData
  local sKey = tostring(self.nActId) .. tostring(nDicId) .. "IsFirst"
  local bIsFirst = (LocalData.GetPlayerLocalData)(sKey)
  if bIsFirst == nil then
    bIsFirst = true
  end
  if bIsFirst then
    (LocalData.SetPlayerLocalData)(sKey, false)
  end
  return bIsFirst
end

ThrowGiftData.GetLevelNewStateInternal = function(self, nLevelId)
  -- function num : 0_6 , upvalues : _ENV, LocalData
  local mapLevelCfgData = (ConfigTable.GetData)("ThrowGiftLevel", nLevelId)
  if mapLevelCfgData == nil then
    return false
  end
  local nOpenTime = self:GetActOpenTime()
  if mapLevelCfgData.DayOpen ~= 0 and mapLevelCfgData.DayOpen ~= nil and nOpenTime ~= 0 then
    local nServerTimeStamp = ((CS.ClientManager).Instance).serverTimeStamp
    local nUnlockTime = mapLevelCfgData.DayOpen * 86400 + nOpenTime
    if nUnlockTime - nServerTimeStamp <= 0 then
      local sKey = tostring(self.nActId) .. tostring(nLevelId) .. "LevelNew"
      local bIsFirst = (LocalData.GetPlayerLocalData)(sKey)
      if bIsFirst == nil then
        bIsFirst = true
      end
      if bIsFirst then
        return true
      end
    end
  end
  do
    return false
  end
end

ThrowGiftData.SetLevelNew = function(self, nLevelId)
  -- function num : 0_7 , upvalues : _ENV, LocalData
  local idx = (table.indexof)(self.tbNewLevel, nLevelId)
  if idx > 0 then
    (table.remove)(self.tbNewLevel, idx)
  end
  local sKey = tostring(self.nActId) .. tostring(nLevelId) .. "LevelNew"
  ;
  (LocalData.SetPlayerLocalData)(sKey, false)
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_ThrowGift_NewLevel, {self.nActId, nLevelId}, false)
end

ThrowGiftData.UpdateNewState = function(self)
  -- function num : 0_8 , upvalues : _ENV, LocalData
  self.tbNewLevel = {}
  local foreachLevel = function(mapData)
    -- function num : 0_8_0 , upvalues : self, _ENV
    if mapData.ActivityId == self.nActId then
      local bNewState = self:GetLevelNewStateInternal(mapData.Id)
      if bNewState then
        (table.insert)(self.tbNewLevel, mapData.Id)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_ThrowGift_NewLevel, {self.nActId, mapData.Id}, bNewState)
    end
  end

  ForEachTableLine(DataTable.ThrowGiftLevel, foreachLevel)
  local bNew = (LocalData.GetPlayerLocalData)("Activity_ThrowGift_New")
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_ThrowGift_New, {self.nActId}, bNew ~= true)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ThrowGiftData.GetLevelNewState = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  do return (table.indexof)(self.tbNewLevel, nLevelId) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ThrowGiftData.GetNewLevels = function(self)
  -- function num : 0_10 , upvalues : _ENV
  return clone(self.tbNewLevel)
end

return ThrowGiftData

