local PlayerPotentialPreselectionData = class("PlayerPotentialPreselectionData")
local TimerManager = require("GameCore.Timer.TimerManager")
local saveCD = 5
PlayerPotentialPreselectionData.Init = function(self)
  -- function num : 0_0
  self.bGetData = false
  self.tbPreselectionList = {}
  self.mapCurUsePreselection = {}
  self.rankSaveTimer = nil
end

PlayerPotentialPreselectionData.CreateNewPreselection = function(self, mapNetData)
  -- function num : 0_1 , upvalues : _ENV
  local mapPotential = {}
  local tbCharPotential = {}
  for _,v in ipairs(mapNetData.CharPotentials) do
    local nCharId = v.CharId
    local tbPotential = {}
    for _,data in ipairs(v.Potentials) do
      (table.insert)(tbPotential, {nId = data.Id, nLevel = data.Level})
    end
    ;
    (table.insert)(tbCharPotential, {nCharId = nCharId, tbPotential = tbPotential})
  end
  mapPotential = {nId = mapNetData.Id, sName = mapNetData.Name, bPreference = mapNetData.Preference, tbCharPotential = tbCharPotential, nTimestamp = mapNetData.Timestamp}
  return mapPotential
end

PlayerPotentialPreselectionData.GetPreselectionById = function(self, nId)
  -- function num : 0_2 , upvalues : _ENV
  for _,v in ipairs(self.tbPreselectionList) do
    if v.nId == nId then
      return v
    end
  end
end

PlayerPotentialPreselectionData.SavePreselection = function(self, sName, bPreference, tbCharPotential, callback)
  -- function num : 0_3
  self:SendImportPotential(sName, bPreference, tbCharPotential, callback)
end

PlayerPotentialPreselectionData.PackPotentialData = function(self, tbCharPotential)
  -- function num : 0_4 , upvalues : _ENV
  local bit_buffer = {}
  local bit_pos = 0
  local to_uint32 = function(num)
    -- function num : 0_4_0 , upvalues : _ENV
    num = (math.floor)(num or 0)
    if num < 0 then
      num = 0
    else
      if num > 4294967295 then
        num = 4294967295
      end
    end
    return num
  end

  local add_bit = function(bit)
    -- function num : 0_4_1 , upvalues : bit_buffer, bit_pos
    bit_buffer[bit_pos] = bit
    bit_pos = bit_pos + 1
  end

  local write_bits = function(value, num_bits)
    -- function num : 0_4_2 , upvalues : add_bit
    for i = num_bits - 1, 0, -1 do
      add_bit(value >> i & 1)
    end
  end

  local pack_potential = function(tbAll, tbPotential, bSpecial)
    -- function num : 0_4_3 , upvalues : _ENV, write_bits
    for k,nId in ipairs(tbAll) do
      local nLevel = 0
      for _,data in ipairs(tbPotential) do
        if data.nId == nId then
          nLevel = data.nLevel
          break
        end
      end
      do
        do
          do
            if nLevel <= 0 or not 1 then
              local flag = not bSpecial or 0
            end
            write_bits(flag, 1)
            write_bits(nLevel, 3)
            -- DECOMPILER ERROR at PC33: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC33: LeaveBlock: unexpected jumping out DO_STMT

          end
        end
      end
    end
  end

  for k,v in ipairs(tbCharPotential) do
    if v.nCharId == 0 then
      return 
    end
    write_bits(to_uint32(v.nCharId), 32)
  end
  for k,v in ipairs(tbCharPotential) do
    local potentialCfg = (ConfigTable.GetData)("CharPotential", v.nCharId)
    if potentialCfg ~= nil then
      if k == 1 then
        pack_potential(potentialCfg.MasterSpecificPotentialIds, v.tbPotential, true)
        pack_potential(potentialCfg.MasterNormalPotentialIds, v.tbPotential, false)
        pack_potential(potentialCfg.CommonPotentialIds, v.tbPotential, false)
      else
        pack_potential(potentialCfg.AssistSpecificPotentialIds, v.tbPotential, true)
        pack_potential(potentialCfg.AssistNormalPotentialIds, v.tbPotential, false)
        pack_potential(potentialCfg.CommonPotentialIds, v.tbPotential, false)
      end
    end
  end
  local bytes = {}
  for i = 0, bit_pos - 1, 8 do
    local byte = 0
    for j = 0, 7 do
      if not bit_buffer[i + j] then
        do
          byte = byte * 2 + (i + j >= bit_pos or 0)
          byte = (byte) * 2
          -- DECOMPILER ERROR at PC90: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC90: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
    ;
    (table.insert)(bytes, (string.char)(byte))
  end
  return (((CS.System).Convert).ToBase64String)((table.concat)(bytes))
end

