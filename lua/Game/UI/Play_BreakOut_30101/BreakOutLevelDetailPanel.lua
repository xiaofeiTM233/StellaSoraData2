local BasePanel = require("GameCore.UI.BasePanel")
local BreakOutLevelDetailPanel = class("BreakOutLevelDetailPanel", BasePanel)
BreakOutLevelDetailPanel._sUIResRootPath = "UI_Activity/"
BreakOutLevelDetailPanel._tbDefine = {
{sPrefabPath = "30101/Play/BreakOutLevelDetailPanel.prefab", sCtrlName = "Game.UI.Play_BreakOut_30101.BreakOutLevelDetailCtr"}
}
BreakOutLevelDetailPanel.Awake = function(self)
  -- function num : 0_0
end

BreakOutLevelDetailPanel.OnEnable = function(self)
  -- function num : 0_1
end

BreakOutLevelDetailPanel.OnDisable = function(self)
  -- function num : 0_2
end

BreakOutLevelDetailPanel.OnDestroy = function(self)
  -- function num : 0_3
end

BreakOutLevelDetailPanel.OnRelease = function(self)
  -- function num : 0_4
end

return BreakOutLevelDetailPanel

