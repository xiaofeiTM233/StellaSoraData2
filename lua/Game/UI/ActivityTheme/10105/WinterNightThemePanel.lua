local BasePanel = require("GameCore.UI.BasePanel")
local WinterNightThemePanel = class("WinterNightThemePanel", BasePanel)
WinterNightThemePanel._sUIResRootPath = "UI_Activity/"
WinterNightThemePanel._tbDefine = {
{sPrefabPath = "10105/WinterNightPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10105.WinterNightThemeCtrl"}
}
WinterNightThemePanel.Awake = function(self)
  -- function num : 0_0
end

WinterNightThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

WinterNightThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

WinterNightThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

WinterNightThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return WinterNightThemePanel

