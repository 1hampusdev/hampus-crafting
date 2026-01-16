Framework = {}
Framework.Type = nil
Framework.Object = nil

CreateThread(function()
    -- Try qbx_core first
    local ok, obj = pcall(function()
        return exports['qbx_core']:GetCoreObject()
    end)

    if ok and obj then
        Framework.Type = 'QBX'
        Framework.Object = obj
        print('[hampus-crafting] Using qbx_core')
        return
    end

    -- Try ESX Legacy
    local esx = nil
    TriggerEvent('esx:getSharedObject', function(obj) esx = obj end)
    if esx then
        Framework.Type = 'ESX'
        Framework.Object = esx
        print('[hampus-crafting] Using ESX Legacy')
        return
    end

    print('[hampus-crafting] No framework detected, running inventory-only mode')
end)

function Framework.GetPlayer(source)
    if Framework.Type == 'QBX' then
        return Framework.Object.Functions.GetPlayer(source)
    elseif Framework.Type == 'ESX' then
        return Framework.Object.GetPlayerFromId(source)
    end
    return nil
end
