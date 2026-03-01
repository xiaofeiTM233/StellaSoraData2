local BaseCtrl = require("GameCore.UI.BaseCtrl")
local SpringFestivalThemeCtrl = class("SpringFestivalThemeCtrl", BaseCtrl)
local ClientManager = (CS.ClientManager).Instance
local TimerManager = require("GameCore.Timer.TimerManager")
SpringFestivalThemeCtrl._mapNodeConfig = {
btnEntrance_ = {nCount = 5, sComponentName = "UIButton", callback = "OnBtn_ClickActivityEntrance"}
, 
imgRemaineTime = {}
, 
txtActivityTime = {sComponentName = "TMP_Text"}
, 
txtActivityDate = {sComponentName = "TMP_Text"}
, 
imgEnd = {}
, 
txtActivityEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
imgMiniGame = {sComponentName = "Image"}
, 
txtMiniGame = {sComponentName = "TMP_Text", sLanguageId = "Activity_Mini_Game_Cookie"}
, 
imgMiniGameEnd = {}
, 
txtMiniGameEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_Mini_Game_Cookie"}
, 
txtMiniGame_End = {}
, 
txtTask = {sComponentName = "TMP_Text", sLanguageId = "Activity_Task"}
, 
txtTaskProgress = {sComponentName = "TMP_Text"}
, 
imgTaskActivityTime = {}
, 
txtTaskActivityTime = {sComponentName = "TMP_Text"}
, 
imgStory = {sComponentName = "Image"}
, 
goStoryEnd = {}
, 
txtStory = {sComponentName = "TMP_Text", sLanguageId = "Activity_Story"}
, 
txtStoryEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
txtMiniGameEndState = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
txtTaskEndState = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
txtShopEndState = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
txtShop = {sComponentName = "TMP_Text", sLanguageId = "Activity_Shop"}
, 
imgShopActivityTime = {}
, 
txtShopActivityTime = {sComponentName = "TMP_Text"}
, 
imgLevel = {sComponentName = "Image"}
, 
goLevelEnd = {}
, 
txtLevel = {sComponentName = "TMP_Text", sLanguageId = "Activity_Level"}
, 
txtLevel_End = {sComponentName = "TMP_Text", sLanguageId = "Activity_Level"}
, 
txtLevelEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_End"}
, 
imgLevelActivityUnlockTime = {}
, 
txtLevelActivityUnlockTime = {sComponentName = "TMP_Text"}
, 
imgLevelEnd = {}
, 
TopBar = {sNodeName = "TopBarPanel", sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"}
, 
imgMiniGameActivityUnlockTime = {}
, 
txtMiniGameActivityUnlockTime = {sComponentName = "TMP_Text"}
, 
imgTaskBgEnd = {}
, 
txtTaskEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_Task"}
, 
txtTaskProgress_End = {}
, 
imgTaskActivityUnlockTime = {}
, 
txtTaskActivityUnlockTime = {sComponentName = "TMP_Text"}
, 
imgStoryActivityTime = {}
, 
txtStoryActivityTime = {sComponentName = "TMP_Text"}
, 
imgStoryActivityUnlockTime = {}
, 
txtStoyActivityUnlockTime = {sComponentName = "TMP_Text"}
, 
imgShopActivityUnlockTime = {}
, 
txtShopActivityUnlockTime = {sComponentName = "TMP_Text"}
, 
imgLevelActivityTime = {}
, 
txtLevelActivityTime = {sComponentName = "TMP_Text"}
, 
imgMiniGameActivityTime = {}
, 
txtMiniGameActivityTime = {sComponentName = "TMP_Text"}
, 
txtShopEnd = {sComponentName = "TMP_Text", sLanguageId = "Activity_Shop"}
, 
imgShopEnd = {}
, 
txtShop_End = {}
, 
txtTaskProgressEnd = {sComponentName = "TMP_Text"}
, 
dbTaskEnd = {}
, 
redDotEntrance2 = {}
, 
storyRedDot = {}
, 
reddotLevel = {}
, 
goMiniGameEnd = {}
, 
imgStoryEnd = {}
, 
txtStory_End = {sComponentName = "TMP_Text", sLanguageId = "Activity_Story"}
, 
Chensha_Chopsticks_01 = {}
, 
Chensha_Chopsticks_02 = {}
, 
Eat_01 = {}
, 
Eat_02 = {}
, 
Eat_03 = {}
, 
Chensha_Expression_02 = {}
, 
Chensha_Expression_01 = {}
, 
dbMiniGameEnd = {}
}
SpringFestivalThemeCtrl._mapEventConfig = {}
local ActivityState = {NotOpen = 1, Open = 2, Closed = 3}
SpringFestivalThemeCtrl.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local param = self:GetPanelParam()
  if type(param) == "table" then
    self.nActId = param[1]
    self.bFromEntrance = param[2]
  end
  self.animRoot = (self.gameObject):GetComponent("Animator")
  self.SpringFestivalData = (PlayerData.Activity):GetActivityGroupDataById(self.nActId)
  if self.SpringFestivalData ~= nil then
    self.ActivityGroupCfg = (self.SpringFestivalData).actGroupConfig
  end
end

SpringFestivalThemeCtrl.FadeIn = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Hit)(EventId.SetTransition)
end

