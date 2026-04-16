local PenguinLevel = class("PenguinLevel")
local PenguinCard = require("Game.UI.Play_PenguinCard.PenguinCard")
local PenguinCardBuff = require("Game.UI.Play_PenguinCard.PenguinCardBuff")
local PenguinCardQuest = require("Game.UI.Play_PenguinCard.PenguinCardQuest")
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local ConfigData = require("GameCore.Data.ConfigData")
local PenguinCardUtils = require("Game.UI.Play_PenguinCard.PenguinCardUtils")
PenguinLevel.Init = function(self, nFloorId, nLevelId, nActId, tbStarScore)
  -- function num : 0_0 , upvalues : _ENV
  self.nFloorId = nFloorId
  if not tbStarScore then
    self.tbStarScore = {0, 0, 0}
    self.nLevelId = nLevelId
    self.nActId = nActId
    self.bWarning = true
    self:ParseConfigData()
    self:ParseLocalData()
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.PenguinCard, self)
  end
end

PenguinLevel.ParseConfigData = function(self)
  -- function num : 0_1 , upvalues : _ENV, ConfigData
  self.nBaseCardCount = (ConfigTable.GetConfigNumber)("PenguinCardHandCardCount")
  self.nMaxRound = (ConfigTable.GetConfigNumber)("PenguinCardMaxRound")
  self.nMaxSlot = (ConfigTable.GetConfigNumber)("PenguinCardMaxSlot")
  self.nMaxBuyLimit = (ConfigTable.GetConfigNumber)("PenguinCardHandCardCount")
  self.tbRoundUpgradeCost = (ConfigTable.GetConfigNumberArray)("PenguinCardRoundUpgradeCost")
  self.tbSlotUpgradeCost = (ConfigTable.GetConfigNumberArray)("PenguinCardSlotUpgradeCost")
  self.tbBuyLimitUpgradeCost = (ConfigTable.GetConfigNumberArray)("PenguinCardBuyLimitUpgradeCost")
  self.nFireScore = (ConfigTable.GetConfigNumber)("PenguinCardFeverScore")
  self.mapBuyCost = {}
  local func_ForEach_Line = function(mapData)
    -- function num : 0_1_0 , upvalues : self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    (self.mapBuyCost)[mapData.Count] = {Turn = mapData.Turn, Cost = mapData.Cost}
  end

  ForEachTableLine(DataTable.PenguinCardCost, func_ForEach_Line)
  self.mapHandRankRule = {}
  local func_ForEach_Rank = function(mapData)
    -- function num : 0_1_1 , upvalues : self, ConfigData
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

    (self.mapHandRankRule)[mapData.Order] = {Id = mapData.Id, SuitCount = mapData.SuitCount, Value = mapData.Value, Ratio = mapData.Ratio * ConfigData.IntFloatPrecision}
  end

  ForEachTableLine(DataTable.PenguinCardHandRank, func_ForEach_Rank)
end

PenguinLevel.ParseLocalData = function(self)
  -- function num : 0_2 , upvalues : LocalData
  local bAuto = (LocalData.GetPlayerLocalData)("PenguinCardAuto")
  self.bAuto = bAuto == true
  local nSpeed = (LocalData.GetPlayerLocalData)("PenguinCardSpeed")
  self.nSpeed = nSpeed or 1
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PenguinLevel.ParseLevelData = function(self, nFloorId)
  -- function num : 0_3 , upvalues : _ENV
  local mapLevelCfg = (ConfigTable.GetData)("PenguinCardFloor", nFloorId)
  if not mapLevelCfg then
    return 
  end
  self.nMaxTurn = mapLevelCfg.MaxTurn
  self.nScore = mapLevelCfg.InitialScore
  self.nTotalScore = mapLevelCfg.InitialScore
  self.nSlotCount = mapLevelCfg.InitialSlot
  self.nRoundLimit = mapLevelCfg.InitialRound
  self.nFixedTurnGroupId = mapLevelCfg.FixedTurn
  self.sLevelDesc = mapLevelCfg.Floortips
  self.bShowWin = mapLevelCfg.ShowWin
  self.nQuestTurn = mapLevelCfg.QuestTurn
  self.nQuestGroup = mapLevelCfg.QuestGroup
  self.nBuyLimit = mapLevelCfg.InitialBuyLimit
  self.nWeightGroupId = mapLevelCfg.WeightGroup
  local mapPoolCfg = (ConfigTable.GetData)("PenguinBaseCardPool", mapLevelCfg.PoolId)
  if not mapPoolCfg then
    return 
  end
  self.mapBaseCardPool = {tbId = mapPoolCfg.BaseCardId, tbWeight = mapPoolCfg.Weight}
end

PenguinLevel.ClearLevelData = function(self)
  -- function num : 0_4 , upvalues : _ENV
  self.nGameState = nil
  self.nCurTurn = 0
  self.nCurRound = 0
  self.nHp = 3
  if self.tbBuffPool == nil then
    self.tbBuffPool = {}
  end
  if self.tbBuff == nil then
    self.tbBuff = {}
  else
    if next(self.tbBuff) ~= nil then
      local nCount = #self.tbBuff
      for i = nCount, 1, -1 do
        self:RecycleBuff((self.tbBuff)[i])
        ;
        (table.remove)(self.tbBuff, i)
      end
    end
  end
  do
    if self.tbPenguinCardPool == nil then
      self.tbPenguinCardPool = {}
    end
    if self.tbPenguinCard == nil then
      self.tbPenguinCard = {}
      for i = 1, 6 do
        -- DECOMPILER ERROR at PC51: Confused about usage of register: R5 in 'UnsetPending'

        (self.tbPenguinCard)[i] = 0
      end
    else
      do
        if next(self.tbPenguinCard) ~= nil then
          for i = 1, 6 do
            local mapCard = (self.tbPenguinCard)[i]
            if mapCard ~= 0 then
              self:RecyclePenguinCard(mapCard)
              -- DECOMPILER ERROR at PC71: Confused about usage of register: R6 in 'UnsetPending'

              ;
              (self.tbPenguinCard)[i] = 0
            end
          end
        end
        do
          if self.tbQuestPool == nil then
            self.tbQuestPool = {}
          end
          self.mapQuest = nil
          self.mapLog = {}
          self.nTotalRound = 0
          self.nBestTurnScore = 0
          self.nBestRoundScore = 0
          self.mapHandRankHistory = {}
          self.mapSuitHistory = {}
          self.nGetPenguinCardCount = 0
        end
      end
    end
  end
end

PenguinLevel.StartGame = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (math.randomseed)((os.time)())
  self:ClearLevelData()
  self:ParseLevelData(self.nFloorId)
  self:SwitchGameState()
end

PenguinLevel.CompleteGame = function(self)
  -- function num : 0_6 , upvalues : PenguinCardUtils
  local nNextState = (PenguinCardUtils.GameState).Complete
  self:SwitchNextGameState(nNextState, {bManual = true})
end

PenguinLevel.RestartGame = function(self)
  -- function num : 0_7 , upvalues : PenguinCardUtils, TimerManager, _ENV
  local nNextState = (PenguinCardUtils.GameState).Start
  local nWaitTime = self:QuitGameState(nNextState)
  if nWaitTime == 0 then
    self:StartGame()
  else
    ;
    (TimerManager.Add)(1, nWaitTime, self, function()
    -- function num : 0_7_0 , upvalues : self
    self:StartGame()
  end
, true, true, true)
    ;
    (EventManager.Hit)(EventId.TemporaryBlockInput, nWaitTime)
  end
