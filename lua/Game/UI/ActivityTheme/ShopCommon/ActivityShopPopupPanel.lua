local ActivityShopPopupPanel = class("ActivityShopPopupPanel", BasePanel)
ActivityShopPopupPanel._bIsMainPanel = false
ActivityShopPopupPanel._tbDefine = {
{sPrefabPath = "ShopPopup/ActivityShopPopupPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.ShopCommon.ActivityShopPopupCtrl"}
}
ActivityShopPopupPanel.Awake = function(self)
  -- function num : 0_0
end

ActivityShopPopupPanel.OnEnable = function(self)
  -- function num : 0_1
end

ActivityShopPopupPanel.OnDisable = function(self)
  -- function num : 0_2
end

ActivityShopPopupPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ActivityShopPopupPanel

