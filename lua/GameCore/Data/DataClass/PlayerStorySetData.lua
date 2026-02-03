local PlayerStorySetData = class("PlayerStorySetData")
PlayerStorySetData.Init = function(self)
  -- function num : 0_0
  self.tbChapter = {}
  self.bGetData = false
  self:InitConfig()
end

PlayerStorySetData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local funcForeachSection = function(mapData)
    -- function num : 0_1_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbChapter)[mapData.ChapterId] == nil then
      (self.tbChapter)[mapData.ChapterId] = {}
      -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.tbChapter)[mapData.ChapterId]).tbSectionList = {}
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.tbChapter)[mapData.ChapterId]).bUnlock = false
    end
    ;
    (table.insert)(((self.tbChapter)[mapData.ChapterId]).tbSectionList, {nId = mapData.Id, nSortId = mapData.SortId, nStatus = (AllEnum.StorySetStatus).Lock})
  end

  ForEachTableLine((ConfigTable.Get)("StorySetSection"), funcForeachSection)
  for _,v in pairs(self.tbChapter) do
    if v.tbSectionList ~= nil then
      (table.sort)(v.tbSectionList, function(a, b)
    -- function num : 0_1_1
    do return a.nId < b.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    end
  end
end

PlayerStorySetData.UnInit = function(self)
  -- function num : 0_2
end

PlayerStorySetData.UpdateStorySetState = function(self, bState)
  -- function num : 0_3 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Story_Set_Server, nil, bState)
end

PlayerStorySetData.CacheStorySetData = function(self, netMsg)
  -- function num : 0_4 , upvalues : _ENV
  if netMsg.Chapters ~= nil then
    local nChapterId = -1
    for _,data in ipairs(netMsg.Chapters) do
      -- DECOMPILER ERROR at PC16: Confused about usage of register: R8 in 'UnsetPending'

      if (self.tbChapter)[data.ChapterId] ~= nil then
        ((self.tbChapter)[data.ChapterId]).bUnlock = true
        local nCurIndex = data.SectionIndex or 0
        nCurIndex = nCurIndex + 1
        local bShow = false
        local mapChapterCfg = (ConfigTable.GetData)("StorySetChapter", data.ChapterId)
        if mapChapterCfg ~= nil then
          bShow = mapChapterCfg.IsShow
        end
        for nIndex,v in ipairs(((self.tbChapter)[data.ChapterId]).tbSectionList) do
          if nIndex <= nCurIndex then
            v.nStatus = (AllEnum.StorySetStatus).UnLock
          end
          if (table.indexof)(data.RewardedIds, v.nId) > 0 then
            v.nStatus = (AllEnum.StorySetStatus).Received
          end
          local mapCfg = (ConfigTable.GetData)("StorySetChapter", data.ChapterId)
          ;
          (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {mapCfg.TabId, data.ChapterId, v.nId}, (v.nStatus == (AllEnum.StorySetStatus).UnLock and bShow))
        end
        local chapterHasRedDot = (RedDotManager.GetValid)(RedDotDefine.Story_Set_Chapter, {data.TadId, data.ChapterId})
        if chapterHasRedDot == true then
          if nChapterId < 0 then
            nChapterId = data.ChapterId
          else
            nChapterId = (math.min)(nChapterId, data.ChapterId)
          end
        end
        self:SetRecentChapterId(nChapterId)
      end
    end
  end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

PlayerStorySetData.UnlockNewChapter = function(self, nId)
  -- function num : 0_5 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbChapter)[nId] ~= nil then
    ((self.tbChapter)[nId]).bUnlock = true
    local bShow = false
    local mapCfg = (ConfigTable.GetData)("StorySetChapter", nId)
    if mapCfg ~= nil then
      bShow = mapCfg.IsShow
    end
    for k,v in ipairs(((self.tbChapter)[nId]).tbSectionList) do
      if k == 1 then
        v.nStatus = (AllEnum.StorySetStatus).UnLock
        ;
        (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {mapCfg.TabId, nId, v.nId}, bShow)
        break
      end
    end
  end
end

