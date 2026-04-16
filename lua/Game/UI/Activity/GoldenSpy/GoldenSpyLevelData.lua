local GoldenSpyLevelData = class("GoldenSpyLevelData")
local GoldenSpyFloorData = require("Game.UI.Activity.GoldenSpy.GoldenSpyFloorData")
GoldenSpyLevelData.ctor = function(self)
  -- function num : 0_0
end

GoldenSpyLevelData.InitData = function(self)
  -- function num : 0_1 , upvalues : GoldenSpyFloorData
  if self.floorData == nil then
    self.floorData = (GoldenSpyFloorData.new)()
  end
  ;
  (self.floorData):InitData()
  self.nCurScore = 0
  self.nCurFloor = 1
  self.nCurFloorId = nil
  self.tbCatchItem = {}
  self.tbBuff = {}
  self.tbUsedSkill = {}
  self.tbSkillData = {}
  self.taskData = {nScore = 0, 
tbItems = {}
}
  self.nCompleteTaskCount = 0
  self.nLevelType = nil
  self.tbRandomPrefabName = {}
end

GoldenSpyLevelData.StartLevel = function(self, levelId)
  -- function num : 0_2 , upvalues : _ENV
  self.levelId = levelId
  self.levelConfig = (ConfigTable.GetData)("GoldenSpyLevel", levelId)
  if self.levelConfig == nil then
    return 
  end
  self.nCurFloorId = ((self.levelConfig).FloorList)[self.nCurFloor]
  ;
  (self.floorData):StartFloor(levelId, self.nCurFloorId)
  self.nLevelType = (self.levelConfig).LevelType
  local tbSkillData = decodeJson((self.levelConfig).Skill)
  for _,v in ipairs(tbSkillData) do
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R8 in 'UnsetPending'

    (self.tbSkillData)[v[1]] = v[2]
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbUsedSkill)[v[1]] = 0
  end
end

GoldenSpyLevelData.NextFloor = function(self)
  -- function num : 0_3
  self.nCurFloor = self.nCurFloor + 1
  self.nCurFloorId = ((self.levelConfig).FloorList)[self.nCurFloor]
  ;
  (self.floorData):InitData()
  ;
  (self.floorData):StartFloor(self.levelId, self.nCurFloorId)
end

GoldenSpyLevelData.GetFloorData = function(self)
  -- function num : 0_4
  return self.floorData
end

GoldenSpyLevelData.GetCurScore = function(self)
  -- function num : 0_5
  return self.nCurScore
end

GoldenSpyLevelData.AddScore = function(self, nScore)
  -- function num : 0_6
  self.nCurScore = self.nCurScore + nScore
end

GoldenSpyLevelData.GetCurFloor = function(self)
  -- function num : 0_7
  return self.nCurFloor
end

GoldenSpyLevelData.GetTotalFloor = function(self)
  -- function num : 0_8
  return #(self.levelConfig).FloorList
end

GoldenSpyLevelData.GetCurFloorId = function(self)
  -- function num : 0_9
  return self.nCurFloorId
end