SpringFestivalThemeCtrl.OnEnable = function(self)
  -- function num : 0_2 , upvalues : _ENV, ActivityState
  do
    if self.animRoot ~= nil then
      local sAnim = "SpringThemePanel_in_02"
      if self.bFromEntrance then
        sAnim = "SpringThemePanel_in_01"
      end
      ;
      (self.animRoot):Play(sAnim, 0, 0)
    end
    self:RefreshPanel()
    for i = 1, 5 do
      local actData = (self.SpringFestivalData):GetActivityDataByIndex(i)
      if i == (AllEnum.ActivityThemeFuncIndex).Task then
        local nActId = actData.ActivityId
        local state = (self.tbActState)[nActId]
        if state == ActivityState.Closed then
          ((self._mapNode).redDotEntrance2):SetActive(false)
        else
          ;
          (RedDotManager.RegisterNode)(RedDotDefine.Activity_Group_Task, {self.nActId, nActId}, (self._mapNode).redDotEntrance2)
        end
      else
        do
          if i == (AllEnum.ActivityThemeFuncIndex).Level then
            local nActId = actData.ActivityId
            ;
            (RedDotManager.RegisterNode)(RedDotDefine.ActivityLevel, {self.nActId, nActId}, (self._mapNode).reddotLevel)
          else
            do
              do
                if i == (AllEnum.ActivityThemeFuncIndex).Story then
                  local nActId = actData.ActivityId
                  ;
                  (RedDotManager.RegisterNode)(RedDotDefine.Activity_GroupNew_Avg_Group, {self.nActId, nActId}, (self._mapNode).storyRedDot)
                end
                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC88: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
    self:StartEatingAnimation()
  end
end

SpringFestivalThemeCtrl.OnDisable = function(self)
  -- function num : 0_3 , upvalues : TimerManager
  if self.minigameRemainTimer ~= nil then
    (TimerManager.Remove)(self.minigameRemainTimer)
    self.minigameRemainTimer = nil
  end
  if self.remainTimer ~= nil then
    (TimerManager.Remove)(self.remainTimer)
    self.remainTimer = nil
  end
  if self.shopRemainTimer ~= nil then
    (TimerManager.Remove)(self.shopRemainTimer)
    self.shopRemainTimer = nil
  end
  if self.levelRemainTimer ~= nil then
    (TimerManager.Remove)(self.levelRemainTimer)
    self.levelRemainTimer = nil
  end
  if self.avgRemainTimer ~= nil then
    (TimerManager.Remove)(self.avgRemainTimer)
    self.avgRemainTimer = nil
  end
  if self.taskRemainTimer ~= nil then
    (TimerManager.Remove)(self.taskRemainTimer)
    self.taskRemainTimer = nil
  end
  if self.updateTimer ~= nil then
    (self.updateTimer):Cancel()
    self.updateTimer = nil
  end
