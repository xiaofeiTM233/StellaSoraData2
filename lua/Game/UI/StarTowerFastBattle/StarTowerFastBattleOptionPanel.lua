local StarTowerFastBattleOptionPanel = class("StarTowerFastBattleOptionPanel", BasePanel)
StarTowerFastBattleOptionPanel._bIsMainPanel = false
StarTowerFastBattleOptionPanel._tbDefine = {
{sPrefabPath = "StarTowerFastBattle/StarTowerFastBattleOptionPanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleOptionCtrl"}
}
StarTowerFastBattleOptionPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParams = self:GetPanelParam()
  if type(tbParams) == "table" then
    self.bShop = tbParams[1]
    self.bMachine = tbParams[2]
    self.nMachineCount = tbParams[3]
    self.nCoinCount = tbParams[4]
    self.closeCallback = tbParams[5]
    self.nDiscount = tbParams[6]
    self.bFirstFree = tbParams[7]
    self.bLastFloor = tbParams[8]
  end
end

StarTowerFastBattleOptionPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerFastBattleOptionPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerFastBattleOptionPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return StarTowerFastBattleOptionPanel