GoldenSpyLevelData.GetLevelPrefabName = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local floorCfg = (ConfigTable.GetData)("GoldenSpyFloor", self.nCurFloorId)
  if floorCfg == nil then
    return 
  end
  local nPrefabName = (floorCfg.PrefabName)[1]
  if (self.levelConfig).LevelType == (GameEnum.GoldenSpyLevelType).Random then
    local tbPrefabPool = {}
    for i = 1, #floorCfg.PrefabName do
      (table.insert)(tbPrefabPool, (floorCfg.PrefabName)[i])
    end
    for i = #tbPrefabPool, 1, -1 do
      local index = (table.indexof)(self.tbRandomPrefabName, tbPrefabPool[i])
      if index > 0 then
        (table.remove)(tbPrefabPool, i)
      end
    end
    local nRandomIndex = (math.random)(1, #tbPrefabPool)
    nPrefabName = tbPrefabPool[nRandomIndex]
    ;
    (table.insert)(self.tbRandomPrefabName, nPrefabName)
  end
  do
    return nPrefabName
  end
end

GoldenSpyLevelData.CatchedItem = function(self, nItemId, itemCtrl)
  -- function num : 0_11 , upvalues : _ENV
  local itemCfg = (ConfigTable.GetData)("GoldenSpyItem", nItemId)
  if itemCfg == nil then
    return 
  end
  local nScore = itemCfg.Score
  if itemCtrl ~= nil then
    if (itemCtrl:GetItemCfg()).ItemType == (GameEnum.GoldenSpyItem).SafeBox then
      nScore = itemCtrl:GetScore()
    end
    if (itemCtrl:GetItemCfg()).ItemType == (GameEnum.GoldenSpyItem).Companion then
      nScore = nScore + itemCtrl:GetBagItemPrice()
    end
  end
  for _,v in ipairs(self.tbBuff) do
    local buffCfg = (ConfigTable.GetData)("GoldenSpyBuffCard", v.buffId)
    -- DECOMPILER ERROR at PC73: Unhandled construct in 'MakeBoolean' P1

    if buffCfg ~= nil and buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddScore and (buffCfg.Params)[1] == itemCfg.ItemType and buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).TemporaryBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
      nScore = nScore + (buffCfg.Params)[2]
    end
    if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).DelayBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
      nScore = nScore + (buffCfg.Params)[2]
    end
    if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).PermanentBuff and v.bActive then
      nScore = nScore + (buffCfg.Params)[2]
    end
  end
  if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).SkillCountBuff then
    self.nCurScore = self.nCurScore + (nScore)
    -- DECOMPILER ERROR at PC127: Confused about usage of register: R5 in 'UnsetPending'

    if (self.tbCatchItem)[nItemId] == nil then
      (self.tbCatchItem)[nItemId] = {itemId = nItemId, itemCount = 0}
    end
    -- DECOMPILER ERROR at PC134: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self.tbCatchItem)[nItemId]).itemCount = ((self.tbCatchItem)[nItemId]).itemCount + 1
    ;
    (self.floorData):DeleteItem(nItemId)
    local bFinishTask = self:UpdateTask(nItemId)
    if bFinishTask then
      self:RefreshTask()
    end
    return bFinishTask, nScore
  end
end

GoldenSpyLevelData.GetCatchItemData = function(self)
  -- function num : 0_12
  return self.tbCatchItem
end

GoldenSpyLevelData.GetTaskData = function(self)
  -- function num : 0_13
  return self.taskData
end