end

PenguinLevel.QuitGame = function(self, callback)
  -- function num : 0_8 , upvalues : _ENV
  local bAct = false
  if self.nActId then
    local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
    if actData then
      local bOpen = actData:CheckActivityOpen()
      if bOpen then
        bAct = true
        local nScore = (math.floor)(self.nScore + 0.5 + 1e-09)
        actData:SendActivityPenguinCardSettleReq(self.nLevelId, self.nStar, nScore, callback)
      else
        do
          do
            ;
            (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Activity_Invalid_Tip_3")})
            if not bAct then
              callback(true)
            end
            self:QuitGameState()
            self:ClearLevelData()
          end
        end
      end
    end
  end
end

PenguinLevel.SwitchGameState = function(self)
  -- function num : 0_9
  local nNextState = self:CheckNextGameState()
  self:SwitchNextGameState(nNextState)
end

PenguinLevel.RunGameState = function(self, mapParam)
  -- function num : 0_10 , upvalues : PenguinCardUtils
  if self.nGameState == (PenguinCardUtils.GameState).Start then
    self:RunState_Start()
  else
    if self.nGameState == (PenguinCardUtils.GameState).Prepare then
      self:RunState_Prepare()
    else
      if self.nGameState == (PenguinCardUtils.GameState).Dealing then
        self:RunState_Dealing()
      else
        if self.nGameState == (PenguinCardUtils.GameState).Flip then
          self:RunState_Flip()
        else
          if self.nGameState == (PenguinCardUtils.GameState).Settlement then
            self:RunState_Settlement()
          else
            if self.nGameState == (PenguinCardUtils.GameState).Complete then
              self:RunState_Complete(mapParam)
            else
              if self.nGameState == (PenguinCardUtils.GameState).Quest then
                self:RunState_Quest()
              end
            end
          end
        end
      end
    end
  end
end

PenguinLevel.QuitGameState = function(self, nNextState)
  -- function num : 0_11 , upvalues : PenguinCardUtils
  local nWaitTime = 0
  if self.nGameState == (PenguinCardUtils.GameState).Start then
    nWaitTime = self:QuitState_Start()
  else
    if self.nGameState == (PenguinCardUtils.GameState).Prepare then
      nWaitTime = self:QuitState_Prepare(nNextState)
    else
      if self.nGameState == (PenguinCardUtils.GameState).Dealing then
        nWaitTime = self:QuitState_Dealing(nNextState)
      else
        if self.nGameState == (PenguinCardUtils.GameState).Flip then
          nWaitTime = self:QuitState_Flip(nNextState)
        else
          if self.nGameState == (PenguinCardUtils.GameState).Settlement then
            nWaitTime = self:QuitState_Settlement(nNextState)
          else
            if self.nGameState == (PenguinCardUtils.GameState).Complete then
              nWaitTime = self:QuitState_Complete()
            else
              if self.nGameState == (PenguinCardUtils.GameState).Quest then
                nWaitTime = self:QuitState_Quest(nNextState)
              end
            end
          end
        end
      end
    end
  end
  return nWaitTime
end

PenguinLevel.CheckNextGameState = function(self)
  -- function num : 0_12 , upvalues : PenguinCardUtils
  if self.nGameState == nil then
    return (PenguinCardUtils.GameState).Start
  else
    if self.nGameState == (PenguinCardUtils.GameState).Start then
      if self.nQuestTurn >= 0 and self.nQuestTurn <= self.nCurTurn then
        return (PenguinCardUtils.GameState).Quest
      else
        return (PenguinCardUtils.GameState).Prepare
      end
    else
      if self.nGameState == (PenguinCardUtils.GameState).Prepare then
        return (PenguinCardUtils.GameState).Dealing
      else
        if self.nGameState == (PenguinCardUtils.GameState).Dealing then
          return (PenguinCardUtils.GameState).Flip
        else
          if self.nGameState == (PenguinCardUtils.GameState).Flip then
            return (PenguinCardUtils.GameState).Settlement
          else
            if self.nGameState == (PenguinCardUtils.GameState).Settlement then
              if self.nCurRound < self:GetRoundLimitInTurn() then
                return (PenguinCardUtils.GameState).Dealing
              end
              if self.nMaxTurn <= self.nCurTurn then
                return (PenguinCardUtils.GameState).Complete
              end
              if self.mapQuest ~= nil then
                return (PenguinCardUtils.GameState).Quest
              else
                if self.nQuestTurn >= 0 and self.nQuestTurn <= self.nCurTurn then
                  return (PenguinCardUtils.GameState).Quest
                else
                  return (PenguinCardUtils.GameState).Prepare
                end
              end
            else
              if self.nGameState == (PenguinCardUtils.GameState).Quest then
                if self.nMaxTurn <= self.nCurTurn or self.nHp <= 0 then
                  return (PenguinCardUtils.GameState).Complete
                else
                  return (PenguinCardUtils.GameState).Prepare
                end
              end
            end
          end
        end
      end
    end
  end
end

PenguinLevel.SwitchNextGameState = function(self, nNextState, mapParam)
  -- function num : 0_13 , upvalues : TimerManager, _ENV
  local nWaitTime = self:QuitGameState(nNextState)
  if nWaitTime == 0 then
    self.nGameState = nNextState
    self:RunGameState(mapParam)
  else
    ;
    (TimerManager.Add)(1, nWaitTime, self, function()
    -- function num : 0_13_0 , upvalues : self, nNextState, mapParam
    self.nGameState = nNextState
    self:RunGameState(mapParam)
  end
, true, true, true)
    ;
    (EventManager.Hit)(EventId.TemporaryBlockInput, nWaitTime)
  end
end

PenguinLevel.RunState_Start = function(self)
  -- function num : 0_14 , upvalues : _ENV
  (EventManager.Hit)("PenguinCard_RunState_Start")
end

PenguinLevel.QuitState_Start = function(self)
  -- function num : 0_15 , upvalues : _ENV
  (EventManager.Hit)("PenguinCard_QuitState_Start")
  local nWaitTime = 0.167
  return nWaitTime
end

PenguinLevel.RunState_Quest = function(self)
  -- function num : 0_16 , upvalues : _ENV
  self.tbSelectableQuest = {}
  self.bSkipQuestShow = false
  self.mapQuestForShow = nil
  if self.mapQuest ~= nil then
    self.mapQuestForShow = clone(self.mapQuest)
    local bComplete = (self.mapQuest):CheckComplete()
    if bComplete then
      self:CompleteQuest()
      self:RollQuest()
    else
      local bExpired = (self.mapQuest):CheckExpired()
      if bExpired then
        self:ChangeHp(-1)
        if self.nHp > 0 then
          self:RollQuest()
        end
      else
        self.bSkipQuestShow = true
      end
    end
  else
    do
      self:RollQuest()
      if next(self.tbSelectableQuest) == nil then
        self.bSkipQuestShow = true
      end
      ;
      (EventManager.Hit)("PenguinCard_RunState_Quest", self.bSkipQuestShow)
      if self.bSkipQuestShow then
        self:SwitchGameState()
      end
    end
  end
end

PenguinLevel.QuitState_Quest = function(self, nNextState)
  -- function num : 0_17 , upvalues : _ENV, PenguinCardUtils
  self.tbSelectableQuest = {}
  self.bSkipQuestShow = false
  self.mapQuestForShow = nil
  ;
  (EventManager.Hit)("PenguinCard_QuitState_Quest", nNextState)
  local nWaitTime = 0
  if nNextState == (PenguinCardUtils.GameState).Start then
    nWaitTime = 0.6
  else
    if nNextState == (PenguinCardUtils.GameState).Prepare then
      nWaitTime = 0.57
    else
      if nNextState == (PenguinCardUtils.GameState).Complete then
        nWaitTime = 0.6
      end
    end
  end
  return nWaitTime
end

PenguinLevel.RollQuest = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local tbId = self:GetRollQuestResult()
  self:ClearSelectableQuest()
  for _,nId in ipairs(tbId) do
    local mapCard = self:CreateQuest(nId)
    ;
    (table.insert)(self.tbSelectableQuest, mapCard)
  end
  self.mapQuest = nil
end

PenguinLevel.GetRollQuestResult = function(self)
  -- function num : 0_19 , upvalues : _ENV, PenguinCardUtils
  local mapWeightCfg = (ConfigTable.GetData)("PenguinCardQuestWeight", self.nQuestGroup * 100 + self.nCurTurn)
  if not mapWeightCfg then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_Error_EmptyQuest")})
    return {}
  end
  local tbId = (PenguinCardUtils.WeightedRandom)(mapWeightCfg.QuestList, mapWeightCfg.Weight, 3)
  return tbId
end

PenguinLevel.ClearSelectableQuest = function(self)
  -- function num : 0_20 , upvalues : _ENV
  if next(self.tbSelectableQuest) ~= nil then
    for i = #self.tbSelectableQuest, 1, -1 do
      local mapCard = (table.remove)(self.tbSelectableQuest, i)
      self:RecycleQuest(mapCard)
    end
  end
end

PenguinLevel.SelectQuest = function(self, nIndex)
  -- function num : 0_21 , upvalues : _ENV
  self.mapQuest = nil
  self.mapQuest = (self.tbSelectableQuest)[nIndex]
  ;
  (table.remove)(self.tbSelectableQuest, nIndex)
  self:ClearSelectableQuest()
  ;
  (EventManager.Hit)("PenguinCard_SelectQuest")
  if (NovaAPI.IsEditorPlatform)() then
    printLog("领取任务：" .. "  " .. (self.mapQuest).nId)
  end
end

PenguinLevel.CompleteQuest = function(self)
  -- function num : 0_22
  local mapData = self:CreateBuff((self.mapQuest).nBuffId)
  mapData:ResetAllTrigger()
  self:AddBuff(mapData, true)
end

PenguinLevel.ChangeHp = function(self, nChange)
  -- function num : 0_23 , upvalues : _ENV
  self.nHp = self.nHp + nChange
  if (NovaAPI.IsEditorPlatform)() then
    printLog("Hp变化：" .. "  " .. nChange .. "  当前：" .. self.nHp)
  end
  ;
  (EventManager.Hit)("PenguinCard_ChangeHp", nChange)
  if self.nHp <= 0 then
    self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).FatalDamage, {nHpChange = nChange})
  end
