function isPlayerJobMatching(tattooJobs, playerJob)
    if not playerJob or not playerJob.name then
        dbg.info('isPlayerJobMatching: playerJob not passed!')
        return false
    end

    for _, tattooJob in pairs(tattooJobs) do
        if not tattooJob.name then
            dbg.error('isPlayerJobMatching: Missing job name in tattoo permissions config!')
            break
        end

        if tattooJob.name == playerJob.name then
            if playerJob.grade == nil and tattooJob.grade == nil then
                return true
            end
            
            if tattooJob.grade == nil then
                return true
            end

            if playerJob.grade ~= nil and playerJob.grade >= tattooJob.grade then
                return true
            end
        end
    end
end

-- If you need to do something extra after rcore_tattoos resets the player's tattoos
-- you can put it here and it will be executed after each tattoo reset (after buy, preview, remove..)

-- If you don't have any idea what to put here, ignore it
-- Could be used for example if someone gets their hair fades from other script deleted by our tattoo reset
-- because hair fades are considered to be tattoos in GTA. You could simply reapply the hair fades here somehow. 
function resetPedDecorationsExtra()
    return
end

-- This commands is for debugging when business bossmenu marker isn't working correctly
if Config.Debug then
    RegisterCommand("rcore_tattoos_reload_markers", function(source, args, rawCommand)
        TriggerEvent('rcore_tattoos:reloadBusinessMarkers')
    end, false)
end


------------------------------
-- Menu open/closing events

-- If you don't have any idea what to put here, ignore it
-- Use on your own risk, use these functions only if you are experienced,
-- support is not provided with these extra functions
------------------------------

-- This function is called before tattoo shop menu is opened
function beforeMenuOpen(pos, onlyPreview)
    getNaked(pos, onlyPreview)
end

-- This function is called after tattoo shop menu is closed
function afterMenuClose()
    resetSkin()
end
