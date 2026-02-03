local EquipmentRollPanel = class("EquipmentRollPanel", BasePanel)
EquipmentRollPanel._tbDefine = {
{sPrefabPath = "Equipment/EquipmentRollPanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentRollCtrl"}
}
EquipmentRollPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nCharId = tbParam[1]
    self.nSlotId = tbParam[2]
    self.nSelectGemIndex = tbParam[3]
    self.nEquipedGemIndex = tbParam[4]
    ;
    (PlayerData.Equipment):CacheEquipmentSelect(self.nSlotId, self.nSelectGemIndex)
  end
end

EquipmentRollPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentRollPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

EquipmentRollPanel.OnDisable = function(self)
  -- function num : 0_3
end

EquipmentRollPanel.OnDestroy = function(self)
  -- function num : 0_4
end

EquipmentRollPanel.OnRelease = function(self)
  -- function num : 0_5
end

return EquipmentRollPanel

