KillswitchDb = {}

keyid_to_username = {}

-- Returns the Username of the owner of this engine's killswitch
-- or nil if unowned.
function KillswitchDb.GetOwner(keyid)
    return keyid_to_username[keyid]
end

function KillswitchDb.SetOwner(keyid, username)
    keyid_to_username[keyid] = username
end