end

PenguinLevel.AddBuff = function(self, mapBuff, bWaitShow)
  -- function num : 0_24 , upvalues : _ENV
  if mapBuff.bOnly then
    local nBuffCount = #self.tbBuff
    for i = nBuffCount, 1, -1 do
      if mapBuff.nId == ((self.tbBuff)[i]).nId then
        self:DeleteBuff(i)
      end
    end
    ;
    (table.insert)(self.tbBuff, mapBuff)
    ;
    (EventManager.Hit)("PenguinCard_AddBuff", mapBuff, bWaitShow)
  else
    do
      local nHasKey = 0
      for k,v in pairs(self.tbBuff) do
        if v.nId == mapBuff.nId then
          nHasKey = k
          break
        end
      end
      do
        do
          if nHasKey > 0 then
            ((self.tbBuff)[nHasKey]):AddGrowthLayer()
          else
            ;
            (table.insert)(self.tbBuff, mapBuff)
            ;
            (EventManager.Hit)("PenguinCard_AddBuff", mapBuff, bWaitShow)
          end
          if (NovaAPI.IsEditorPlatform)() then
            printLog("获得buff：" .. "  " .. mapBuff.nId)
          end
        end
      end
    end
  end
end

PenguinLevel.DeleteBuff = function(self, i, nDelayTime)
  -- function num : 0_25 , upvalues : _ENV
  self:RecycleBuff((self.tbBuff)[i])
  ;
  (table.remove)(self.tbBuff, i)
  ;
  (EventManager.Hit)("PenguinCard_DeleteBuff", i, nDelayTime)
end

PenguinLevel.RecycleBuff = function(self, mapBuff)
  -- function num : 0_26 , upvalues : _ENV
  mapBuff:Clear()
  ;
  (table.insert)(self.tbBuffPool, mapBuff)
end

PenguinLevel.CreateBuff = function(self, nId)
  -- function num : 0_27 , upvalues : _ENV, PenguinCardBuff
  local mapBuff = nil
  if next(self.tbBuffPool) == nil then
    mapBuff = (PenguinCardBuff.new)(nId)
  else
    mapBuff = (table.remove)(self.tbBuffPool, 1)
    mapBuff:Init(nId)
  end
  return mapBuff
end

PenguinLevel.RecycleQuest = function(self, mapQuest)
  -- function num : 0_28 , upvalues : _ENV
  mapQuest:Clear()
  ;
  (table.insert)(self.tbQuestPool, mapQuest)
end

PenguinLevel.CreateQuest = function(self, nId)
  -- function num : 0_29 , upvalues : _ENV, PenguinCardQuest
  local mapQuest = nil
  if next(self.tbQuestPool) == nil then
    mapQuest = (PenguinCardQuest.new)(nId)
  else
    mapQuest = (table.remove)(self.tbQuestPool, 1)
    mapQuest:Init(nId)
  end
  return mapQuest
end

PenguinLevel.RunState_Prepare = function(self)
  -- function num : 0_30 , upvalues : _ENV
  self.nCurTurn = self.nCurTurn + 1
  self.nCurRound = 0
  self.nTurnBuyCount = 0
  self.nTurnScore = 0
  self.tbHandRankCount = {}
  self.tbSelectablePenguinCard = {}
  self.bSelectedPenguinCard = false
  self.nUpgradeDiscount = 1
  self.nTempAddRound = 0
  for _,v in ipairs(self.tbBuff) do
    v:ResetTurnTrigger()
  end
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 then
      v:ResetTurnTrigger()
    end
  end
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).Prepare)
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).BeforeUpgrade)
  self:FreeRollPenguinCard()
  ;
  (EventManager.Hit)("PenguinCard_RunState_Prepare")
end

PenguinLevel.QuitState_Prepare = function(self, nNextState)
  -- function num : 0_31 , upvalues : _ENV, PenguinCardUtils
  self:ClearSelectablePenguinCard()
  self.nTurnBuyCount = 0
  self.tbSelectablePenguinCard = {}
  self.bSelectedPenguinCard = false
  self.bPreTurnWin = false
  ;
  (EventManager.Hit)("PenguinCard_QuitState_Prepare", nNextState)
  local nWaitTime = 0
  if nNextState == (PenguinCardUtils.GameState).Start then
    nWaitTime = 0.6
  else
    if nNextState == (PenguinCardUtils.GameState).Dealing then
      nWaitTime = 0.45
    else
      if nNextState == (PenguinCardUtils.GameState).Complete then
        nWaitTime = 0.6
      end
    end
  end
  return nWaitTime
end

