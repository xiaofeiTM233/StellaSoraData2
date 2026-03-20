local BasePanel = require("GameCore.UI.BasePanel")
local PostalThemePanel = class("PostalThemePanel", BasePanel)
PostalThemePanel._sUIResRootPath = "UI_Activity/"
PostalThemePanel._tbDefine = {
{sPrefabPath = "10106/PostalPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10106.PostalThemeCtrl"}
}
PostalThemePanel.Awake = function(self)
  -- function num : 0_0
end

PostalThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

PostalThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

PostalThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

PostalThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return PostalThemePanel

