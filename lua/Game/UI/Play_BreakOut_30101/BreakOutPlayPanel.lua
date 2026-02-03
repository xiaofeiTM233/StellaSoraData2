local BreakOutPlayPanel = class("TowerDefensePanel", BasePanel)
BreakOutPlayPanel._bIsMainPanel = true
BreakOutPlayPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
BreakOutPlayPanel._sUIResRootPath = "UI_Activity/"
BreakOutPlayPanel._tbDefine = {
{sPrefabPath = "30101/Play/BreakOutPlayPanel.prefab", sCtrlName = "Game.UI.Play_BreakOut_30101.BreakOutPlayCtrl"}
, 
{sPrefabPath = "30101/Play/BreakOutPlaySkillPanel.prefab", sCtrlName = "Game.UI.Play_BreakOut_30101.BreakOutPlaySkillCtrl"}
, 
{sPrefabPath = "30101/Play/PausePanel.prefab", sCtrlName = "Game.UI.Play_BreakOut_30101.BreakOutPauseCtrl"}
, 
{sPrefabPath = "30101/Play/BreakOutAllResultPanel.prefab", sCtrlName = "Game.UI.Play_BreakOut_30101.BreakOutResultCtrl"}
}
BreakOutPlayPanel.SetTop = function(self, goCanvas)
  -- function num : 0_0 , upvalues : _ENV
  local nTopLayer = 0
  if self.trUIRoot ~= nil then
    local nChildCount = (self.trUIRoot).childCount
    local trChild = nil
    for i = 1, nChildCount do
      trChild = (self.trUIRoot):GetChild(i - 1)
      nTopLayer = (math.max)(nTopLayer, (NovaAPI.GetCanvasSortingOrder)(trChild:GetComponent("Canvas")))
    end
  end
  do
    if nTopLayer > 0 then
      (NovaAPI.SetCanvasSortingOrder)(goCanvas, nTopLayer + 1)
    end
  end
end

BreakOutPlayPanel.Awake = function(self)
  -- function num : 0_1 , upvalues : _ENV, GamepadUIManager
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  ;
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
end

BreakOutPlayPanel.OnEnable = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local wait = function()
    -- function num : 0_2_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud, false, true)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormation)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormationDisc)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.RegionBossFormation)
  end

  ;
  (cs_coroutine.start)(wait)
end

BreakOutPlayPanel.OnAfterEnter = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, self.tbSkill)
end

BreakOutPlayPanel.OnDisable = function(self)
  -- function num : 0_4 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.DisableGamepadUI)("BreakOutPlayCtrl")
  ;
  (GamepadUIManager.QuitAdventure)()
end

BreakOutPlayPanel.OnDestroy = function(self)
  -- function num : 0_5
end

BreakOutPlayPanel.OnRelease = function(self)
  -- function num : 0_6
end

return BreakOutPlayPanel

