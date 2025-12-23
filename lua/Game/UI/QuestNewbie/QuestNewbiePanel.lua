local QuestNewbiePanel = class("QuestNewbiePanel", BasePanel)
QuestNewbiePanel._tbDefine = {
{sPrefabPath = "QuestNewbie/QuestNewbiePanel.prefab", sCtrlName = "Game.UI.QuestNewbie.QuestNewbieCtrl"}
}
QuestNewbiePanel.Awake = function(self)
  -- function num : 0_0
  self.nCurTab = nil
end

QuestNewbiePanel.OnEnable = function(self)
  -- function num : 0_1
end

QuestNewbiePanel.OnDisable = function(self)
  -- function num : 0_2
end

QuestNewbiePanel.OnDestroy = function(self)
  -- function num : 0_3
end

QuestNewbiePanel.OnRelease = function(self)
  -- function num : 0_4
end

return QuestNewbiePanel

