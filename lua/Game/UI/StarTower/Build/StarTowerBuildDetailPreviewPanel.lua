local StarTowerBuildDetailPreviewPanel = class("StarTowerBuildDetailPreviewPanel", BasePanel)
StarTowerBuildDetailPreviewPanel._bIsMainPanel = false
StarTowerBuildDetailPreviewPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
StarTowerBuildDetailPreviewPanel._tbDefine = {
{sPrefabPath = "StarTowerBuild/StarTowerBuildDetailPanel.prefab", sCtrlName = "Game.UI.StarTower.Build.StarTowerBuildDetailCtrl"}
}
StarTowerBuildDetailPreviewPanel.Awake = function(self)
  -- function num : 0_0
end

StarTowerBuildDetailPreviewPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerBuildDetailPreviewPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerBuildDetailPreviewPanel.OnDestroy = function(self)
  -- function num : 0_3
end

StarTowerBuildDetailPreviewPanel.OnRelease = function(self)
  -- function num : 0_4
end

return StarTowerBuildDetailPreviewPanel