GoldenSpyLevelData.RefreshTask = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local nScore = 0
  local tbItems = {}
  self.taskData = {nScore = 0, 
tbItems = {}
}
  local allItems = (self.floorData):GetItems()
  local items = {}
  for _,v in pairs(allItems) do
    local itemCfg = (ConfigTable.GetData)("GoldenSpyItem", v.itemId)
    if itemCfg ~= nil and itemCfg.IsTask then
      (table.insert)(items, v)
    end
  end
  local nTotalItemCount = 0
  for _,v in pairs(items) do
    nTotalItemCount = nTotalItemCount + v.itemCount
  end
  if nTotalItemCount <= 0 then
    return 
  end
  local nRandomMaxCount = (math.min)(nTotalItemCount, 3)
  local nExWeight = 0
  for _,v in ipairs(self.tbBuff) do
    local buffCfg = (ConfigTable.GetData)("GoldenSpyBuffCard", v.buffId)
    -- DECOMPILER ERROR at PC85: Unhandled construct in 'MakeBoolean' P1

    if buffCfg ~= nil and buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddTaskWeight and buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).TemporaryBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
      nExWeight = nExWeight + (buffCfg.Params)[1]
    end
    if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).DelayBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
      nExWeight = nExWeight + (buffCfg.Params)[1]
    end
    if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).PermanentBuff and v.bActive then
      nExWeight = nExWeight + (buffCfg.Params)[1]
    end
  end
  if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).SkillCountBuff then
    local tbRandomTaskConfig = {}
    local nRandomTotalWeight = 0
    local mLogWeight = 0
    local forEachLine_ExScore = function(mapLineData)
    -- function num : 0_14_0 , upvalues : nRandomMaxCount, _ENV, tbRandomTaskConfig, nRandomTotalWeight, nExWeight, mLogWeight
    if mapLineData.ItemCount <= nRandomMaxCount then
      (table.insert)(tbRandomTaskConfig, mapLineData)
      if mapLineData.ItemCount == 1 then
        nRandomTotalWeight = nRandomTotalWeight + mapLineData.Weight + nExWeight
        mLogWeight = mapLineData.Weight + nExWeight
      else
        nRandomTotalWeight = nRandomTotalWeight + mapLineData.Weight
      end
    end
  end

    ForEachTableLine(DataTable.GoldenSpyExtraScore, forEachLine_ExScore)
    if (NovaAPI.IsEditorPlatform)() then
      print("GoldenSpyLevelCtrl: 单个物品任务权重:", mLogWeight, "总权重:", nRandomTotalWeight)
    end
    if #tbRandomTaskConfig <= 0 then
      return 
    end
    local nRandomWeight = (math.random)(1, nRandomTotalWeight)
    local tempWeight = 0
    local nRandomCount = 0
    for i,v in ipairs(tbRandomTaskConfig) do
      if v.ItemCount == 1 then
        tempWeight = tempWeight + v.Weight + (nExWeight)
      else
        tempWeight = tempWeight + v.Weight
      end
      if nRandomWeight <= tempWeight then
        nScore = v.Score
        nRandomCount = v.ItemCount
        break
      end
    end
    do
      local tempNum = 0
      local tempItemList = {}
      for _,v in pairs(items) do
        for i = 1, v.itemCount do
          (table.insert)(tempItemList, v.itemId)
        end
      end
      for i = 1, nRandomCount do
        local nRandomNum = (math.random)(1, #tempItemList)
        ;
        (table.insert)(tbItems, {nItemId = tempItemList[nRandomNum], bFinish = false})
        ;
        (table.remove)(tempItemList, nRandomNum)
      end
      for _,v in ipairs(self.tbBuff) do
        local buffCfg = (ConfigTable.GetData)("GoldenSpyBuffCard", v.buffId)
        -- DECOMPILER ERROR at PC257: Unhandled construct in 'MakeBoolean' P1

        if buffCfg ~= nil and buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddExScoreFactor and buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).TemporaryBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
          nScore = nScore * (1 + (buffCfg.Params)[1] / 100)
          nScore = (math.floor)(nScore)
        end
        if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).DelayBuff and v.bActive and (table.indexof)(v.tbActiveFloor, self.nCurFloor) > 0 then
          nScore = nScore * (1 + (buffCfg.Params)[1] / 100)
          nScore = (math.floor)(nScore)
        end
        if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).PermanentBuff and v.bActive then
          nScore = nScore * (1 + (buffCfg.Params)[1] / 100)
          nScore = (math.floor)(nScore)
        end
      end
      if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).SkillCountBuff then
        self.taskData = {nScore = nScore, tbItems = tbItems}
      end
    end
  end
end

GoldenSpyLevelData.UpdateTask = function(self, nItemId)
  -- function num : 0_15 , upvalues : _ENV
  if self.taskData == nil or (self.taskData).nScore == 0 then
    return false
  end
  for _,v in ipairs((self.taskData).tbItems) do
    if v.nItemId == nItemId and v.bFinish == false then
      v.bFinish = true
      break
    end
  end
  do
    local bFinish = true
    for _,v in ipairs((self.taskData).tbItems) do
      if v.bFinish == false then
        bFinish = false
        break
      end
    end
    do
      if bFinish then
        self:AddScore((self.taskData).nScore)
        self.nCompleteTaskCount = self.nCompleteTaskCount + 1
      end
      return bFinish
    end
  end
end

GoldenSpyLevelData.GetCompleteTaskCount = function(self)
  -- function num : 0_16
  return self.nCompleteTaskCount
end

GoldenSpyLevelData.GetBuffData = function(self)
  -- function num : 0_17
  return self.tbBuff
end

