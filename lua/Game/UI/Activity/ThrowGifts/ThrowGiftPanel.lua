local ThrowGiftPanel = class("ThrowGiftPanel", BasePanel)
ThrowGiftPanel._sUIResRootPath = "UI_Activity/"
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
ThrowGiftPanel._tbDefine = {
{sPrefabPath = "_400005/ThrowGiftsPanel.prefab", sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftCtrl"}
}
ThrowGiftPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager
  (GamepadUIManager.EnterAdventure)(true)
  ;
  (GamepadUIManager.EnableGamepadUI)("ThrowGiftPanel", {}, nil, true)
end

ThrowGiftPanel.OnEnable = function(self)
  -- function num : 0_1
end

ThrowGiftPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

ThrowGiftPanel.OnDisable = function(self)
  -- function num : 0_3
end

ThrowGiftPanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("ThrowGiftPanel")
  ;
  (GamepadUIManager.QuitAdventure)()
end

ThrowGiftPanel.OnRelease = function(self)
  -- function num : 0_5
end

return ThrowGiftPanel