end

SpringFestivalThemeCtrl.RefreshPanel = function(self)
  -- function num : 0_4
  if self.SpringFestivalData == nil or self.ActivityGroupCfg == nil then
    return 
  end
  self:RefreshTime()
  self:RefreshButtonState()
end

SpringFestivalThemeCtrl.RefreshTime = function(self)
  -- function num : 0_5 , upvalues : TimerManager, _ENV
  local bOpen = (self.SpringFestivalData):CheckActivityGroupOpen()
  if bOpen then
    self:RefreshRemainTime((self.SpringFestivalData):GetActGroupEndTime(), (self._mapNode).txtActivityTime)
    if self.remainTimer == nil then
      self.remainTimer = self:AddTimer(0, 1, function()
    -- function num : 0_5_0 , upvalues : self, TimerManager
    local remainTime = self:RefreshRemainTime((self.SpringFestivalData):GetActGroupEndTime(), (self._mapNode).txtActivityTime)
    if remainTime <= 0 then
      (TimerManager.Remove)(self.remainTimer)
      self.remainTimer = nil
    end
  end
, true, true, false)
    end
  end
  ;
  ((self._mapNode).imgRemaineTime):SetActive(bOpen)
  ;
  ((self._mapNode).imgEnd):SetActive(not bOpen)
  local nOpenMonth, nOpenDay, nEndMonth, nEndDay, nOpenYear, nEndYear = (self.SpringFestivalData):GetActGroupDate()
  local strOpenDay = (string.format)("%d", nOpenDay)
  local strEndDay = (string.format)("%d", nEndDay)
  local dateStr = (string.format)("%s/%s/%s ~ %s/%s/%s", nOpenYear, nOpenMonth, strOpenDay, nEndYear, nEndMonth, strEndDay)
  ;
  (NovaAPI.SetTMPText)((self._mapNode).txtActivityDate, dateStr)
end

