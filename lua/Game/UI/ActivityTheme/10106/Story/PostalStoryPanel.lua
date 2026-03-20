local BasePanel = require("GameCore.UI.BasePanel")
local PostalStoryPanel = class("PostalStoryPanel", BasePanel)
PostalStoryPanel._sUIResRootPath = "UI_Activity/"
PostalStoryPanel._tbDefine = {
{sPrefabPath = "10106/Story/PostalStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10106.Story.PostalStoryCtrl"}
}
PostalStoryPanel.Awake = function(self)
  -- function num : 0_0
end

PostalStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

PostalStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

PostalStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

PostalStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return PostalStoryPanel

