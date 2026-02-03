local PenguinCardPanel = class("PenguinCardPanel", BasePanel)
PenguinCardPanel._tbDefine = {
{sPrefabPath = "Play_PenguinCard/PenguinCardPanel.prefab", sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardCtrl"}
}
PenguinCardPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.mapLevel = tbParam[1]
  end
end

PenguinCardPanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (PlayerData.Base):SetSkipNewDayWindow(true)
end

PenguinCardPanel.OnDisable = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (PlayerData.Base):SetSkipNewDayWindow(false)
  ;
  (PlayerData.Base):OnBackToMainMenuModule()
end

PenguinCardPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return PenguinCardPanel

