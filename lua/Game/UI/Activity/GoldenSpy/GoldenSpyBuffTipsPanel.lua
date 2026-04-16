local GoldenSpyBuffTipsPanel = class("GoldenSpyBuffTipsPanel", BasePanel)
GoldenSpyBuffTipsPanel._bIsMainPanel = false
GoldenSpyBuffTipsPanel._bAddToBackHistory = false
GoldenSpyBuffTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
GoldenSpyBuffTipsPanel._sUIResRootPath = "UI_Activity/"
GoldenSpyBuffTipsPanel._tbDefine = {
{sPrefabPath = "_400008/GoldenSpyBuffTips.prefab", sCtrlName = "Game.UI.Activity.GoldenSpy.GoldenSpyBuffTipsCtrl"}
}
GoldenSpyBuffTipsPanel.Awake = function(self)
  -- function num : 0_0
end

GoldenSpyBuffTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

GoldenSpyBuffTipsPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

GoldenSpyBuffTipsPanel.OnDisable = function(self)
  -- function num : 0_3
end

GoldenSpyBuffTipsPanel.OnDestroy = function(self)
  -- function num : 0_4
end

GoldenSpyBuffTipsPanel.OnRelease = function(self)
  -- function num : 0_5
end

return GoldenSpyBuffTipsPanel

