local EquipmentInfoPanel = class("EquipmentInfoPanel", BasePanel)
EquipmentInfoPanel._bIsMainPanel = false
EquipmentInfoPanel._tbDefine = {
{sPrefabPath = "Equipment/EquipmentInfoPanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentInfoCtrl"}
}
EquipmentInfoPanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentInfoPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentInfoPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

EquipmentInfoPanel.OnDisable = function(self)
  -- function num : 0_3
end

EquipmentInfoPanel.OnDestroy = function(self)
  -- function num : 0_4
end

EquipmentInfoPanel.OnRelease = function(self)
  -- function num : 0_5
end

return EquipmentInfoPanel