SpringFestivalThemeCtrl.RefreshRemainTime = function(self, endTime, txtComp)
  -- function num : 0_6 , upvalues : ClientManager, _ENV
  local curTime = ClientManager.serverTimeStamp
  local remainTime = endTime - curTime
  local sTimeStr = ""
  if remainTime <= 60 then
    local sec = (math.floor)(remainTime)
    sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Remain_Time_Sec") or "", sec)
  else
    do
      if remainTime > 60 and remainTime <= 3600 then
        local min = (math.floor)(remainTime / 60)
        local sec = (math.floor)(remainTime - min * 60)
        if sec == 0 then
          min = min - 1
          sec = 60
        end
        sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Remain_Time_Min") or "", min, sec)
      else
        do
          if remainTime > 3600 and remainTime <= 86400 then
            local hour = (math.floor)(remainTime / 3600)
            local min = (math.floor)((remainTime - hour * 3600) / 60)
            if min == 0 then
              hour = hour - 1
              min = 60
            end
            sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Remain_Time_Hour") or "", hour, min)
          else
            do
              if remainTime > 86400 then
                local day = (math.floor)(remainTime / 86400)
                local hour = (math.floor)((remainTime - day * 86400) / 3600)
                if hour == 0 then
                  day = day - 1
                  hour = 24
                end
                sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Remain_Time_Day") or "", day, hour)
              end
              do
                ;
                (NovaAPI.SetTMPText)(txtComp, sTimeStr)
                return remainTime
              end
            end
          end
        end
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshRemainOpenTime = function(self, openTime)
  -- function num : 0_7 , upvalues : ClientManager, _ENV
  local curTime = ClientManager.serverTimeStamp
  local remainTime = openTime - curTime
  local sTimeStr = ""
  if remainTime <= 60 then
    local sec = (math.floor)(remainTime)
    sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Open_Time_Sec") or "", sec)
  else
    do
      if remainTime > 60 and remainTime <= 3600 then
        local min = (math.floor)(remainTime / 60)
        sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Open_Time_Min") or "", min)
      else
        do
          if remainTime > 3600 and remainTime <= 86400 then
            local hour = (math.floor)(remainTime / 3600)
            sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Open_Time") or "", hour)
          else
            do
              do
                if remainTime > 86400 then
                  local day = (math.floor)(remainTime / 86400)
                  sTimeStr = orderedFormat((ConfigTable.GetUIText)("Activity_Open_Time_Day") or "", day)
                end
                return sTimeStr
              end
            end
          end
        end
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshButtonState = function(self)
  -- function num : 0_8 , upvalues : _ENV
  self.tbActState = {}
  for i = 1, 5 do
    local actData = (self.SpringFestivalData):GetActivityDataByIndex(i)
    if i == (AllEnum.ActivityThemeFuncIndex).MiniGame then
      self:RefreshMiniGameButtonState(actData)
    else
      if i == (AllEnum.ActivityThemeFuncIndex).Task then
        self:RefreshTaskButtonState(actData)
      else
        if i == (AllEnum.ActivityThemeFuncIndex).Level then
          self:RefreshLevelButtonState(actData)
        else
          if i == (AllEnum.ActivityThemeFuncIndex).Shop then
            self:RefreshShopButtonState(actData)
          else
            if i == (AllEnum.ActivityThemeFuncIndex).Story then
              self:RefreshStoryButtonState(actData)
            end
          end
        end
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshButtonTimer = function(self, actData, timer, txtTrans, imgTrans, refreshFunc)
  -- function num : 0_9 , upvalues : _ENV, ActivityState, ClientManager, TimerManager
  local countDowmTimer = nil
  local activityId = actData.ActivityId
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  local state = ActivityState.NotOpen
  local bShowCountDown = false
  if activityData ~= nil then
    local curTime = ClientManager.serverTimeStamp
    do
      if activityData.StartTime ~= "" and activityData.EndTime ~= "" then
        local openTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(activityData.StartTime)
        local endTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(activityData.EndTime)
        if curTime < openTime then
          state = ActivityState.NotOpen
        else
          if openTime <= curTime and curTime <= endTime then
            state = ActivityState.Open
          else
            state = ActivityState.Closed
          end
        end
      else
        do
          if activityData.EndType == (GameEnum.activityEndType).NoLimit then
            state = ActivityState.Open
            if activityData.StartTime ~= "" then
              local openTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(activityData.StartTime)
              if curTime < openTime then
                state = ActivityState.NotOpen
              end
            end
          end
          do
            -- DECOMPILER ERROR at PC78: Unhandled construct in 'MakeBoolean' P1

            if state == ActivityState.NotOpen and timer == nil and activityData.StartTime ~= "" and activityData.EndTime ~= "" then
              local openTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(activityData.StartTime)
              local fcTimer = function()
    -- function num : 0_9_0 , upvalues : curTime, ClientManager, openTime, self, imgTrans, _ENV, TimerManager, timer, countDowmTimer, activityId, ActivityState, refreshFunc, actData
    curTime = ClientManager.serverTimeStamp
    local remainTime = openTime - curTime
    if remainTime > 0 then
      local sTimeStr = self:RefreshRemainOpenTime(openTime)
      local txtUnlock = imgTrans:GetComponentInChildren(typeof((CS.TMPro).TMP_Text))
      if txtUnlock ~= nil then
        (NovaAPI.SetTMPText)(txtUnlock, sTimeStr)
      end
    else
      do
        imgTrans:SetActive(false)
        ;
        (TimerManager.Remove)(timer)
        countDowmTimer = nil
        -- DECOMPILER ERROR at PC39: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (self.tbActState)[activityId] = ActivityState.Open
        refreshFunc(actData)
        self:RefreshActivityData()
      end
    end
  end

              fcTimer()
              countDowmTimer = self:AddTimer(0, 1, fcTimer, true, true, false)
            end
            do
              if state == ActivityState.Open and activityData.StartTime ~= "" and activityData.EndTime ~= "" then
                local endTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(activityData.EndTime)
                if (self.SpringFestivalData):GetActGroupEndTime() < endTime then
                  bShowCountDown = true
                else
                  if endTime - curTime > 259200 then
                    bShowCountDown = endTime >= (self.SpringFestivalData):GetActGroupEndTime()
                    if timer == nil and bShowCountDown then
                      self:RefreshRemainTime(endTime, txtTrans)
                      local fcTimer = function()
    -- function num : 0_9_1 , upvalues : self, endTime, txtTrans, TimerManager, timer, countDowmTimer, refreshFunc, actData
    local remainTime = self:RefreshRemainTime(endTime, txtTrans)
    if remainTime <= 0 then
      (TimerManager.Remove)(timer)
      countDowmTimer = nil
      refreshFunc(actData)
    end
  end

                      fcTimer()
                      countDowmTimer = self:AddTimer(0, 1, fcTimer, true, true, false)
                    end
                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_THEN_STMT

                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_STMT

                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_STMT

                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_THEN_STMT

                    -- DECOMPILER ERROR at PC146: LeaveBlock: unexpected jumping out IF_STMT

                  end
                end
              end
            end
            curTime = state
            do return curTime, bShowCountDown, countDowmTimer end
            -- DECOMPILER ERROR: 3 unprocessed JMP targets
          end
        end
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshMiniGameButtonState = function(self, actData)
  -- function num : 0_10 , upvalues : _ENV, ActivityState
  local activityId = actData.ActivityId
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  if activityData ~= nil then
    local refreshFunc = function(actData)
    -- function num : 0_10_0 , upvalues : self
    self:RefreshMiniGameButtonState(actData)
  end

    local state, bShowCountDown, countDowmTimer = self:RefreshButtonTimer(actData, self.minigameRemainTimer, (self._mapNode).txtMiniGameActivityTime, (self._mapNode).imgMiniGameActivityUnlockTime, refreshFunc)
    if self.minigameRemainTimer == nil then
      self.minigameRemainTimer = countDowmTimer
    end
    ;
    ((self._mapNode).imgMiniGameActivityUnlockTime):SetActive(state == ActivityState.NotOpen)
    ;
    (((self._mapNode).imgMiniGameActivityTime).gameObject):SetActive((state == ActivityState.Open and bShowCountDown))
    ;
    ((self._mapNode).imgMiniGameEnd):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).txtMiniGame_End):SetActive(state == ActivityState.Closed)
    ;
    (((self._mapNode).txtMiniGameEnd).gameObject):SetActive(state == ActivityState.Closed)
    ;
    (((self._mapNode).goMiniGameEnd).gameObject):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).dbMiniGameEnd):SetActive(state == ActivityState.Closed)
    -- DECOMPILER ERROR at PC91: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbActState)[activityId] = state
  end
  -- DECOMPILER ERROR: 9 unprocessed JMP targets
