local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ThrowGiftData = class("ThrowGiftData", ActivityDataBase)
ThrowGiftData.Init = function(self)
  -- function num : 0_0
  self.nActId = 0
  self.mapLevels = {}
  self.mapItems = {}
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
    -- function num : 0_4_0 , upvalues : self, nLevelId, nScore, bWin, callback
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
        if callback ~= nil then
          callback()
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_throw_gift_settle_req, msg, nil, msgCallback)
end

return ThrowGiftData