PenguinLevel.GetRoundLimitInTurn = function(self)
  -- function num : 0_32
  return self.nRoundLimit + self.nTempAddRound
end

PenguinLevel.AddRound = function(self)
  -- function num : 0_33 , upvalues : _ENV
  if self.nRoundLimit == self.nMaxRound then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_AddBtnMaxLevel")})
    return 
  end
  local nCost = (self.tbRoundUpgradeCost)[self.nRoundLimit + 1] * self.nUpgradeDiscount
  if self.nScore < nCost then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_NotEnoughScoreUpgrade")})
    return 
  end
  self.nRoundLimit = self.nRoundLimit + 1
  self:ChangeScore(-1 * nCost)
  ;
  (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_buy", sContent = orderedFormat((ConfigTable.GetUIText)("PenguinCard_AddRoundSuccess"), self.nRoundLimit)})
  self:AfterUpgrade(nCost)
  ;
  (EventManager.Hit)("PenguinCard_AddRound")
end

PenguinLevel.AddSlot = function(self)
  -- function num : 0_34 , upvalues : _ENV
  if self.nSlotCount == self.nMaxSlot then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_AddBtnMaxLevel")})
    return 
  end
  local nCost = (self.tbSlotUpgradeCost)[self.nSlotCount + 1] * self.nUpgradeDiscount
  if self.nScore < nCost then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_NotEnoughScoreUpgrade")})
    return 
  end
  self.nSlotCount = self.nSlotCount + 1
  self:ChangeScore(-1 * nCost)
  ;
  (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_buy", sContent = orderedFormat((ConfigTable.GetUIText)("PenguinCard_AddSlotSuccess"), self.nSlotCount)})
  self:AfterUpgrade(nCost)
  ;
  (EventManager.Hit)("PenguinCard_AddSlot")
end

PenguinLevel.AddRoll = function(self)
  -- function num : 0_35 , upvalues : _ENV
  if self.nBuyLimit == self.nMaxBuyLimit then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_AddBtnMaxLevel")})
    return 
  end
  local nCost = (self.tbBuyLimitUpgradeCost)[self.nBuyLimit + 1] * self.nUpgradeDiscount
  if self.nScore < nCost then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_NotEnoughScoreUpgrade")})
    return 
  end
  self.nBuyLimit = self.nBuyLimit + 1
  self:ChangeScore(-1 * nCost)
  ;
  (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_buy", sContent = orderedFormat((ConfigTable.GetUIText)("PenguinCard_AddRollSuccess"), self.nBuyLimit)})
  self:AfterUpgrade(nCost)
  ;
  (EventManager.Hit)("PenguinCard_AddRoll")
end

PenguinLevel.AfterUpgrade = function(self, nUpgradeCost)
  -- function num : 0_36 , upvalues : _ENV
  self.nUpgradeDiscount = 1
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).AfterUpgrade, {nUpgradeCost = nUpgradeCost})
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).BeforeUpgrade)
end

PenguinLevel.FreeRollPenguinCard = function(self)
  -- function num : 0_37 , upvalues : _ENV
  local tbId = self:GetRollPenguinCardResult()
  if next(tbId) == nil then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_Error_EmptyPenguinCard")})
    return 
  end
  self:ClearSelectablePenguinCard()
  for _,nId in ipairs(tbId) do
    local mapCard = self:CreatePenguinCard(nId)
    ;
    (table.insert)(self.tbSelectablePenguinCard, mapCard)
  end
  self.bSelectedPenguinCard = false
end

PenguinLevel.RollPenguinCard = function(self)
  -- function num : 0_38 , upvalues : _ENV
  if self.nBuyLimit <= self.nTurnBuyCount then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_RollMax")})
    return 
  end
  local nCost = self:GetRollPenguinCardCost()
  if self.nScore < nCost then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_NotEnoughScoreRoll")})
    return 
  end
  local tbId = self:GetRollPenguinCardResult()
  if next(tbId) == nil then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = "Mode_Card_refresh_falied", sContent = (ConfigTable.GetUIText)("PenguinCard_Error_EmptyPenguinCard")})
    return 
  end
  self.nTurnBuyCount = self.nTurnBuyCount + 1
  self:ChangeScore(-1 * nCost)
  self:ClearSelectablePenguinCard()
  for _,nId in ipairs(tbId) do
    local mapCard = self:CreatePenguinCard(nId)
    ;
    (table.insert)(self.tbSelectablePenguinCard, mapCard)
  end
  self.bSelectedPenguinCard = false
  ;
  (EventManager.Hit)("PenguinCard_RollPenguinCard")
end

PenguinLevel.SelectPenguinCard = function(self, nIndex)
  -- function num : 0_39 , upvalues : _ENV
  local mapSelectCard = (self.tbSelectablePenguinCard)[nIndex]
  local bUpgrade, nAimIndex = self:CheckUpgradePenguinCard(mapSelectCard)
  if not bUpgrade and self.nSlotCount <= self:GetOwnPenguinCardCount() then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("PenguinCard_SlotMax"))
    return 
  end
  if bUpgrade then
    local nAddLevel = mapSelectCard.nLevel
    ;
    ((self.tbPenguinCard)[nAimIndex]):Upgrade(nAddLevel)
  else
    do
      do
        local mapCard = self:CreatePenguinCard(mapSelectCard.nId)
        -- DECOMPILER ERROR at PC35: Confused about usage of register: R6 in 'UnsetPending'

        ;
        (self.tbPenguinCard)[nAimIndex] = mapCard
        ;
        ((self.tbPenguinCard)[nAimIndex]):SetSlotIndex(nAimIndex)
        ;
        ((self.tbPenguinCard)[nAimIndex]):ResetAllTrigger()
        self.bSelectedPenguinCard = true
        self.nGetPenguinCardCount = self.nGetPenguinCardCount + 1
        self:AfterChangePenguinCard()
        ;
        (EventManager.Hit)("PenguinCard_SelectPenguinCard", nAimIndex, bUpgrade)
      end
    end
  end
end

PenguinLevel.AfterChangePenguinCard = function(self)
  -- function num : 0_40 , upvalues : _ENV
  local nAllLevel = 0
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 then
      nAllLevel = nAllLevel + v.nLevel
    end
  end
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).PenguinCardChange, {PenguinCardLevel = nAllLevel})
end

PenguinLevel.CheckUpgradePenguinCard = function(self, mapSelectCard)
  -- function num : 0_41 , upvalues : _ENV
  local bUpgrade = false
  local nFirstEmpty = 0
  local nAimIndex = 0
  for i,v in ipairs(self.tbPenguinCard) do
    if v == 0 and nFirstEmpty == 0 then
      nFirstEmpty = i
    end
    if v ~= 0 and v.nGroupId == mapSelectCard.nGroupId then
      bUpgrade = true
      nAimIndex = i
      break
    end
  end
  do
    if not bUpgrade then
      nAimIndex = nFirstEmpty
    end
    return bUpgrade, nAimIndex
  end
end

PenguinLevel.SalePenguinCard = function(self, nIndex)
  -- function num : 0_42 , upvalues : _ENV
  self:ChangeScore(((self.tbPenguinCard)[nIndex]).nSoldPrice)
  local mapCard = (self.tbPenguinCard)[nIndex]
  local nGroupId = mapCard.nGroupId
  self:RecyclePenguinCard(mapCard)
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbPenguinCard)[nIndex] = 0
  self:AfterChangePenguinCard()
  ;
  (EventManager.Hit)("PenguinCard_SalePenguinCard", nIndex, nGroupId)
end

