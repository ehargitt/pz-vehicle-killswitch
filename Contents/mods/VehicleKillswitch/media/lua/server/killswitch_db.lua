KillswitchDb = {}

local db_store = "mod_" .. KillswitchInfo.MOD_ID .. "db_store.txt"
local keyid_to_username = {}

-- Returns the Username of the owner of this engine's killswitch
-- or nil if unowned.
function KillswitchDb.GetOwner(keyid)
    return keyid_to_username[keyid]
end

function KillswitchDb.SetOwner(keyid, username)
    keyid_to_username[keyid] = username
end

function Init()
    keyid_to_username = ACUtils.io_persistence.load(db_store, KillswitchInfo.MOD_ID);
    if keyid_to_username == nil then
        keyid_to_username = {}
    end
end

function OnSave()
    if db_store ~= nil then
        error = ACUtils.io_persistence.store(db_store, KillswitchInfo.MOD_ID, keyid_to_username)
    end
end

Events.OnServerStarted.Add(Init)
Events.OnServerStartSaving.Add(OnSave)
Events.OnLoad.Add(Init)
Events.OnSave.Add(OnSave)