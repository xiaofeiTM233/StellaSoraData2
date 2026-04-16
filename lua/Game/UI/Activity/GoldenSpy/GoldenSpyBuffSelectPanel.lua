local GoldenSpyBuffSelectPanel = class("GoldenSpyBuffSelectPanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
GoldenSpyBuffSelectPanel._bIsMainPanel = false
GoldenSpyBuffSelectPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
GoldenSpyBuffSelectPanel._sUIResRootPath = "UI_Activity/"
GoldenSpyBuffSelectPanel._tbDefine = {
{sPrefabPath = "_400008/GoldenSpyBuffSelectPanel.prefab", sCtrlName = "Game.UI.Activity.GoldenSpy.GoldenSpyBuffSelectCtrl"}
}
GoldenSpyBuffSelectPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager
  (GamepadUIManager.EnableGamepadUI)("GoldenSpyBuffSelect", {})
end

GoldenSpyBuffSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

GoldenSpyBuffSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

GoldenSpyBuffSelectPanel.OnDisable = function(self)
  -- function num : 0_3
end

GoldenSpyBuffSelectPanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("GoldenSpyBuffSelect")
end

GoldenSpyBuffSelectPanel.OnRelease = function(self)
  -- function num : 0_5
end

return GoldenSpyBuffSelectPanel

