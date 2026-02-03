local PenguinCardQuestPanel = class("PenguinCardQuestPanel", BasePanel)
PenguinCardQuestPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
PenguinCardQuestPanel._bIsMainPanel = false
PenguinCardQuestPanel._tbDefine = {
{sPrefabPath = "Play_PenguinCard/PenguinCardQuestPanel.prefab", sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardQuestCtrl"}
}
PenguinCardQuestPanel.Awake = function(self)
  -- function num : 0_0
end

PenguinCardQuestPanel.OnEnable = function(self)
  -- function num : 0_1
end

PenguinCardQuestPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

PenguinCardQuestPanel.OnDisable = function(self)
  -- function num : 0_3
end

PenguinCardQuestPanel.OnDestroy = function(self)
  -- function num : 0_4
end

PenguinCardQuestPanel.OnRelease = function(self)
  -- function num : 0_5
end

return PenguinCardQuestPanel

