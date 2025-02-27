local playerLoaded = false

local playerModels = {
    [0] = 'mp_m_freemode_01',
    [1] = 'mp_f_freemode_01'
}

local defaultSpawnCoords = Config.Spawn

local cam = nil

Citizen.CreateThreadNow(function()
    DoScreenFadeOut(0)
    Wait(1500)
    while true do
        Wait(100)
        if NetworkIsSessionActive() or NetworkIsPlayerActive(PlayerId()) then
            exports['spawnmanager']:setAutoSpawn(false)
            Wait(1000)

            if Config.Framework == "esx" then
                TriggerServerEvent('qb-multicharacter:server:resetCurrentChar')
            end
            
            CharacterSelect()
            SetEntityVisible(PlayerPedId(), false)
            TriggerEvent('esx:loadingScreenOff')
            break
        end
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData, isNew, skin)
    local spawn = playerData.coords or vector3(Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    if isNew or not skin or #skin == 1 then
        local finished = false
        if playerData.sex == nil or playerData.sex == 0 then
            playerData.sex = "m"
        end
        skin = Config.Default[playerData.sex]
        skin.sex = playerData.sex == "m" and 0 or 1
        local model = skin.sex == 0 and "mp_m_freemode_01" or "mp_f_freemode_01"
        RequestModel(model)

        while not HasModelLoaded(model) do
            RequestModel(model)
            Wait(0)
        end

        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        TriggerEvent("skinchanger:loadSkin", skin, function()
            local playerPed = PlayerPedId()
            SetPedAoBlobRendering(playerPed, true)
            ResetEntityAlpha(playerPed)
            TriggerServerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:onPlayerSpawn")
            TriggerEvent("playerSpawned")
            TriggerEvent("esx:restoreLoadout")

            TriggerEvent("esx_skin:openSaveableMenu", function()
                finished = true
            end, function()
                finished = true
            end)
        end)
        repeat
            Wait(200)
        until finished
    else
        if playerData.sex == nil or playerData.sex == 0 then
            playerData.sex = "m"
        end
        skin.sex = playerData.sex == "m" and 0 or 1
        local model = skin.sex == 0 and "mp_m_freemode_01" or "mp_f_freemode_01"

        RequestModel(model)

        while not HasModelLoaded(model) do
            RequestModel(model)
            Wait(0)
        end

        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        TriggerEvent("skinchanger:loadSkin", skin, function()
            local playerPed = PlayerPedId()
            SetPedAoBlobRendering(playerPed, true)
            ResetEntityAlpha(playerPed)
            local playerId = PlayerId()
            SetEntityVisible(playerPed, true, 0)
            SetPlayerInvincible(playerId, false)
        end)
    end

    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
	cam = nil
    local playerPed = PlayerPedId()
    SetEntityVisible(PlayerPedId(), true, 0)
    FreezeEntityPosition(playerPed, false)
    if isNew then
        SetEntityCoords(playerPed, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, false, false, false, true)
    else
        SetEntityCoords(playerPed, spawn.x, spawn.y, spawn.z, false, false, false, true)
    end

    if not isNew then
        TriggerEvent("skinchanger:loadSkin", skin)
        Wait(500)
        SetEntityVisible(PlayerPedId(), true, 0)
    end
end)