PlayerStorySetData.GetAllChapterList = function(self, nType, bOnlyShowUnRead)
  -- function num : 0_6 , upvalues : _ENV
  local tbChapter = {}
  local tabCfg = (ConfigTable.GetData)("StorySetTab", nType)
  for nId,v in pairs(self.tbChapter) do
    local mapCfg = (ConfigTable.GetData)("StorySetChapter", nId)
    if mapCfg ~= nil and mapCfg.IsShow and (mapCfg.TabId == nType or tabCfg.IsAll) then
      local bShow = true
      do
        do
          if bOnlyShowUnRead == true then
            local chapterHasRedDot = (RedDotManager.GetValid)(RedDotDefine.Story_Set_Chapter, {mapCfg.TabId, mapCfg.Id})
            if chapterHasRedDot ~= true then
              bShow = false
            end
          end
          if bShow == true then
            (table.insert)(tbChapter, {nId = nId, tbSectionList = v.tbSectionList, bUnlock = v.bUnlock})
          end
          -- DECOMPILER ERROR at PC53: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC53: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC53: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  ;
  (table.sort)(tbChapter, function(a, b)
    -- function num : 0_6_0
    do return a.nId < b.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbChapter
end

PlayerStorySetData.GetAllTabList = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local tbTabData = {}
  local foreachFunc = function(mapData)
    -- function num : 0_7_0 , upvalues : _ENV, tbTabData
    if mapData.OpenTime == "" or not ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapData.OpenTime) then
      local openTime = mapData.IsShow ~= true or 0
    end
    local curTime = ((CS.ClientManager).Instance).serverTimeStamp
    if openTime <= curTime then
      (table.insert)(tbTabData, mapData)
    end
  end

  ForEachTableLine((ConfigTable.Get)("StorySetTab"), foreachFunc)
  return tbTabData
end

PlayerStorySetData.TryOpenStorySetPanel = function(self, callback)
  -- function num : 0_8
  if not self.bGetData then
    self:SendGetStorySetData(callback)
  else
    if callback ~= nil then
      callback()
    end
  end
end

PlayerStorySetData.SetRecentChapterId = function(self, chapterId)
  -- function num : 0_9
  self.nRecentChapterId = chapterId
end

PlayerStorySetData.GetRecentChapterId = function(self)
  -- function num : 0_10
  return self.nRecentChapterId
end

PlayerStorySetData.IsChapterAllRead = function(self, nChapterId)
  -- function num : 0_11 , upvalues : _ENV
  if (self.tbChapter)[nChapterId] == nil then
    return false
  end
  local chapter = (self.tbChapter)[nChapterId]
  if not chapter.bUnlock then
    return false
  end
  if chapter.tbSectionList == nil or #chapter.tbSectionList == 0 then
    return false
  end
  for _,section in ipairs(chapter.tbSectionList) do
    if section.nStatus ~= (AllEnum.StorySetStatus).Received then
      return false
    end
  end
  return true
end

PlayerStorySetData.SendGetStorySetData = function(self, callback)
  -- function num : 0_12 , upvalues : _ENV
  local func_cb = function(_, netMsg)
    -- function num : 0_12_0 , upvalues : _ENV, callback
    (RedDotManager.SetValid)(RedDotDefine.Story_Set_Server, nil, false)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).story_set_info_req, {}, nil, func_cb)
end

PlayerStorySetData.ReceiveStorySetReward = function(self, nChapterId, nSectionId, callback)
  -- function num : 0_13 , upvalues : _ENV
  local func_cb = function(_, netMsg)
    -- function num : 0_13_0 , upvalues : self, nChapterId, _ENV, nSectionId, callback
    if (self.tbChapter)[nChapterId] ~= nil then
      local nIndex = 0
      for k,v in ipairs(((self.tbChapter)[nChapterId]).tbSectionList) do
        if v.nId == nSectionId then
          nIndex = k
          break
        end
      end
      do
        -- DECOMPILER ERROR at PC31: Confused about usage of register: R3 in 'UnsetPending'

        if nIndex ~= 0 then
          ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nStatus = (AllEnum.StorySetStatus).Received
          local mapCfg = (ConfigTable.GetData)("StorySetChapter", nChapterId)
          ;
          (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {mapCfg.TabId, nChapterId, nSectionId}, false)
          nIndex = nIndex + 1
        end
        do
          -- DECOMPILER ERROR at PC64: Confused about usage of register: R3 in 'UnsetPending'

          if nIndex <= #((self.tbChapter)[nChapterId]).tbSectionList then
            ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nStatus = (AllEnum.StorySetStatus).UnLock
            local bShow = false
            local mapCfg = (ConfigTable.GetData)("StorySetChapter", nChapterId)
            if mapCfg ~= nil then
              bShow = mapCfg.IsShow
            end
            local nId = ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nId
            local mapCfg = (ConfigTable.GetData)("StorySetChapter", nChapterId)
            ;
            (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {mapCfg.TabId, nChapterId, nId}, bShow)
          end
          do
            if callback ~= nil then
              callback(netMsg)
            end
            self:SetRecentChapterId(nChapterId)
            ;
            (EventManager.Hit)("ReceiveStorySetRewardSuc")
          end
        end
      end
    end
  end

  local msg = {ChapterId = nChapterId, SectionId = nSectionId}
  local tabEvent = {}
  ;
  (table.insert)(tabEvent, {"story_id", tostring(nSectionId)})
  local _skip = (PlayerData.Avg).bSkip == true and "1" or "0"
  ;
  (table.insert)(tabEvent, {"is_skip", _skip})
  ;
  (table.insert)(tabEvent, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("set_story", tabEvent)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).story_set_reward_receive_req, msg, nil, func_cb)
end

return PlayerStorySetData