end

SpringFestivalThemeCtrl.RefreshTaskButtonState = function(self, actData)
  -- function num : 0_11 , upvalues : _ENV, ActivityState
  local activityId = actData.ActivityId
  local actInsData = (PlayerData.Activity):GetActivityDataById(activityId)
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  if activityData ~= nil then
    local refreshFunc = function(actData)
    -- function num : 0_11_0 , upvalues : actInsData, self
    if actInsData ~= nil then
      actInsData:RefreshTaskRedDot()
    end
    self:RefreshTaskButtonState(actData)
  end

    local state, bShowCountDown, countDowmTimer = self:RefreshButtonTimer(actData, self.taskRemainTimer, (self._mapNode).txtTaskActivityTime, (self._mapNode).imgTaskActivityUnlockTime, refreshFunc)
    if self.taskRemainTimer == nil then
      self.taskRemainTimer = countDowmTimer
    end
    if state == ActivityState.Closed and actInsData ~= nil then
      actInsData:RefreshTaskRedDot()
    end
    ;
    ((self._mapNode).imgTaskActivityTime):SetActive((state == ActivityState.Open and bShowCountDown))
    ;
    ((self._mapNode).txtTaskProgress_End):SetActive(state == ActivityState.Closed)
    ;
    (((self._mapNode).dbTaskEnd).gameObject):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).imgTaskBgEnd):SetActive(state == ActivityState.Closed)
    ;
    (((self._mapNode).txtTaskEnd).gameObject):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).imgTaskActivityUnlockTime):SetActive(state == ActivityState.NotOpen)
    -- DECOMPILER ERROR at PC93: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbActState)[activityId] = state
    local ActivityTaskData = (PlayerData.Activity):GetActivityDataById(activityId)
    local nDone, nTotal = 0, 0
    if ActivityTaskData ~= nil then
      nDone = ActivityTaskData:CalcTotalProgress()
    end
    local progress = (string.format)("%d/%d", nDone, nTotal)
    ;
    (NovaAPI.SetTMPText)((self._mapNode).txtTaskProgress, progress)
    ;
    (NovaAPI.SetTMPText)((self._mapNode).txtTaskProgressEnd, progress)
  end
  -- DECOMPILER ERROR: 9 unprocessed JMP targets