PenguinLevel.GetRollPenguinCardCost = function(self)
  -- function num : 0_43 , upvalues : _ENV
  local findIntervalIndex = function(x, starts)
    -- function num : 0_43_0 , upvalues : _ENV
    if not starts or #starts == 0 or x < starts[1] then
      return 1
    end
    local low, high = 1, #starts
    local best = 1
    while 1 do
      while 1 do
        if low <= high then
          local mid = (math.floor)((low + high) / 2)
          if starts[mid] <= x then
            best = mid
            low = mid + 1
            -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
      high = mid - 1
    end
    do
      return best
    end
  end

  local mapData = (self.mapBuyCost)[self.nTurnBuyCount + 1]
  local nIndex = findIntervalIndex(self.nCurTurn, mapData.Turn)
  local nCost = (mapData.Cost)[nIndex]
  return nCost
end

PenguinLevel.ClearSelectablePenguinCard = function(self)
  -- function num : 0_44 , upvalues : _ENV
  if next(self.tbSelectablePenguinCard) ~= nil then
    for i = #self.tbSelectablePenguinCard, 1, -1 do
      local mapCard = (table.remove)(self.tbSelectablePenguinCard, i)
      self:RecyclePenguinCard(mapCard)
    end
  end
end

PenguinLevel.GetRollPenguinCardResult = function(self)
  -- function num : 0_45 , upvalues : _ENV, PenguinCardUtils
  local mapWeightCfg = (ConfigTable.GetData)("PenguinCardWeight", self.nWeightGroupId * 100 + self.nCurTurn)
  if not mapWeightCfg then
    return {}
  end
  local tbMaxGroupId = self:GetMaxLevelPenguinCard()
  local tbId = (PenguinCardUtils.WeightedRandom)(mapWeightCfg.CardList, mapWeightCfg.Weight, 3, tbMaxGroupId)
  return tbId
end

PenguinLevel.GetMaxLevelPenguinCard = function(self)
  -- function num : 0_46 , upvalues : _ENV
  local tbGroupId = {}
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 and v.nLevel == v.nMaxLevel then
      (table.insert)(tbGroupId, v.nGroupId)
    end
  end
  return tbGroupId
end

PenguinLevel.RecyclePenguinCard = function(self, mapCard)
  -- function num : 0_47 , upvalues : _ENV
  mapCard:Clear()
  ;
  (table.insert)(self.tbPenguinCardPool, mapCard)
end

PenguinLevel.CreatePenguinCard = function(self, nId)
  -- function num : 0_48 , upvalues : _ENV, PenguinCard
  local mapCard = nil
  if next(self.tbPenguinCardPool) == nil then
    mapCard = (PenguinCard.new)(nId)
  else
    mapCard = (table.remove)(self.tbPenguinCardPool, 1)
    mapCard:Init(nId)
  end
  return mapCard
end

PenguinLevel.RunState_Dealing = function(self)
  -- function num : 0_49 , upvalues : _ENV, PenguinCardUtils
  self.nCurRound = self.nCurRound + 1
  self.nTotalRound = self.nTotalRound + 1
  self.tbHandRank = {}
  self.nHandRankId = 0
  self.mapAllSuit = {}
  self.nRoundScore = 0
  self.nRoundValue = 0
  self.nRoundRatio = 1
  self.nRoundMultiRatio = 0
  self.mapCalBaseCardPool = clone(self.mapBaseCardPool)
  for _,v in ipairs(self.tbBuff) do
    v:ResetRoundTrigger()
  end
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 then
      v:ResetRoundTrigger()
    end
  end
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).Dealing)
  self.tbBaseCardId = (PenguinCardUtils.WeightedRandom)((self.mapCalBaseCardPool).tbId, (self.mapCalBaseCardPool).tbWeight, self.nBaseCardCount, {}, true)
  if self.nFixedTurnGroupId > 0 then
    local nFixedId = self.nFixedTurnGroupId * 10000 + self.nCurTurn * 100 + self.nCurRound
    local mapFixedCfg = (ConfigTable.GetData)("PenguinCardFixedTurn", nFixedId, true)
    if mapFixedCfg then
      self.tbBaseCardId = mapFixedCfg.BaseCardId
    end
  end
  do
    self.tbShowedCard = {}
    for i = 1, self.nBaseCardCount do
      -- DECOMPILER ERROR at PC79: Confused about usage of register: R5 in 'UnsetPending'

      (self.tbShowedCard)[i] = false
    end
    ;
    (EventManager.Hit)("PenguinCard_RunState_Dealing")
    self:SwitchGameState()
  end
end

PenguinLevel.QuitState_Dealing = function(self, nNextState)
  -- function num : 0_50 , upvalues : _ENV, PenguinCardUtils
  (EventManager.Hit)("PenguinCard_QuitState_Dealing", nNextState)
  local nWaitTime = 0
  if nNextState == (PenguinCardUtils.GameState).Start then
    nWaitTime = 0.6
  else
    if nNextState == (PenguinCardUtils.GameState).Flip then
      nWaitTime = 0.85
    else
      if nNextState == (PenguinCardUtils.GameState).Complete then
        nWaitTime = 0.6
      end
    end
  end
  return nWaitTime
end

PenguinLevel.ChangeBaseCardWeight = function(self, tbChangeWeight)
  -- function num : 0_51 , upvalues : _ENV
  for k,v in pairs(tbChangeWeight) do
    local nIndex = (table.indexof)((self.mapCalBaseCardPool).tbId, tonumber(k))
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.mapCalBaseCardPool).tbWeight)[nIndex] = ((self.mapCalBaseCardPool).tbWeight)[nIndex] + v
  end
end

PenguinLevel.RunState_Flip = function(self)
  -- function num : 0_52 , upvalues : _ENV
  (EventManager.Hit)("PenguinCard_RunState_Flip")
  self:PlayAuto()
end

PenguinLevel.QuitState_Flip = function(self, nNextState)
  -- function num : 0_53 , upvalues : _ENV, PenguinCardUtils
  self:StopAuto()
  ;
  (EventManager.Hit)("PenguinCard_QuitState_Flip", nNextState)
  local nWaitTime = 0
  if nNextState == (PenguinCardUtils.GameState).Start then
    nWaitTime = 0.6
  else
    if nNextState == (PenguinCardUtils.GameState).Settlement then
      nWaitTime = 1
    else
      if nNextState == (PenguinCardUtils.GameState).Complete then
        nWaitTime = 0.6
      end
    end
  end
  return nWaitTime
end

