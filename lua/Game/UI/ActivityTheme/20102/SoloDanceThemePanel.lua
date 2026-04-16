local BasePanel = require("GameCore.UI.BasePanel")
local SolodanceThemePanel = class("SolodanceThemePanel", BasePanel)
SolodanceThemePanel._sUIResRootPath = "UI_Activity/"
SolodanceThemePanel._tbDefine = {
{sPrefabPath = "20102/SolodanceThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.20102.SolodanceThemeCtrl"}
}
SolodanceThemePanel.Awake = function(self)
  -- function num : 0_0
end

SolodanceThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

SolodanceThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

SolodanceThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

SolodanceThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return SolodanceThemePanel

