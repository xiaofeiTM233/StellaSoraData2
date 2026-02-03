local BasePanel = require("GameCore.UI.BasePanel")
local SpringFestivalThemePanel = class("SpringFestivalThemePanel", BasePanel)
SpringFestivalThemePanel._sUIResRootPath = "UI_Activity/"
SpringFestivalThemePanel._tbDefine = {
{sPrefabPath = "10104/SpringThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10104.SpringFestivalThemeCtrl"}
}
SpringFestivalThemePanel.Awake = function(self)
  -- function num : 0_0
end

SpringFestivalThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

SpringFestivalThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

SpringFestivalThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

SpringFestivalThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return SpringFestivalThemePanel

