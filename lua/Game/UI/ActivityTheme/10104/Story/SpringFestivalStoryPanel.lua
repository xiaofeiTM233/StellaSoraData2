local BasePanel = require("GameCore.UI.BasePanel")
local SpringFestivalStoryPanel = class("SpringFestivalStoryPanel", BasePanel)
SpringFestivalStoryPanel._sUIResRootPath = "UI_Activity/"
SpringFestivalStoryPanel._tbDefine = {
{sPrefabPath = "10104/Story/SpringThemeStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10104.Story.SpringFestivalStoryCtrl"}
}
SpringFestivalStoryPanel.Awake = function(self)
  -- function num : 0_0
end

SpringFestivalStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

SpringFestivalStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

SpringFestivalStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

SpringFestivalStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return SpringFestivalStoryPanel

