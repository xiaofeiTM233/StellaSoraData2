local BasePanel = require("GameCore.UI.BasePanel")
local MiracleThemePanel = class("MiracleThemePanel", BasePanel)
MiracleThemePanel._sUIResRootPath = "UI_Activity/"
MiracleThemePanel._tbDefine = {
{sPrefabPath = "10103/MiracleThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10103.MiracleThemeCtrl"}
}
MiracleThemePanel.Awake = function(self)
  -- function num : 0_0
end

MiracleThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

MiracleThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

MiracleThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

MiracleThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return MiracleThemePanel

