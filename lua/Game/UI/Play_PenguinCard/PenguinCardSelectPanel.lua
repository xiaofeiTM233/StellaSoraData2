local PenguinCardSelectPanel = class("PenguinCardSelectPanel", BasePanel)
PenguinCardSelectPanel._bIsMainPanel = true
PenguinCardSelectPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
PenguinCardSelectPanel._tbDefine = {
{sPrefabPath = "Play_PenguinCard/PenguinCardSelectPanel.prefab", sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardSelectCtrl"}
}
PenguinCardSelectPanel.Awake = function(self)
  -- function num : 0_0
  self.nPos = nil
end

PenguinCardSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

PenguinCardSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

PenguinCardSelectPanel.OnDisable = function(self)
  -- function num : 0_3
end

PenguinCardSelectPanel.OnDestroy = function(self)
  -- function num : 0_4
end

PenguinCardSelectPanel.OnRelease = function(self)
  -- function num : 0_5
end

return PenguinCardSelectPanel

