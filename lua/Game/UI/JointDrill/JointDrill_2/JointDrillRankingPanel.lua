local JointDrillRankingPanel = class("JointDrillRankingPanel", BasePanel)
JointDrillRankingPanel._sUIResRootPath = "UI_Activity/"
JointDrillRankingPanel._tbDefine = {
{sPrefabPath = "_510003/JointDrillRankingPanel.prefab", sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillRankingCtrl"}
}
JointDrillRankingPanel.Awake = function(self)
  -- function num : 0_0
  self.mapRankDetail = nil
  self.nGridPos = 0
end

JointDrillRankingPanel.OnEnable = function(self)
  -- function num : 0_1
end

JointDrillRankingPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

JointDrillRankingPanel.OnDisable = function(self)
  -- function num : 0_3
end

JointDrillRankingPanel.OnDestroy = function(self)
  -- function num : 0_4
end

JointDrillRankingPanel.OnRelease = function(self)
  -- function num : 0_5
end

return JointDrillRankingPanel