PlayerPotentialPreselectionData.UnPackPotentialData = function(self, b64Str)
  -- function num : 0_5 , upvalues : _ENV
  if not b64Str or type(b64Str) ~= "string" or b64Str == "" then
    return 
  end
  b64Str = b64Str:gsub("%s+", "")
  b64Str = b64Str:gsub("-", "+")
  b64Str = b64Str:gsub("_", "/")
  b64Str = b64Str:gsub("[^A-Za-z0-9+/=]", "")
  local len = #b64Str
  if len % 4 ~= 0 then
    b64Str = b64Str .. (string.rep)("=", 4 - len % 4)
  end
  if #b64Str % 4 ~= 0 then
    printError("Base64长度错误")
    return 
  end
  local ok, packed_data = xpcall(function()
    -- function num : 0_5_0 , upvalues : _ENV, b64Str
    return (((CS.System).Convert).FromBase64String)(b64Str)
  end
, function(e)
    -- function num : 0_5_1
    return e
  end
)
  if not ok then
    printError("Base64解码失败: " .. tostring(packed_data))
    return 
  end
  local bit_buffer = {}
  local bit_count = 0
  for i = 1, #packed_data do
    local byte = (string.byte)(packed_data, i)
    for j = 7, 0, -1 do
      local bit = byte >> j & 1
      bit_buffer[bit_count] = bit
      bit_count = bit_count + 1
    end
  end
  local bit_index = 0
  local read_bits = function(num_bits)
    -- function num : 0_5_2 , upvalues : bit_index, bit_count, bit_buffer
    local value = 0
    for i = num_bits - 1, 0, -1 do
      if not bit_buffer[bit_index] then
        do
          value = value + (bit_count <= bit_index or 0) * (1 << i)
          bit_index = bit_index + 1
          -- DECOMPILER ERROR at PC20: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC20: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
    return value
  end

  local tbCharPotential = {}
  for i = 1, 3 do
    local nCharId = read_bits(32)
    local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
    if mapCharCfg == nil or mapCharCfg.Visible == false or mapCharCfg.Available == false then
      printError("角色id解析错误")
      return 
    end
    ;
    (table.insert)(tbCharPotential, {CharId = nCharId, 
Potentials = {}
})
  end
  local nMaxLevel = (ConfigTable.GetConfigNumber)("PotentialPreselectionMaxLevel")
  local unpack_potential = function(tbPotential, tbAll, bSpecial)
    -- function num : 0_5_3 , upvalues : _ENV, read_bits, nMaxLevel
    for _,nId in ipairs(tbAll) do
      if bSpecial then
        local flag = read_bits(1)
        if flag == 1 then
          (table.insert)(tbPotential, {Id = nId, Level = 1})
        end
      else
        do
          do
            local nLevel = read_bits(3)
            if nMaxLevel < nLevel then
              printError("潜能等级异常")
              return false
            end
            if nLevel > 0 then
              (table.insert)(tbPotential, {Id = nId, Level = nLevel})
            end
            -- DECOMPILER ERROR at PC39: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC39: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC39: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    return true
  end

  for k,v in ipairs(tbCharPotential) do
    if v.CharId > 0 then
      local potentialCfg = (ConfigTable.GetData)("CharPotential", v.CharId)
      if potentialCfg then
        local bAvailable = true
        if k == 1 then
          if bAvailable then
            bAvailable = unpack_potential(v.Potentials, potentialCfg.MasterSpecificPotentialIds, true)
          end
          if bAvailable then
            do
              bAvailable = unpack_potential(v.Potentials, potentialCfg.MasterNormalPotentialIds, false)
              if bAvailable then
                bAvailable = unpack_potential(v.Potentials, potentialCfg.AssistSpecificPotentialIds, true)
              end
              if bAvailable then
                bAvailable = unpack_potential(v.Potentials, potentialCfg.AssistNormalPotentialIds, false)
              end
              if bAvailable then
                bAvailable = unpack_potential(v.Potentials, potentialCfg.CommonPotentialIds, false)
              end
              if not bAvailable then
                return 
              end
              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC186: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  return tbCharPotential
end

PlayerPotentialPreselectionData.SavePreselectionFromRank = function(self, sName, bPreference, tbCharPotential, callback)
  -- function num : 0_6 , upvalues : _ENV, TimerManager, saveCD
  if self.rankSaveTimer ~= nil then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Potential_Preselection_Save_CD"))
    return 
  end
  self.rankSaveTimer = (TimerManager.Add)(1, saveCD, nil, function()
    -- function num : 0_6_0 , upvalues : self
    (self.rankSaveTimer):Cancel()
    self.rankSaveTimer = nil
  end
, true, true, true, nil)
  self:SendImportPotential(sName, bPreference, tbCharPotential, callback)
end

PlayerPotentialPreselectionData.GetPreselectionList = function(self)
  -- function num : 0_7
  return self.tbPreselectionList
end

PlayerPotentialPreselectionData.SendGetPreselectionList = function(self, callback)
  -- function num : 0_8 , upvalues : _ENV
  if not self.bGetData then
    local netCallback = function(_, mapNetData)
    -- function num : 0_8_0 , upvalues : self, _ENV, callback
    self.bGetData = true
    self.tbPreselectionList = {}
    for _,v in ipairs(mapNetData.List) do
      local mapData = self:CreateNewPreselection(v)
      ;
      (table.insert)(self.tbPreselectionList, mapData)
    end
    if callback ~= nil then
      callback()
    end
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_list_req, {}, nil, netCallback)
  else
    do
      if callback ~= nil then
        callback()
      end
    end
  end
