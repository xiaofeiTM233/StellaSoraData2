local BasePanel = require("GameCore.UI.BasePanel")
local WinterNightStoryPanel = class("WinterNightStoryPanel", BasePanel)
WinterNightStoryPanel._sUIResRootPath = "UI_Activity/"
WinterNightStoryPanel._tbDefine = {
{sPrefabPath = "10105/Story/WinterNightStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10105.Story.WinterNightStoryCtrl"}
}
WinterNightStoryPanel.Awake = function(self)
  -- function num : 0_0
end

WinterNightStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

WinterNightStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

WinterNightStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

WinterNightStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return WinterNightStoryPanel

