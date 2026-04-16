local GoldenSpyLevelPanel = class("GoldenSpyLevelPanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
GoldenSpyLevelPanel._bIsMainPanel = true
GoldenSpyLevelPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
GoldenSpyLevelPanel._sUIResRootPath = "UI_Activity/"
GoldenSpyLevelPanel._tbDefine = {
{sPrefabPath = "_400008/GoldenSpyPanel.prefab", sCtrlName = "Game.UI.Activity.GoldenSpy.GoldenSpyLevelCtrl"}
}
GoldenSpyLevelPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (PlayerData.Base):SetSkipNewDayWindow(true)
  self.bFirstInCtrl = true
end

GoldenSpyLevelPanel.OnEnable = function(self)
  -- function num : 0_1
end

GoldenSpyLevelPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

GoldenSpyLevelPanel.OnDisable = function(self)
  -- function num : 0_3
end

GoldenSpyLevelPanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : _ENV
  (PlayerData.Base):SetSkipNewDayWindow(false)
  ;
  (PlayerData.Base):OnBackToMainMenuModule()
end

GoldenSpyLevelPanel.OnRelease = function(self)
  -- function num : 0_5
end

return GoldenSpyLevelPanel

