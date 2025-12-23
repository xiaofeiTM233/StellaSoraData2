local ReceivePropsNPCPanel = class("ReceivePropsNPCPanel", BasePanel)
ReceivePropsNPCPanel._bIsMainPanel = false
ReceivePropsNPCPanel._tbDefine = {
{sPrefabPath = "ReceivePropsEx/ReceivePropsNPCPanel.prefab", sCtrlName = "Game.UI.ReceivePropsEx.ReceivePropsNPCCtrl"}
}
ReceivePropsNPCPanel.Awake = function(self)
  -- function num : 0_0
end

ReceivePropsNPCPanel.OnEnable = function(self)
  -- function num : 0_1
end

ReceivePropsNPCPanel.OnDisable = function(self)
  -- function num : 0_2
end

ReceivePropsNPCPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ReceivePropsNPCPanel

