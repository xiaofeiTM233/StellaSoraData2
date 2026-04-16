local NotificationManager = {}
local TimerManager = require("GameCore.Timer.TimerManager")
local Event = require("GameCore.Event.Event")
local SDKManager = (CS.SDKManager).Instance
local tbNotification = {}
local bAppSuspended = false
local OnApplicationFocus = function(_, bFocus)
  -- function num : 0_0 , upvalues : bAppSuspended
  bAppSuspended = not bFocus
end

NotificationManager.RegisterNotification = function(nId, nSubkey, nTime)
  -- function num : 0_1 , upvalues : SDKManager, _ENV, TimerManager, bAppSuspended, tbNotification
  if not SDKManager:IsSDKInit() then
    return 
  end
  if not (NovaAPI.IsMobilePlatform)() then
    return 
  end
  local configData = (ConfigTable.GetData)("NotificationConfig", nId)
  if configData == nil then
    printLog("NotificationManager 注册推送失败，配置表数据不存在")
    return 
  end
  local setTime = nTime - 5000
  if setTime <= ((CS.ClientManager).Instance).serverTimeStamp then
    return 
  end
  local data = {id = nId, key = nId + nSubkey, time = nTime, timer = (TimerManager.Add)(1, setTime - ((CS.ClientManager).Instance).serverTimeStamp, nil, function()
    -- function num : 0_1_0 , upvalues : bAppSuspended, _ENV, nId, nSubkey
    if not bAppSuspended then
      printLog("NotificationManager 由计时器触发的取消推送成功，id:", tostring(nId + nSubkey))
      UnregisterNotification(nId, nSubkey)
    end
  end
, true, true, false, nil)}
  ;
  (table.insert)(tbNotification, data)
  local sContent = configData.Content
  sContent = (string.gsub)(sContent, "==PLAYER_NAME==", (PlayerData.Base):GetPlayerNickName())
  SDKManager:BuildLocalNotification(nId + nSubkey, configData.Title, sContent, nTime)
  printLog("NotificationManager 注册推送成功，id:", tostring(nId + nSubkey), "title:", configData.Title, "content:", sContent, "time:", tostring(setTime))
end

NotificationManager.UnregisterNotification = function(nId, nSubkey)
  -- function num : 0_2 , upvalues : SDKManager, _ENV, tbNotification
  if not SDKManager:IsSDKInit() then
    return 
  end
  if not (NovaAPI.IsMobilePlatform)() then
    return 
  end
  local tbRemove = {}
  for i,data in ipairs(tbNotification) do
    if data.id == nId and data.key == nId + nSubkey then
      (data.timer):_Stop()
      ;
      (table.remove)(tbNotification, i)
      ;
      (table.insert)(tbRemove, nId + nSubkey)
      break
    end
  end
  do
    SDKManager:DeleteLocalNotification(tbRemove)
    printLog("NotificationManager 取消推送成功，id:", tostring(nId + nSubkey))
  end
end

local Uninit = function()
  -- function num : 0_3 , upvalues : _ENV, NotificationManager, Uninit, OnApplicationFocus
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, NotificationManager, Uninit)
  ;
  (EventManager.Remove)("CS2LuaEvent_OnApplicationFocus", NotificationManager, OnApplicationFocus)
end

NotificationManager.Init = function()
  -- function num : 0_4 , upvalues : _ENV, NotificationManager, Uninit, OnApplicationFocus
  (EventManager.Add)(EventId.CSLuaManagerShutdown, NotificationManager, Uninit)
  ;
  (EventManager.Add)("CS2LuaEvent_OnApplicationFocus", NotificationManager, OnApplicationFocus)
end

return NotificationManager

