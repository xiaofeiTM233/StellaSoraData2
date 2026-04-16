local GoldenSpyResultPanel = class("GoldenSpyResultPanel", BasePanel)
GoldenSpyResultPanel._bIsMainPanel = true
GoldenSpyResultPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
GoldenSpyResultPanel._nSnapshotPrePanel = 1
GoldenSpyResultPanel._sUIResRootPath = "UI_Activity/"
GoldenSpyResultPanel._tbDefine = {
{sPrefabPath = "_400008/GoldenSpyResultPanel.prefab", sCtrlName = "Game.UI.Activity.GoldenSpy.GoldenSpyResultCtrl"}
}
GoldenSpyResultPanel.Awake = function(self)
  -- function num : 0_0
end

GoldenSpyResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

GoldenSpyResultPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

GoldenSpyResultPanel.OnDisable = function(self)
  -- function num : 0_3
end

GoldenSpyResultPanel.OnDestroy = function(self)
  -- function num : 0_4
end

GoldenSpyResultPanel.OnRelease = function(self)
  -- function num : 0_5
end

return GoldenSpyResultPanel