-- RegisterNetEvent('esx:firstloaded')
-- AddEventHandler('esx:firstloaded', function(playerData, isNew, skin)
-- 	local playerPed = PlayerPedId()

-- 	SetEntityCoords(playerPed, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)

-- 	if isNew or not skin or #skin == 1 then
-- 		local finished = false
-- 		skin = Config.Default[playerData.sex]
-- 		skin.sex = playerData.sex == "m" and 0 or 1
-- 		local model = skin.sex == 0 and mp_m_freemode_01 or mp_f_freemode_01
-- 		RequestModel(model)
-- 		while not HasModelLoaded(model) do
-- 			RequestModel(model)
-- 			Wait(0)
-- 		end
-- 		SetPlayerModel(PlayerId(), model)
-- 		SetModelAsNoLongerNeeded(model)
-- 	end

--     if Config.SkinSystem == "skinchanger" then
--         TriggerEvent('skinchanger:loadSkin', skin, function()
--             local playerPed = PlayerPedId()
--             SetPedAoBlobRendering(playerPed, true)
--             ResetEntityAlpha(playerPed)
--             TriggerEvent('esx_skin:openSaveableMenu', function()
--                 finished = true
--             end, function()
--                 finished = true
--             end)
--         end)
--     end
    
--     DoScreenFadeOut(750)
-- 	Wait(750)

    -- RenderScriptCams(false, true, 250, 1, 0)
    -- DestroyCam(cam, false)

	-- cam = nil
-- 	FreezeEntityPosition(playerPed, true)
-- 	SetEntityCoords(playerPed, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
--     if not isNew then  TriggerEvent('skinchanger:loadSkin', skin) end
--     Wait(500)
-- 	DoScreenFadeIn(750)
-- 	Wait(750)
-- 	repeat Wait(200) until not IsScreenFadedOut()
-- 	TriggerServerEvent('esx:onPlayerSpawn')
-- 	TriggerEvent('esx:onPlayerSpawn')
-- 	TriggerEvent('playerSpawned')
-- 	TriggerEvent('esx:restoreLoadout')
--     SetEntityCoords(playerPed, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
-- end)

CharacterSelect = function()
    TriggerEvent('esx:loadingScreenOff')
    ShutdownLoadingScreen()
    -- ShutdownLoadingScreenNui()
    DoScreenFadeOut(300)

    ShutdownLoadingScreenNui(true)
    RequestCollisionAtCoord(0.0, 0.0, 777.0)
    FreezeEntityPosition(PlayerPedId(), true)
    SetNuiFocus(true, true)
    enableCam()
    SetCamFov(cam, 35.0)
    SetFocusEntity(PlayerPedId())
    TriggerServerEvent('qb-multicharacter:server:toggleBucket', true)
    Config.FrameworkFunctions._TSC('qb-multicharacter:server:getCharDatas', function(result)
        Wait(3000)
        DoScreenFadeIn(500)
        SendNUIMessage({
            action = "open",
            chars = result.chars,
            maxValues = result.maxValue,
            MaxCharacterSlots = Config.MaxCharacterSlots,
            tebexStore = Config.TebexStore,
            framework = Config.Framework
        })
    end)

    SetCamUseShallowDofMode(cam, true)
    SetCamNearDof(cam, 0.7)
    SetCamFarDof(cam, 2.3)
    SetCamDofStrength(cam, 1.0)

    while DoesCamExist(cam) do
        SetUseHiDof()
        Citizen.Wait(0)  
    end
end

enableCam = function()
    ped = PlayerPedId()

    local bgCoords = Config.BackgroundLocations[math.random(1, #Config.BackgroundLocations)]

    SetEntityCoords(ped, bgCoords.coords.x, bgCoords.coords.y, bgCoords.coords.z)
    SetEntityHeading(ped, 267.44)

    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)

    if (not DoesCamExist(cam)) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(PlayerPedId()) + 180)
    end
end

RegisterNUICallback('redeemKeycode', function(data, cb)
    Config.FrameworkFunctions._TSC('qb-multicharacter:server:redeemKeycode', function(result)
        if result == true then
            Config.FrameworkFunctions._TSC('qb-multicharacter:server:getCharDatas', function(result)
                SendNUIMessage({
                    action = "open",
                    chars = result.chars,
                    maxValues = result.maxValue,
                    MaxCharacterSlots = Config.MaxCharacterSlots,
                    framework = Config.Framework
                })
            end)
        end
        cb(result)
    end, data.keycode)
end)

local cachedDatas = {}
local cachedSkins = {}

RegisterNUICallback('selectChar', function(data, cb)
    if cachedDatas[data.identifier] ~= nil then
        if cachedSkins[data.identifier] ~= nil then
            TriggerEvent('qb-multicharacter:client:loadCharPed', cachedSkins[data.identifier], cachedDatas[data.identifier].gender)
            cb(true)
        else
            Config.FrameworkFunctions._TSC('qb-multicharacter:server:loadCharPed', function(_result)
                cachedSkins[data.identifier] = _result
                TriggerEvent('qb-multicharacter:client:loadCharPed', _result, cachedDatas[data.identifier].gender)
                cb(true)
            end, data.identifier, cachedDatas[data.identifier].gender)
        end
    else
        Config.FrameworkFunctions._TSC('qb-multicharacter:server:getCharData', function(result)
            cachedDatas[data.identifier] = result
            Config.FrameworkFunctions._TSC('qb-multicharacter:server:loadCharPed', function(_result)
                cachedSkins[data.identifier] = _result
                TriggerEvent('qb-multicharacter:client:loadCharPed', _result, cachedDatas[data.identifier].gender)
                cb(true)
            end, data.identifier, result.gender)
        end, data)
    end
end)

RegisterNUICallback('loadChar', function(data, cb)
    if data.gender == "male" then
        data.gender = 0
    else
        data.gender = 1
    end

    data.skin = false

    Config.FrameworkFunctions.C_LOADPLAYERSKIN(data)
    cb(true)
end)


RegisterNUICallback('createChar', function(payload, cb)
    Config.FrameworkFunctions._TSC('qb-multicharacter:server:createChar', function(__)
        -- Config.FrameworkFunctions._TSC('qb-multicharacter:server:getCharDatas', function(result)
            RenderScriptCams(false, true, 250, 1, 0)
            DestroyCam(cam, false)
            FreezeEntityPosition(PlayerPedId(), false)

            SetNuiFocus(false, false)

            if __ == 0 then
                gender = "m"
            else
                gender = "f"
            end
            if Config.Framework == "esx" then
                local playerPed = PlayerPedId()

	            SetEntityCoords(playerPed, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
                TriggerEvent('skinchanger:loadSkin', Config.Default[gender], function()
                    SetPedAoBlobRendering(playerPed, true)
                    ResetEntityAlpha(playerPed)
                        TriggerEvent('esx_skin:openSaveableMenu', function()
                            finished = true
                        end, function()
                            finished = true
                        end)
                end)

                local playerData = {
                    sex = gender
                }
    
                TriggerEvent('esx:firstloaded', playerData, true, Config.Default[gender])
                TriggerServerEvent('qb-multicharacter:server:giveStarterESX')
                Wait(2000)
            end
            cb(true)
        -- end)
    end, payload)
end)

RegisterNUICallback('playChar', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:toggleBucket', false)
    Config.FrameworkFunctions._TSC('qb-multicharacter:server:playChar', function()
        SetNuiFocus(false, false)
        cb(true)
    end, data.identifier)
end)

RegisterNUICallback('selectGender', function(data, cb)
    data.skin = false
    if data.gender == "male" then
        data.gender = 0
        Config.FrameworkFunctions.C_LOADPLAYERSKIN(data)
    else
        data.gender = 1
        Config.FrameworkFunctions.C_LOADPLAYERSKIN(data)
    end
end)

RegisterNetEvent('qb-multicharacter:client:loadCharPed')
AddEventHandler('qb-multicharacter:client:loadCharPed', function(data, gender)
    data.gender = gender
    Config.FrameworkFunctions.C_LOADPLAYERSKIN(data)
end)

RegisterNetEvent('qb-multicharacter:client:isNew')
AddEventHandler('qb-multicharacter:client:isNew', function()
    DoScreenFadeOut(500)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(PlayerPedId(), false)
    Wait(2000)
    if Config.Framework == "qb" then
        SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    end
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    Wait(500)
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerServerEvent("qb-hotels:sv:createRoom")
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qb-multicharacter:client:spawnLastqb')
AddEventHandler('qb-multicharacter:client:spawnLastqb', function(data, identifier)
    SetEntityCoords(PlayerPedId(), data.pos.x, data.pos.y, data.pos.z)

    DoScreenFadeOut(500)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityCoords(PlayerPedId(), data.pos.x, data.pos.y, data.pos.z)
    Wait(2000)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    Wait(500)
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')

    TriggerServerEvent('qb-multicharacter:server:loadCharPed', identifier, data.gender)
    SetEntityCoords(PlayerPedId(), data.pos.x, data.pos.y, data.pos.z)
end)

RegisterNetEvent('qb-multicharacter:client:removeFreeze')
AddEventHandler('qb-multicharacter:client:removeFreeze', function()
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent('qb-multicharacter:client:spawnESX')
AddEventHandler('qb-multicharacter:client:spawnESX', function(data)
    -- print(json.encode(data.pos))
    -- print(json.encode(data.skin))
    -- print(json.encode(data.gender))


    -- local ped = PlayerPedId()
    -- SetEntityCoords(ped, data.pos.x, data.pos.y, data.pos.z)
    -- RenderScriptCams(false, true, 250, 1, 0)
    -- DestroyCam(cam, false)

    -- FreezeEntityPosition(ped, false)
    -- local skinData = json.decode(data.skin)

    -- if data.gender == 0 or data.gender == "m" then
    --     cmodel = "mp_m_freemode_01"
    -- else
    --     cmodel = "mp_f_freemode_01"
    -- end
    -- print("cmodel", cmodel)
    -- local model = GetHashKey(cmodel)
    -- print("model", model)
    -- print("model requested")
    -- RequestModel(model)
    -- print("model waiting to load")
    -- while not HasModelLoaded(model) do
    --     RequestModel(model)
    --     Citizen.Wait(0)
    -- end
    -- print("model loaded")
    -- SetPlayerModel(PlayerId(), model)
    -- SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)

	-- SetModelAsNoLongerNeeded(model)
    -- print("spawnESX")
    -- if data.skin then
    --     skinData.sex = data.gender
    --     print("skinData", json.encode(skinData))
    --     TriggerEvent('skinchanger:loadSkin', skinData, function()
    --         print("LOADED")
    --         SetEntityVisible(ped, true, 0)
    --     end)
    -- end
end)