PenguinLevel.ShowBaseCard = function(self, nIndex)
  -- function num : 0_54 , upvalues : _ENV
  local add = function(i)
    -- function num : 0_54_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbShowedCard)[i] == false then
      (self.tbShowedCard)[i] = true
      local nId = (self.tbBaseCardId)[i]
      local mapCfg = (ConfigTable.GetData)("PenguinBaseCard", nId)
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R3 in 'UnsetPending'

      if mapCfg then
        if not (self.mapAllSuit)[mapCfg.Suit1] then
          (self.mapAllSuit)[mapCfg.Suit1] = 0
        end
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (self.mapAllSuit)[mapCfg.Suit1] = (self.mapAllSuit)[mapCfg.Suit1] + mapCfg.SuitCount1
        local SuitCards = {}
        if mapCfg.SuitCount1 > 0 then
          (table.insert)(SuitCards, mapCfg.Suit1)
        end
        if mapCfg.SuitCount2 > 0 then
          (table.insert)(SuitCards, mapCfg.Suit2)
        end
        local SuitCount = {}
        if mapCfg.SuitCount1 > 0 then
          SuitCount[mapCfg.Suit1] = mapCfg.SuitCount1
        end
        if mapCfg.SuitCount2 > 0 then
          SuitCount[mapCfg.Suit2] = mapCfg.SuitCount2
        end
        self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).Flip, {SuitCards = SuitCards, SuitCount = SuitCount, 
BaseCard = {nId = nId, nIndex = i}
})
      end
      do
        local mapAfterCfg = (ConfigTable.GetData)("PenguinBaseCard", (self.tbBaseCardId)[i])
        if mapAfterCfg then
          self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).FlipEnd, {
BaseCard = {nId = (self.tbBaseCardId)[i], nIndex = i}
})
          if self.mapQuest ~= nil then
            (self.mapQuest):AddProgress((GameEnum.PenguinCardQuestType).SuitCount, {nId = mapAfterCfg.Suit1, nCount = mapAfterCfg.SuitCount1})
          end
        end
      end
    end
  end

  local bAll = nIndex == nil
  if bAll then
    for i = 1, self.nBaseCardCount do
      add(i)
    end
  else
    add(nIndex)
  end
  local nShowed = self:GetShowedCardCount()
  if nShowed == self.nBaseCardCount then
    self:CheckHandRank()
    self:SwitchGameState()
  end
  ;
  (EventManager.Hit)("PenguinCard_ShowBaseCard", nIndex)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PenguinLevel.CheckHandRank = function(self)
  -- function num : 0_55 , upvalues : _ENV
  local tbAllSuit = {}
  for k,v in pairs(self.mapAllSuit) do
    (table.insert)(tbAllSuit, {nSuit = k, nCount = v})
  end
  ;
  (table.sort)(tbAllSuit, function(a, b)
    -- function num : 0_55_0
    do return b.nCount < a.nCount end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  for _,v in ipairs(self.mapHandRankRule) do
    self.tbHandRank = {}
    local tbCount = v.SuitCount
    local nType = #tbCount
    local nHasType = #tbAllSuit
    local nAble = 0
    if nType <= nHasType then
      for i = 1, nType do
        if tbCount[i] <= (tbAllSuit[i]).nCount then
          nAble = nAble + 1
          for _ = 1, tbCount[i] do
            (table.insert)(self.tbHandRank, (tbAllSuit[i]).nSuit)
          end
        end
      end
    end
    do
      do
        if nAble == nType then
          self.nHandRankId = v.Id
          -- DECOMPILER ERROR at PC64: Confused about usage of register: R11 in 'UnsetPending'

          if not (self.tbHandRankCount)[self.nHandRankId] then
            (self.tbHandRankCount)[self.nHandRankId] = 0
          end
          -- DECOMPILER ERROR at PC71: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (self.tbHandRankCount)[self.nHandRankId] = (self.tbHandRankCount)[self.nHandRankId] + 1
          self:ChangeRoundScore(v.Value, v.Ratio, 0, true)
          if self.mapQuest ~= nil then
            (self.mapQuest):AddProgress((GameEnum.PenguinCardQuestType).HandRank, {nId = self.nHandRankId, nCount = 1})
          end
          break
        end
        -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
end

PenguinLevel.ChangeRoundScore = function(self, nAddValue, nAddRatio, nAddMultiRatio, bFromHandRank)
  -- function num : 0_56 , upvalues : _ENV
  local nBeforeScore = self.nRoundScore
  local nBeforeBase = self.nRoundValue
  local nBeforeMultiRatio = self.nRoundMultiRatio
  local nBeforeRatio = self.nRoundRatio
  self.nRoundValue = self.nRoundValue + nAddValue
  if nAddMultiRatio > 0 then
    if self.nRoundMultiRatio == 0 then
      self.nRoundMultiRatio = 1
    end
    self.nRoundMultiRatio = self.nRoundMultiRatio + (nAddMultiRatio - 1)
  end
  self.nRoundRatio = self.nRoundRatio + nAddRatio
  local nBeforeAllRatio = nBeforeMultiRatio > 0 and nBeforeMultiRatio * nBeforeRatio or nBeforeRatio
  if self.nRoundMultiRatio <= 0 or not self.nRoundRatio * self.nRoundMultiRatio then
    local nAfterAllRatio = self.nRoundRatio
  end
  nBeforeAllRatio = (math.floor)(nBeforeAllRatio * 100 + 0.5 + 1e-09) / 100
  nAfterAllRatio = (math.floor)(nAfterAllRatio * 100 + 0.5 + 1e-09) / 100
  self.nRoundScore = self.nRoundValue * (nAfterAllRatio)
  local nAddScore = self.nRoundScore - nBeforeScore
  self.nTurnScore = self.nTurnScore + nAddScore
  if self.nBestTurnScore < self.nTurnScore then
    self.nBestTurnScore = self.nTurnScore
  end
  if self.nBestRoundScore < self.nRoundScore then
    self.nBestRoundScore = self.nRoundScore
  end
  ;
  (EventManager.Hit)("PenguinCard_ChangeRoundScore", nBeforeBase, nBeforeAllRatio, nBeforeScore, bFromHandRank)
  if (NovaAPI.IsEditorPlatform)() then
    printLog("轮积分变化：" .. nAddScore .. "  (" .. nBeforeScore .. " -> " .. self.nRoundScore .. ")")
    printLog("基础变化：" .. nAddValue .. "  (" .. nBeforeBase .. " -> " .. self.nRoundValue .. ")")
    printLog("倍率变化：" .. nAfterAllRatio - nBeforeAllRatio .. "  (" .. nBeforeAllRatio .. " -> " .. nAfterAllRatio .. ")")
  end
end

PenguinLevel.GetShowedCardCount = function(self)
  -- function num : 0_57 , upvalues : _ENV
  local nShowed = 0
  for _,v in pairs(self.tbShowedCard) do
    if v then
      nShowed = nShowed + 1
    end
  end
  return nShowed
end

PenguinLevel.ReplaceBaseCard = function(self, nIndex, nBeforeId, nAfterId)
  -- function num : 0_58 , upvalues : _ENV
  local mapBeforeCfg = (ConfigTable.GetData)("PenguinBaseCard", nBeforeId)
  local mapAfterCfg = (ConfigTable.GetData)("PenguinBaseCard", nAfterId)
  if not mapBeforeCfg or not mapAfterCfg then
    return 
  end
  -- DECOMPILER ERROR at PC22: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.mapAllSuit)[mapBeforeCfg.Suit1] = (self.mapAllSuit)[mapBeforeCfg.Suit1] - mapBeforeCfg.SuitCount1
  -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

  if not (self.mapAllSuit)[mapAfterCfg.Suit1] then
    (self.mapAllSuit)[mapAfterCfg.Suit1] = 0
  end
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.mapAllSuit)[mapAfterCfg.Suit1] = (self.mapAllSuit)[mapAfterCfg.Suit1] + mapAfterCfg.SuitCount1
  -- DECOMPILER ERROR at PC40: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.tbBaseCardId)[nIndex] = nAfterId
  ;
  (EventManager.Hit)("PenguinCard_ReplaceBaseCard", nIndex)
end