end

SpringFestivalThemeCtrl.RefreshStoryButtonState = function(self, actData)
  -- function num : 0_12 , upvalues : _ENV, ActivityState
  local activityId = actData.ActivityId
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  if activityData ~= nil then
    local refreshFunc = function(actData)
    -- function num : 0_12_0 , upvalues : _ENV, activityId, self
    local avgData = (PlayerData.Activity):GetActivityDataById(activityId)
    if avgData ~= nil then
      avgData:RefreshAvgRedDot()
    end
    self:RefreshStoryButtonState(actData)
  end

    local state, bShowCountDown, countDowmTimer = self:RefreshButtonTimer(actData, self.avgRemainTimer, (self._mapNode).txtStoryActivityTime, (self._mapNode).imgStoryActivityUnlockTime, refreshFunc)
    if self.avgRemainTimer == nil then
      self.avgRemainTimer = countDowmTimer
    end
    do
      do
        if state == ActivityState.Closed then
          local avgData = (PlayerData.Activity):GetActivityDataById(activityId)
          if avgData ~= nil then
            avgData:RefreshAvgRedDot()
          end
        end
        ;
        ((self._mapNode).imgStoryActivityTime):SetActive((state == ActivityState.Open and bShowCountDown))
        ;
        ((self._mapNode).imgStoryActivityUnlockTime):SetActive(state == ActivityState.NotOpen)
        ;
        ((self._mapNode).goStoryEnd):SetActive(state == ActivityState.Closed)
        ;
        ((self._mapNode).imgStoryEnd):SetActive(state == ActivityState.Closed)
        ;
        (((self._mapNode).txtStory_End).gameObject):SetActive(state == ActivityState.Closed)
        -- DECOMPILER ERROR at PC83: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbActState)[activityId] = state
        -- DECOMPILER ERROR: 7 unprocessed JMP targets
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshLevelButtonState = function(self, actData)
  -- function num : 0_13 , upvalues : _ENV, ActivityState
  local activityId = actData.ActivityId
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  if activityData ~= nil then
    local refreshFunc = function(actData)
    -- function num : 0_13_0 , upvalues : _ENV, activityId, self
    local activityLevelsData = (PlayerData.Activity):GetActivityDataById(activityId)
    if activityLevelsData ~= nil then
      activityLevelsData:ChangeAllRedHot()
    end
    self:RefreshLevelButtonState(actData)
  end

    local state, bShowCountDown, countDowmTimer = self:RefreshButtonTimer(actData, self.levelRemainTimer, (self._mapNode).txtLevelActivityTime, (self._mapNode).imgLevelActivityUnlockTime, refreshFunc)
    if self.levelRemainTimer == nil then
      self.levelRemainTimer = countDowmTimer
    end
    do
      do
        if state == ActivityState.Closed then
          local activityLevelsData = (PlayerData.Activity):GetActivityDataById(activityId)
          if activityLevelsData ~= nil then
            activityLevelsData:ChangeAllRedHot()
          end
        end
        ;
        ((self._mapNode).imgLevelActivityTime):SetActive((state == ActivityState.Open and bShowCountDown))
        ;
        ((self._mapNode).imgLevelActivityUnlockTime):SetActive(state == ActivityState.NotOpen)
        ;
        ((self._mapNode).imgLevelEnd):SetActive(state == ActivityState.Closed)
        ;
        ((self._mapNode).goLevelEnd):SetActive(state == ActivityState.Closed)
        -- DECOMPILER ERROR at PC73: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbActState)[activityId] = state
        -- DECOMPILER ERROR: 6 unprocessed JMP targets
      end
    end
  end
