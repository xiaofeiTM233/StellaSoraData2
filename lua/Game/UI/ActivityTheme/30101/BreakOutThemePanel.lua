local BasePanel = require("GameCore.UI.BasePanel")
local BreakOutThemePanel = class("BreakOutThemePanel", BasePanel)
BreakOutThemePanel._sUIResRootPath = "UI_Activity/"
BreakOutThemePanel._tbDefine = {
{sPrefabPath = "30101/BreakOutThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.30101.BreakOutThemeCtrl"}
}
BreakOutThemePanel.Awake = function(self)
  -- function num : 0_0
end

BreakOutThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

BreakOutThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

BreakOutThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

BreakOutThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return BreakOutThemePanel

