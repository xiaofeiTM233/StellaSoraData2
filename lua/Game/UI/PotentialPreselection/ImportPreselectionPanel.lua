local BasePanel = require("GameCore.UI.BasePanel")
local ImportPreselectionPanel = class("ImportPreselectionPanel", BasePanel)
ImportPreselectionPanel._bIsMainPanel = false
ImportPreselectionPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
ImportPreselectionPanel._tbDefine = {
{sPrefabPath = "PotentialPreselection/ImportPreselectionPanel.prefab", sCtrlName = "Game.UI.PotentialPreselection.ImportPreselectionCtrl"}
}
ImportPreselectionPanel.Awake = function(self)
  -- function num : 0_0
end

ImportPreselectionPanel.OnEnable = function(self)
  -- function num : 0_1
end

ImportPreselectionPanel.OnDisable = function(self)
  -- function num : 0_2
end

ImportPreselectionPanel.OnDestroy = function(self)
  -- function num : 0_3
end

ImportPreselectionPanel.OnRelease = function(self)
  -- function num : 0_4
end

return ImportPreselectionPanel