end

SpringFestivalThemeCtrl.RefreshShopButtonState = function(self, actData)
  -- function num : 0_14 , upvalues : _ENV, ActivityState
  local activityId = actData.ActivityId
  local activityData = (ConfigTable.GetData)("Activity", activityId)
  if activityData ~= nil then
    local refreshFunc = function(actData)
    -- function num : 0_14_0 , upvalues : self
    self:RefreshShopButtonState(actData)
  end

    local state, bShowCountDown, countDowmTimer = self:RefreshButtonTimer(actData, self.shopRemainTimer, (self._mapNode).txtShopActivityTime, (self._mapNode).imgShopActivityUnlockTime, refreshFunc)
    if self.shopRemainTimer == nil then
      self.shopRemainTimer = countDowmTimer
    end
    ;
    ((self._mapNode).imgShopActivityTime):SetActive((state == ActivityState.Open and bShowCountDown))
    ;
    ((self._mapNode).imgShopActivityUnlockTime):SetActive(state == ActivityState.NotOpen)
    ;
    (((self._mapNode).txtShopEnd).gameObject):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).imgShopEnd):SetActive(state == ActivityState.Closed)
    ;
    ((self._mapNode).txtShop_End):SetActive(state == ActivityState.Closed)
    -- DECOMPILER ERROR at PC71: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbActState)[activityId] = state
  end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

SpringFestivalThemeCtrl.RequireActiviyData = function(self)
  -- function num : 0_15 , upvalues : _ENV
  if self.bRequiredActData then
    return 
  end
  local callFunc = function()
    -- function num : 0_15_0 , upvalues : self
    self.bRequireSucc = true
    self:RefreshPanel()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_detail_req, {}, nil, callFunc)
  self.bRequiredActData = true
  self:AddTimer(1, 1, function()
    -- function num : 0_15_1 , upvalues : self
    self.bRequiredActData = false
  end
, true, true, true)
end

SpringFestivalThemeCtrl.RefreshActivityData = function(self)
  -- function num : 0_16
  if self.bRequiredActData then
    return 
  end
  self:AddTimer(1, 3, self.RequireActiviyData, true, true, true)
end