PenguinLevel.RunState_Settlement = function(self)
  -- function num : 0_59 , upvalues : _ENV
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

  if not (self.mapHandRankHistory)[self.nHandRankId] then
    (self.mapHandRankHistory)[self.nHandRankId] = 0
  end
  -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapHandRankHistory)[self.nHandRankId] = (self.mapHandRankHistory)[self.nHandRankId] + 1
  local HandRankSuitCount = {}
  for _,v in ipairs(self.tbHandRank) do
    if not HandRankSuitCount[v] then
      HandRankSuitCount[v] = 0
    end
    HandRankSuitCount[v] = HandRankSuitCount[v] + 1
    -- DECOMPILER ERROR at PC32: Confused about usage of register: R7 in 'UnsetPending'

    if not (self.mapSuitHistory)[v] then
      (self.mapSuitHistory)[v] = 0
    end
    -- DECOMPILER ERROR at PC37: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self.mapSuitHistory)[v] = (self.mapSuitHistory)[v] + 1
  end
  self:TriggerEffect((GameEnum.PenguinCardTriggerPhase).Settlement, {HandRankSuitCount = HandRankSuitCount, SuitCount = self.mapAllSuit, HandRank = self.nHandRankId, HandRankCount = self.tbHandRankCount})
  self:AddLog()
  ;
  (EventManager.Hit)("PenguinCard_RunState_Settlement")
  self:PlayAuto()
end

PenguinLevel.QuitState_Settlement = function(self, nNextState)
  -- function num : 0_60 , upvalues : _ENV, PenguinCardUtils
  self:StopAuto()
  self:ChangeScore(self.nRoundScore)
  if self.mapQuest ~= nil then
    (self.mapQuest):AddProgress((GameEnum.PenguinCardQuestType).Score, {nCount = self.nRoundScore})
  end
  if self:GetRoundLimitInTurn() == self.nCurRound then
    self:EndTurn()
  end
  self.tbHandRank = {}
  self.nHandRankId = 0
  self.mapAllSuit = {}
  self.nRoundScore = 0
  self.nRoundValue = 0
  self.nRoundRatio = 1
  self.nRoundMultiRatio = 0
  self.mapCalBaseCardPool = {}
  ;
  (EventManager.Hit)("PenguinCard_QuitState_Settlement", nNextState)
  local nWaitTime = 0
  if nNextState == (PenguinCardUtils.GameState).Start then
    nWaitTime = 0.6
  else
    if nNextState == (PenguinCardUtils.GameState).Dealing then
      nWaitTime = 0.57
    else
      if nNextState == (PenguinCardUtils.GameState).Prepare then
        nWaitTime = 0.57
      else
        if nNextState == (PenguinCardUtils.GameState).Complete then
          nWaitTime = 0.6
        end
      end
    end
  end
  return nWaitTime
end

PenguinLevel.EndTurn = function(self)
  -- function num : 0_61
  local nBuffCount = #self.tbBuff
  for i = nBuffCount, 1, -1 do
    local bAble = ((self.tbBuff)[i]):AddDuration_Turn()
    if not bAble then
      self:DeleteBuff(i)
    end
  end
  if self.mapQuest ~= nil then
    (self.mapQuest):AddTurnCount()
  end
end

PenguinLevel.AddLog = function(self)
  -- function num : 0_62 , upvalues : _ENV
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

  if not (self.mapLog)[self.nCurTurn] then
    (self.mapLog)[self.nCurTurn] = {nTurnScore = 0, 
tbRound = {}
}
  end
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R1 in 'UnsetPending'

  ;
  ((self.mapLog)[self.nCurTurn]).nTurnScore = self.nTurnScore
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R1 in 'UnsetPending'

  if not (((self.mapLog)[self.nCurTurn]).tbRound)[self.nCurRound] then
    (((self.mapLog)[self.nCurTurn]).tbRound)[self.nCurRound] = {nRoundScore = 0, 
tbHandRank = {}
}
  end
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R1 in 'UnsetPending'

  ;
  ((((self.mapLog)[self.nCurTurn]).tbRound)[self.nCurRound]).nRoundScore = self.nRoundScore
  -- DECOMPILER ERROR at PC52: Confused about usage of register: R1 in 'UnsetPending'

  ;
  ((((self.mapLog)[self.nCurTurn]).tbRound)[self.nCurRound]).tbHandRank = clone(self.tbHandRank)
  -- DECOMPILER ERROR at PC60: Confused about usage of register: R1 in 'UnsetPending'

  ;
  ((((self.mapLog)[self.nCurTurn]).tbRound)[self.nCurRound]).nHandRankId = self.nHandRankId
end

PenguinLevel.RunState_Complete = function(self, mapParam)
  -- function num : 0_63 , upvalues : _ENV
  self.nStar = self:GetStar()
  ;
  (EventManager.Hit)("PenguinCard_RunState_Complete")
  if self.nActId then
    local tab = {}
    ;
    (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tab, {"activity_id", tostring(self.nActId)})
    ;
    (table.insert)(tab, {"battle_id", tostring(self.nLevelId)})
    ;
    (table.insert)(tab, {"round", tostring(self.nCurTurn)})
    ;
    (table.insert)(tab, {"result", tostring(self.nStar == 0 and 2 or 1)})
    local nEnd = mapParam and mapParam.bManual == true and 2 or 1
    ;
    (table.insert)(tab, {"end_type", tostring(nEnd)})
    ;
    (table.insert)(tab, {"score", tostring(self.nScore)})
    ;
    (table.insert)(tab, {"star", tostring(self.nStar)})
    local sId = ""
    for i = 1, 6 do
      if (self.tbPenguinCard)[i] ~= 0 then
        if sId == "" then
          sId = sId .. ((self.tbPenguinCard)[i]).nId
        else
          sId = sId .. "," .. ((self.tbPenguinCard)[i]).nId
        end
      end
    end
    ;
    (table.insert)(tab, {"card_list", sId})
    ;
    (table.insert)(tab, {"skill_1", tostring(self.nRoundLimit)})
    ;
    (table.insert)(tab, {"skill_2", tostring(self.nSlotCount)})
    ;
    (table.insert)(tab, {"skill_3", tostring(self.nBuyLimit)})
    ;
    (NovaAPI.UserEventUpload)("minigame_PenguinCard", tab)
  end
end

PenguinLevel.QuitState_Complete = function(self)
  -- function num : 0_64 , upvalues : _ENV
  self.nStar = 0
  ;
  (EventManager.Hit)("PenguinCard_QuitState_Complete")
  return 0
end

PenguinLevel.GetMostHandRank = function(self)
  -- function num : 0_65 , upvalues : _ENV
  local nCount = 0
  local nId = 0
  for k,v in pairs(self.mapHandRankHistory) do
    if nCount < v then
      nCount = v
      nId = k
    end
  end
  return nId, nCount
end

PenguinLevel.GetMostSuit = function(self)
  -- function num : 0_66 , upvalues : _ENV
  local nCount = 0
  local nId = 0
  for k,v in pairs(self.mapSuitHistory) do
    if nCount < v then
      nCount = v
      nId = k
    end
  end
  return nId, nCount
end

PenguinLevel.GetBestPenguinCard = function(self)
  -- function num : 0_67 , upvalues : _ENV
  local nCount = 0
  local mapCard = nil
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 and nCount < v.nLevel then
      nCount = v.nLevel
      mapCard = v
    end
  end
  return mapCard
end

PenguinLevel.SetAutoState = function(self, bAuto)
  -- function num : 0_68 , upvalues : LocalData
  self.bAuto = bAuto
  ;
  (LocalData.SetPlayerLocalData)("PenguinCardAuto", self.bAuto)
end