end

PlayerPotentialPreselectionData.SendDeletePreselection = function(self, tbIds, callback)
  -- function num : 0_9 , upvalues : _ENV
  local netCallback = function(_, mapNetData)
    -- function num : 0_9_0 , upvalues : _ENV, self, tbIds, callback
    local tbTemp = {}
    for k,v in ipairs(self.tbPreselectionList) do
      if (table.indexof)(tbIds, v.nId) == 0 then
        (table.insert)(tbTemp, v)
      end
    end
    self.tbPreselectionList = tbTemp
    local tbAllTeam = (PlayerData.Team):GetAllTeamData()
    if tbAllTeam ~= nil then
      for nIdx,v in ipairs(tbAllTeam) do
        if (table.indexof)(tbIds, v.nPreselectionId) > 0 then
          local tmpDisc = v.tbTeamDiscId
          local tbTeamMemberId = v.tbTeamMemberId
          ;
          (PlayerData.Team):UpdateFormationInfo(nIdx, tbTeamMemberId, tmpDisc, 0)
        end
      end
    end
    do
      if callback ~= nil then
        callback()
      end
      ;
      (EventManager.Hit)("DeletePotentialPreselection")
    end
  end

  local msgData = {Ids = tbIds}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_delete_req, msgData, nil, netCallback)
end

PlayerPotentialPreselectionData.SendChangePreselectionName = function(self, nId, sName, callback)
  -- function num : 0_10 , upvalues : _ENV
  local netCallback = function()
    -- function num : 0_10_0 , upvalues : _ENV, self, nId, sName, callback
    for _,v in ipairs(self.tbPreselectionList) do
      if v.nId == nId then
        v.sName = sName
        break
      end
    end
    do
      if callback ~= nil then
        callback()
      end
    end
  end

  local msgData = {Id = nId, Name = sName}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_name_set_req, msgData, nil, netCallback)
end

PlayerPotentialPreselectionData.SendPreselectionPreference = function(self, tbCheckIns, tbCheckOutIds, callback)
  -- function num : 0_11 , upvalues : _ENV
  local netCallback = function(_, mapNetData)
    -- function num : 0_11_0 , upvalues : _ENV, self, tbCheckIns, tbCheckOutIds, callback
    for _,v in ipairs(self.tbPreselectionList) do
      if tbCheckIns ~= nil and (table.indexof)(tbCheckIns, v.nId) > 0 then
        v.bPreference = true
      end
      if tbCheckOutIds ~= nil and (table.indexof)(tbCheckOutIds, v.nId) > 0 then
        v.bPreference = false
      end
    end
    if callback ~= nil then
      callback()
    end
  end

  local msgData = {CheckInIds = tbCheckIns, CheckOutIds = tbCheckOutIds}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_preference_set_req, msgData, nil, netCallback)
end

PlayerPotentialPreselectionData.SendUpdatePotential = function(self, nId, tbCharPotential, callback)
  -- function num : 0_12 , upvalues : _ENV
  local netCallback = function(_, mapNetData)
    -- function num : 0_12_0 , upvalues : self, _ENV, nId, callback
    local mapData = self:CreateNewPreselection(mapNetData)
    for k,v in ipairs(self.tbPreselectionList) do
      -- DECOMPILER ERROR at PC13: Confused about usage of register: R8 in 'UnsetPending'

      if v.nId == nId then
        (self.tbPreselectionList)[k] = mapData
        break
      end
    end
    do
      if callback ~= nil then
        callback(mapData)
      end
    end
  end

  local msgData = {Id = nId, CharPotentials = tbCharPotential}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_update_req, msgData, nil, netCallback)
end

PlayerPotentialPreselectionData.SendImportPotential = function(self, sName, bPreference, tbCharPotential, callback)
  -- function num : 0_13 , upvalues : _ENV
  local netCallback = function(_, mapNetData)
    -- function num : 0_13_0 , upvalues : self, _ENV, callback
    local bInList = false
    local mapData = self:CreateNewPreselection(mapNetData)
    for k,v in ipairs(self.tbPreselectionList) do
      if v.nId == mapData.nId then
        bInList = true
        -- DECOMPILER ERROR at PC15: Confused about usage of register: R9 in 'UnsetPending'

        ;
        (self.tbPreselectionList)[k] = mapData
        break
      end
    end
    do
      if not bInList then
        (table.insert)(self.tbPreselectionList, mapData)
      end
      if callback ~= nil then
        callback(mapData)
      end
    end
  end

  local msgData = {Name = sName, Preference = bPreference, CharPotentials = tbCharPotential}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).potential_preselection_import_req, msgData, nil, netCallback)
end

return PlayerPotentialPreselectionData

