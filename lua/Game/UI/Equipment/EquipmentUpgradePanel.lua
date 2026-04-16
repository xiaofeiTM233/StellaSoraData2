local EquipmentUpgradePanel = class("EquipmentUpgradePanel", BasePanel)
EquipmentUpgradePanel._bIsMainPanel = false
EquipmentUpgradePanel._tbDefine = {
{sPrefabPath = "Equipment/EquipmentUpgradePanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentUpgradeCtrl"}
}
EquipmentUpgradePanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentUpgradePanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentUpgradePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

EquipmentUpgradePanel.OnDisable = function(self)
  -- function num : 0_3
end

EquipmentUpgradePanel.OnDestroy = function(self)
  -- function num : 0_4
end

EquipmentUpgradePanel.OnRelease = function(self)
  -- function num : 0_5
end

return EquipmentUpgradePanel