PenguinLevel.SetAutoSpeed = function(self, nSpeed)
  -- function num : 0_69 , upvalues : LocalData
  self.nSpeed = nSpeed
  ;
  (LocalData.SetPlayerLocalData)("PenguinCardSpeed", self.nSpeed)
  if self.sequence then
    self:StopAuto()
    self:PlayAuto()
  end
end

PenguinLevel.PlayAuto = function(self, bClick)
  -- function num : 0_70 , upvalues : PenguinCardUtils, _ENV
  if not self.bAuto or self.bPause then
    return 
  end
  if self.nGameState == (PenguinCardUtils.GameState).Flip then
    self.sequence = (DOTween.Sequence)()
    for j = 1, self.nBaseCardCount do
      do
        if (self.tbShowedCard)[j] == false then
          (self.sequence):AppendCallback(function()
    -- function num : 0_70_0 , upvalues : self, j
    self:ShowBaseCard(j)
  end
)
          ;
          (self.sequence):AppendInterval(0.2 / self.nSpeed)
        end
      end
    end
    ;
    (self.sequence):SetUpdate(true)
  else
    if self.nGameState == (PenguinCardUtils.GameState).Settlement then
      local bKeep = not (PlayerData.Guide):CheckGuideFinishById(302)
      if EditorSettings and EditorSettings.bJumpGuide then
        bKeep = false
      end
      if bKeep then
        return 
      end
      self.sequence = (DOTween.Sequence)()
      if self.nFireScore > self.nRoundValue or not 7 then
        (self.sequence):AppendInterval((bClick or 5) / self.nSpeed)
        ;
        (self.sequence):AppendCallback(function()
    -- function num : 0_70_1 , upvalues : _ENV, self
    (EventManager.Hit)("PenguinCard_QuitScoreAni")
    if self:GetRoundLimitInTurn() == self.nCurRound and self.nCurTurn < self.nMaxTurn then
      local callback = function()
      -- function num : 0_70_1_0 , upvalues : self
      self:SwitchGameState()
    end

      ;
      (EventManager.Hit)("PenguinCard_OpenLog", self.nCurTurn, false, callback)
    else
      do
        self:SwitchGameState()
      end
    end
  end
)
        ;
        (self.sequence):SetUpdate(true)
      end
    end
  end
end

PenguinLevel.StopAuto = function(self)
  -- function num : 0_71
  if self.sequence then
    (self.sequence):Kill()
    self.sequence = nil
  end
end

PenguinLevel.Pause = function(self)
  -- function num : 0_72 , upvalues : _ENV
  self.bPause = true
  if self.sequence then
    (self.sequence):Pause()
  end
  ;
  (EventManager.Hit)("PenguinCard_Pause")
end

PenguinLevel.Resume = function(self)
  -- function num : 0_73 , upvalues : _ENV
  self.bPause = false
  if self.sequence then
    (self.sequence):Play()
  else
    self:PlayAuto()
  end
  ;
  (EventManager.Hit)("PenguinCard_Resume")
end

PenguinLevel.ChangeScore = function(self, nChange)
  -- function num : 0_74 , upvalues : _ENV, PenguinCardUtils
  if not nChange or nChange == 0 then
    return 
  end
  local nBefore = self.nScore
  self.nScore = self.nScore + nChange
  local nBeforeStar, nStar = 0, 0
  for i,v in ipairs(self.tbStarScore) do
    if v <= nBefore then
      nBeforeStar = i
    end
    if v <= self.nScore then
      nStar = i
    end
  end
  if nBeforeStar == 0 and nStar == 1 and self.nGameState == (PenguinCardUtils.GameState).Settlement then
    self.bPreTurnWin = true
  end
  ;
  (EventManager.Hit)("PenguinCard_ChangeScore", nBefore, nBeforeStar, nStar)
  if (NovaAPI.IsEditorPlatform)() then
    printLog("总积分变化：" .. nChange .. "  (" .. nBefore .. " -> " .. self.nScore .. ")")
  end
end

PenguinLevel.GetStar = function(self)
  -- function num : 0_75 , upvalues : _ENV
  local nStar = 0
  for i,v in ipairs(self.tbStarScore) do
    if v <= self.nScore then
      nStar = i
    end
  end
  return nStar
end

PenguinLevel.SetWarning = function(self, bAble)
  -- function num : 0_76
  self.bWarning = bAble
end

PenguinLevel.GetOwnPenguinCardCount = function(self)
  -- function num : 0_77
  local nCount = 0
  for i = 1, 6 do
    if (self.tbPenguinCard)[i] ~= 0 then
      nCount = nCount + 1
    end
  end
  return nCount
end

PenguinLevel.ExecuteEffect = function(self, nEffectType, mapEffectValue, mapTriggerSource)
  -- function num : 0_78 , upvalues : _ENV
  if nEffectType == (GameEnum.PenguinCardEffectType).AddBaseCardWeight then
    self:ChangeBaseCardWeight(mapEffectValue)
  else
    if nEffectType == (GameEnum.PenguinCardEffectType).ReplaceBaseCard then
      self:ReplaceBaseCard((mapTriggerSource.BaseCard).nIndex, (mapTriggerSource.BaseCard).nId, mapEffectValue[1])
    else
      if nEffectType == (GameEnum.PenguinCardEffectType).IncreaseBasicChips then
        self:ChangeRoundScore(mapEffectValue, 0, 0)
      else
        if nEffectType == (GameEnum.PenguinCardEffectType).IncreaseMultiplier then
          self:ChangeRoundScore(0, mapEffectValue, 0)
        else
          if nEffectType == (GameEnum.PenguinCardEffectType).MultiMultiplier then
            self:ChangeRoundScore(0, 0, mapEffectValue)
          else
            if nEffectType == (GameEnum.PenguinCardEffectType).UpgradeDiscount then
              self.nUpgradeDiscount = mapEffectValue / 100
            else
              if nEffectType == (GameEnum.PenguinCardEffectType).AddRound then
                self.nTempAddRound = self.nTempAddRound + mapEffectValue
              else
                if nEffectType == (GameEnum.PenguinCardEffectType).BlockFatalDamage then
                  self:ChangeHp(-1 * mapTriggerSource.nHpChange)
                  ;
                  (EventManager.Hit)("PenguinCard_BlockFatalDamage")
                else
                  if nEffectType == (GameEnum.PenguinCardEffectType).UpgradeRebate then
                    self:ChangeScore(mapTriggerSource.nUpgradeCost * mapEffectValue / 100)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

PenguinLevel.TriggerEffect = function(self, nTriggerPhase, mapTriggerSource)
  -- function num : 0_79 , upvalues : _ENV
  local callback = function(nEffectType, mapEffectValue)
    -- function num : 0_79_0 , upvalues : self, mapTriggerSource
    self:ExecuteEffect(nEffectType, mapEffectValue, mapTriggerSource)
  end

  local nBuffCount = #self.tbBuff
  for i = nBuffCount, 1, -1 do
    local bTriggered = ((self.tbBuff)[i]):Trigger(nTriggerPhase, mapTriggerSource, callback)
    if bTriggered then
      local bAble = ((self.tbBuff)[i]):AddDuration_Count()
      if not bAble then
        local nDelayTime = ((self.tbBuff)[i]):GetDelayTime()
        self:DeleteBuff(i, nDelayTime)
      end
    end
  end
  for _,v in ipairs(self.tbPenguinCard) do
    if v ~= 0 then
      v:Trigger(nTriggerPhase, mapTriggerSource, callback)
      v:Growth(nTriggerPhase, mapTriggerSource)
    end
  end
end

return PenguinLevel

