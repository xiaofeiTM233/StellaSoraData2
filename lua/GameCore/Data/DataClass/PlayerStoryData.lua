local PlayerStoryData = class("PlayerStoryData")
PlayerStoryData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbRecentStoryInfo = {Type = (GameEnum.StoryPreviewType).StorySet, ChapterId = 1001, StoryId = 100101}
  self.nLastMainlineStoryId = 101
end

PlayerStoryData.CacheLastStory = function(self, msgData)
  -- function num : 0_1 , upvalues : _ENV
  if msgData == nil then
    return 
  end
  if msgData.Story ~= nil then
    self.nLastMainlineStoryId = (msgData.Story).Idx
  end
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R2 in 'UnsetPending'

  if msgData.StorySet ~= nil then
    (self.tbRecentStoryInfo).Type = (GameEnum.StoryPreviewType).StorySet
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.tbRecentStoryInfo).ChapterId = (msgData.StorySet).ChapterId
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.tbRecentStoryInfo).StoryId = (msgData.StorySet).SectionId
  end
end

PlayerStoryData.SetLastMainlineStoryId = function(self, storyId)
  -- function num : 0_2
  self.nLastMainlineStoryId = storyId
end

PlayerStoryData.GetLastMainlineStoryId = function(self)
  -- function num : 0_3
  return self.nLastMainlineStoryId
end

PlayerStoryData.GetRecentStoryInfo = function(self)
  -- function num : 0_4 , upvalues : _ENV
  if (self.tbRecentStoryInfo).Type == (GameEnum.StoryPreviewType).None then
    return false
  end
  if (self.tbRecentStoryInfo).Type == (GameEnum.StoryPreviewType).ActivityStory then
    if (self.tbRecentStoryInfo).StoryId == nil or (self.tbRecentStoryInfo).ChapterId == nil then
      return false
    end
    local config = (ConfigTable.GetData)("ActivityStoryChapter", (self.tbRecentStoryInfo).ChapterId, "")
    if config == nil then
      return false
    end
    return true
  else
    do
      if (self.tbRecentStoryInfo).Type == (GameEnum.StoryPreviewType).StorySet then
        if (self.tbRecentStoryInfo).ChapterId == nil then
          return false
        end
        local config = (ConfigTable.GetData)("StorySetChapter", (self.tbRecentStoryInfo).ChapterId, "")
        if config == nil then
          return false
        end
        local title = (ConfigTable.GetUIText)("Nova_Story") .. " " .. config.Title
        return true, self.tbRecentStoryInfo, title, config.Banner
      end
    end
  end
end

PlayerStoryData.SetRecentStoryInfo = function(self, type, chapterId, storyId)
  -- function num : 0_5 , upvalues : _ENV
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R4 in 'UnsetPending'

  (self.tbRecentStoryInfo).Type = type
  -- DECOMPILER ERROR at PC3: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbRecentStoryInfo).ChapterId = chapterId
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbRecentStoryInfo).StoryId = storyId
  local msgData = {}
  if type == (GameEnum.StoryPreviewType).StorySet then
    msgData = {Type = 1, 
StorySet = {ChapterId = chapterId, SectionId = storyId}
}
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_last_read_update_req, msgData)
end

return PlayerStoryData