SpringFestivalThemeCtrl.OnBtn_ClickActivityEntrance = function(self, btn, nIndex)
  -- function num : 0_17 , upvalues : ActivityState, _ENV
  local actData = (self.SpringFestivalData):GetActivityDataByIndex(nIndex)
  local state = (self.tbActState)[actData.ActivityId]
  if state == nil then
    return 
  end
  if state == ActivityState.Closed then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_End_Notice"))
    return 
  else
    if state == ActivityState.NotOpen then
      (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_Not_Open"))
      return 
    else
      if state == ActivityState.Open then
        local activityData = (PlayerData.Activity):GetActivityDataById(actData.ActivityId)
        if activityData == nil then
          local bHint = true
          if nIndex == (AllEnum.ActivityThemeFuncIndex).Story then
            bHint = not (PlayerData.ActivityAvg):HasActivityData(actData.ActivityId)
          end
          if self.bRequiredActData and bHint then
            (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_Data_Refreshing"))
            return 
          end
          if bHint then
            (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_Not_Open"))
            self:RequireActiviyData()
            return 
          end
        end
      end
    end
  end
  do
    if actData.PanelId ~= nil and ActivityState.Open == state then
      if nIndex == (AllEnum.ActivityThemeFuncIndex).MiniGame then
        local nRandom = (math.random)(35, 36)
        local func = function()
    -- function num : 0_17_0 , upvalues : _ENV, actData, self
    (EventManager.Hit)(EventId.OpenPanel, actData.PanelId, actData.ActivityId, self.nActId)
  end

        ;
        (EventManager.Hit)(EventId.SetTransition, nRandom, func)
      else
        do
          ;
          (EventManager.Hit)(EventId.OpenPanel, actData.PanelId, actData.ActivityId)
        end
      end
    end
  end
end

SpringFestivalThemeCtrl.StartEatingAnimation = function(self)
  -- function num : 0_18
  ((self._mapNode).Eat_01):SetActive(false)
  ;
  ((self._mapNode).Eat_02):SetActive(false)
  ;
  ((self._mapNode).Eat_03):SetActive(false)
  self.nEatingElapsed = 0
  self.nEatingDelay = 0
  self.nEatShowElapsed = nil
  self.selectedEat = nil
  if self.updateTimer ~= nil then
    (self.updateTimer):Cancel()
    self.updateTimer = nil
  end
  self.updateTimer = self:AddTimer(0, 0, "OnUpdate", true, true, true)
end

SpringFestivalThemeCtrl.PlayRandomEatingAnimation = function(self)
  -- function num : 0_19 , upvalues : _ENV
  ((self._mapNode).Eat_01):SetActive(false)
  ;
  ((self._mapNode).Eat_02):SetActive(false)
  ;
  ((self._mapNode).Eat_03):SetActive(false)
  local randomValue = (math.random)(1, 100)
  if randomValue <= 50 then
    self.selectedEat = (self._mapNode).Eat_03
  else
    if randomValue <= 85 then
      self.selectedEat = (self._mapNode).Eat_02
    else
      self.selectedEat = (self._mapNode).Eat_01
    end
  end
  ;
  ((self._mapNode).Chensha_Expression_02):SetActive(self.selectedEat ~= (self._mapNode).Eat_01)
  ;
  ((self._mapNode).Chensha_Expression_01):SetActive(self.selectedEat == (self._mapNode).Eat_01)
  self.nEatShowElapsed = 0
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

SpringFestivalThemeCtrl.OnUpdate = function(self)
  -- function num : 0_20
  if self.updateTimer == nil then
    return 
  end
  local nDeltaTime = (self.updateTimer):GetDelTime()
  if self.nEatShowElapsed ~= nil then
    self.nEatShowElapsed = self.nEatShowElapsed + nDeltaTime
    if self.nEatShowElapsed >= 0.13 then
      if self.selectedEat ~= nil then
        (self.selectedEat):SetActive(true)
      end
      self.nEatShowElapsed = nil
    end
  end
  self.nEatingElapsed = self.nEatingElapsed + nDeltaTime
  if self.nEatingDelay <= self.nEatingElapsed then
    self.nEatingElapsed = 0
    self.nEatingDelay = 4
    self:PlayRandomEatingAnimation()
  end
end

return SpringFestivalThemeCtrl

