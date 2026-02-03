local TrialDepotPanel = class("TrialDepotPanel", BasePanel)
TrialDepotPanel._bIsMainPanel = false
TrialDepotPanel._tbDefine = {
{sPrefabPath = "Play_TrialBattle/TrialDepotPanel.prefab", sCtrlName = "Game.UI.TrialBattle.TrialDepotCtrl"}
}
TrialDepotPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbTeam = (self._tbParam)[1]
  self.tbDisc = (self._tbParam)[2]
  self.mapCharData = (self._tbParam)[3]
  self.mapDiscData = (self._tbParam)[4]
  self.mapPotentialAddLevel = (self._tbParam)[5]
  self.mapPotential = (self._tbParam)[6]
  self.mapNote = (self._tbParam)[7]
  self.bBattle = (self._tbParam)[8]
  self.mapNoteNeed = {}
  for nIndex,nDiscId in ipairs(self.tbDisc) do
    if nIndex <= 3 then
      local mapDiscData = (self.mapDiscData)[nDiscId]
      if mapDiscData ~= nil then
        local tbNeedNote = mapDiscData.tbSkillNeedNote
        for _,mapNeedNote in ipairs(tbNeedNote) do
          -- DECOMPILER ERROR at PC48: Confused about usage of register: R13 in 'UnsetPending'

          if (self.mapNoteNeed)[mapNeedNote.nId] == nil then
            (self.mapNoteNeed)[mapNeedNote.nId] = 0
          end
          -- DECOMPILER ERROR at PC56: Confused about usage of register: R13 in 'UnsetPending'

          ;
          (self.mapNoteNeed)[mapNeedNote.nId] = (self.mapNoteNeed)[mapNeedNote.nId] + mapNeedNote.nCount
        end
      end
      do
        -- DECOMPILER ERROR at PC59: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC59: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
end

TrialDepotPanel.OnEnable = function(self)
  -- function num : 0_1
end

TrialDepotPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TrialDepotPanel.OnDisable = function(self)
  -- function num : 0_3
end

TrialDepotPanel.GetSkillLevel = function(self, nCharId)
  -- function num : 0_4 , upvalues : _ENV
  local mapChar = (self.mapCharData)[nCharId]
  local tbList = {}
  tbList[(GameEnum.skillSlotType).NORMAL] = mapChar and (mapChar.tbSkillLvs)[1] or 1
  tbList[(GameEnum.skillSlotType).B] = mapChar and (mapChar.tbSkillLvs)[2] or 1
  tbList[(GameEnum.skillSlotType).C] = mapChar and (mapChar.tbSkillLvs)[3] or 1
  tbList[(GameEnum.skillSlotType).D] = mapChar and (mapChar.tbSkillLvs)[4] or 1
  return tbList
end

return TrialDepotPanel

