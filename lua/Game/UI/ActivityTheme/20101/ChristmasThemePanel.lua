local BasePanel = require("GameCore.UI.BasePanel")
local ChristmasThemePanel = class("ChristmasThemePanel", BasePanel)
ChristmasThemePanel._sUIResRootPath = "UI_Activity/"
ChristmasThemePanel._tbDefine = {
{sPrefabPath = "20101/ChristmasThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.20101.ChristmasThemeCtrl"}
}
ChristmasThemePanel.Awake = function(self)
  -- function num : 0_0
end

ChristmasThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

ChristmasThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

ChristmasThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

ChristmasThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return ChristmasThemePanel

