local PotentialPreselectionEditPanel = class("PotentialPreselectionEditPanel", BasePanel)
PotentialPreselectionEditPanel._tbDefine = {
{sPrefabPath = "PotentialPreselection/PotentialPreselectionEditPanel.prefab", sCtrlName = "Game.UI.PotentialPreselection.PotentialPreselectionEditCtrl"}
}
PotentialPreselectionEditPanel.Awake = function(self)
  -- function num : 0_0
  self.nPanelType = 0
end

PotentialPreselectionEditPanel.OnEnable = function(self)
  -- function num : 0_1
end

PotentialPreselectionEditPanel.OnDisable = function(self)
  -- function num : 0_2
end

PotentialPreselectionEditPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return PotentialPreselectionEditPanel

