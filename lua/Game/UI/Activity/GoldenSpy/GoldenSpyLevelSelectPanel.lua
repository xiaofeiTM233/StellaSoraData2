local GoldenSpyLevelSelectPanel = class("GoldenSpyLevelSelectPanel", BasePanel)
GoldenSpyLevelSelectPanel._bIsMainPanel = true
GoldenSpyLevelSelectPanel._bAddToBackHistory = true
GoldenSpyLevelSelectPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
GoldenSpyLevelSelectPanel._sUIResRootPath = "UI_Activity/"
GoldenSpyLevelSelectPanel._tbDefine = {
{sPrefabPath = "_400008/GoldenSpyLevelSelectPanel.prefab", sCtrlName = "Game.UI.Activity.GoldenSpy.GoldenSpyLevelSelectCtrl"}
}
local PanelTab = {Group = 1, Level = 2}
GoldenSpyLevelSelectPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : PanelTab
  self.nPanelTab = PanelTab.Group
  self.nSelectGroupId = 0
  self.nSelectLevelId = 0
end

GoldenSpyLevelSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

GoldenSpyLevelSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

GoldenSpyLevelSelectPanel.OnDisable = function(self)
  -- function num : 0_3
end

GoldenSpyLevelSelectPanel.OnDestroy = function(self)
  -- function num : 0_4
end

GoldenSpyLevelSelectPanel.OnRelease = function(self)
  -- function num : 0_5
end

return GoldenSpyLevelSelectPanel