GoldenSpyLevelData.AddBuff = function(self, nBuffId)
  -- function num : 0_18 , upvalues : _ENV
  local buffCfg = (ConfigTable.GetData)("GoldenSpyBuffCard", nBuffId)
  if buffCfg == nil then
    return 
  end
  local buffEntity = {buffId = nBuffId, 
tbActiveFloor = {}
, bActive = false}
  if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).TemporaryBuff then
    (table.insert)(buffEntity.tbActiveFloor, self.nCurFloor)
    buffEntity.bActive = true
    if buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddTimeInFloor then
      buffEntity.bActive = false
    end
  else
    if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).DelayBuff then
      (table.insert)(buffEntity.tbActiveFloor, self.nCurFloor + 1)
      buffEntity.bActive = true
    else
      if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).PermanentBuff then
        buffEntity.bActive = true
      else
        if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).SkillCountBuff then
          buffEntity.bActive = true
          -- DECOMPILER ERROR at PC78: Confused about usage of register: R4 in 'UnsetPending'

          if buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddSkillUseCount then
            (self.tbSkillData)[(buffCfg.Params)[1]] = (self.tbSkillData)[(buffCfg.Params)[1]] + (buffCfg.Params)[2]
            ;
            (EventManager.Hit)("GoldenSpy_UpdateSkillCount", (buffCfg.Params)[1], (self.tbSkillData)[(buffCfg.Params)[1]])
          end
        end
      end
    end
  end
  ;
  (table.insert)(self.tbBuff, buffEntity)
  -- DECOMPILER ERROR at PC131: Confused about usage of register: R4 in 'UnsetPending'

  -- DECOMPILER ERROR at PC131: Unhandled construct in 'MakeBoolean' P1

  if self.taskData ~= nil and (self.taskData).nScore > 0 and buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddExScoreFactor and buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).TemporaryBuff and buffEntity.bActive and (table.indexof)(buffEntity.tbActiveFloor, self.nCurFloor) > 0 then
    (self.taskData).nScore = (self.taskData).nScore * (1 + (buffCfg.Params)[1] / 100)
    -- DECOMPILER ERROR at PC138: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.taskData).nScore = (math.floor)((self.taskData).nScore)
    ;
    (EventManager.Hit)("GoldenSpy_UpdateTaskScore", (self.taskData).nScore)
  end
  -- DECOMPILER ERROR at PC170: Confused about usage of register: R4 in 'UnsetPending'

  if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).DelayBuff and buffEntity.bActive and (table.indexof)(buffEntity.tbActiveFloor, self.nCurFloor) > 0 then
    (self.taskData).nScore = (self.taskData).nScore * (1 + (buffCfg.Params)[1] / 100)
    -- DECOMPILER ERROR at PC177: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.taskData).nScore = (math.floor)((self.taskData).nScore)
    ;
    (EventManager.Hit)("GoldenSpy_UpdateTaskScore", (self.taskData).nScore)
  end
  -- DECOMPILER ERROR at PC202: Confused about usage of register: R4 in 'UnsetPending'

  if buffCfg.BuffType == (GameEnum.GoldenSpyBuffType).PermanentBuff and buffEntity.bActive then
    (self.taskData).nScore = (self.taskData).nScore * (1 + (buffCfg.Params)[1] / 100)
    -- DECOMPILER ERROR at PC209: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.taskData).nScore = (math.floor)((self.taskData).nScore)
    ;
    (EventManager.Hit)("GoldenSpy_UpdateTaskScore", (self.taskData).nScore)
  end
  -- DECOMPILER ERROR at PC233: Unhandled construct in 'MakeBoolean' P1

  if buffCfg.BuffType ~= (GameEnum.GoldenSpyBuffType).SkillCountBuff or buffCfg.EffectType == (GameEnum.GoldenSpyBuffEffect).AddScore then
    (EventManager.Hit)("GoldenSpy_ItemUpdateScore", self.tbBuff)
  end
end

GoldenSpyLevelData.GetSkillData = function(self)
  -- function num : 0_19
  return self.tbSkillData
end

GoldenSpyLevelData.GetUsedSkillData = function(self)
  -- function num : 0_20
  return self.tbUsedSkill
end

GoldenSpyLevelData.UseSkill = function(self, nSkillId)
  -- function num : 0_21
  if (self.tbSkillData)[nSkillId] == nil or (self.tbSkillData)[nSkillId] <= 0 then
    return 
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.tbSkillData)[nSkillId] = (self.tbSkillData)[nSkillId] - 1
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.tbUsedSkill)[nSkillId] = (self.tbUsedSkill)[nSkillId] + 1
end

GoldenSpyLevelData.AddSkill = function(self, nSkillId, nCount)
  -- function num : 0_22 , upvalues : _ENV
  if (self.tbSkillData)[nSkillId] == nil then
    return 
  end
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.tbSkillData)[nSkillId] = (self.tbSkillData)[nSkillId] + nCount
  ;
  (EventManager.Hit)("GoldenSpy_UpdateSkillCount", nSkillId, (self.tbSkillData)[nSkillId])
end

return GoldenSpyLevelData

