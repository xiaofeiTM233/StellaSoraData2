local GachaPanel = class("GachaPanel", BasePanel)
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
GachaPanel._tbDefine = {
{sPrefabPath = "GachaEx/GachaPanel.prefab", sCtrlName = "Game.UI.GachaEx.GachaCtrl"}
}
GachaPanel.Awake = function(self)
  -- function num : 0_0
end

GachaPanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : Actor2DManager
  (Actor2DManager.ForceUseL2D)(true)
end

GachaPanel.OnDisable = function(self)
  -- function num : 0_2 , upvalues : Actor2DManager
  (Actor2DManager.ForceUseL2D)(false)
end

GachaPanel.OnDestroy = function(self)
  -- function num : 0_3
end

GachaPanel.OnRelease = function(self)
  -- function num : 0_4
end

return GachaPanel

