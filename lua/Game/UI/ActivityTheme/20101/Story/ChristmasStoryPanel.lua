local BasePanel = require("GameCore.UI.BasePanel")
local ChristmasStoryPanel = class("ChristmasStoryPanel", BasePanel)
ChristmasStoryPanel._sUIResRootPath = "UI_Activity/"
ChristmasStoryPanel._tbDefine = {
{sPrefabPath = "20101/Story/ChristmasStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.20101.Story.ChristmasStoryCtrl"}
}
ChristmasStoryPanel.Awake = function(self)
  -- function num : 0_0
end

ChristmasStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

ChristmasStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

ChristmasStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

ChristmasStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return ChristmasStoryPanel

