local GoldenSpyFloorData = class("GoldenSpyFloorData")
GoldenSpyFloorData.ctor = function(self)
  -- function num : 0_0
end

GoldenSpyFloorData.InitData = function(self)
  -- function num : 0_1
  self.tbItem = {}
end

GoldenSpyFloorData.StartFloor = function(self, levelId, floorId)
  -- function num : 0_2 , upvalues : _ENV
  self.levelId = levelId
  self.floorId = floorId
  self.floorConfig = (ConfigTable.GetData)("GoldenSpyFloor", floorId)
  if self.floorConfig == nil then
    return 
  end
end

GoldenSpyFloorData.GetCurFloor = function(self)
  -- function num : 0_3
  return self.floorId
end

GoldenSpyFloorData.GetFloorConfig = function(self)
  -- function num : 0_4
  return self.floorConfig
end

GoldenSpyFloorData.SetItem = function(self, itemId)
  -- function num : 0_5
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbItem)[itemId] == nil then
    (self.tbItem)[itemId] = {itemId = itemId, itemCount = 0}
  end
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbItem)[itemId]).itemCount = ((self.tbItem)[itemId]).itemCount + 1
end

GoldenSpyFloorData.DeleteItem = function(self, itemId)
  -- function num : 0_6 , upvalues : _ENV
  if (self.tbItem)[itemId] == nil then
    return 
  end
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbItem)[itemId]).itemCount = ((self.tbItem)[itemId]).itemCount - 1
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

  if ((self.tbItem)[itemId]).itemCount <= 0 then
    (self.tbItem)[itemId] = nil
  end
  local itemCfg = (ConfigTable.GetData)("GoldenSpyItem", itemId)
  if itemCfg.ItemType == (GameEnum.GoldenSpyItem).BuffItem then
    return 
  end
  local nCount = 0
  for k,v in pairs(self.tbItem) do
    local itemCfg = (ConfigTable.GetData)("GoldenSpyItem", k)
    if itemCfg ~= nil and itemCfg.ItemType ~= (GameEnum.GoldenSpyItem).Boom then
      nCount = nCount + v.itemCount
    end
  end
  do
    if self.tbItem == nil or nCount <= 0 then
      (EventManager.Hit)("GoldenSpy_FinishFloor")
    end
  end
end

GoldenSpyFloorData.GetItems = function(self)
  -- function num : 0_7
  return self.tbItem
end

return GoldenSpyFloorData

