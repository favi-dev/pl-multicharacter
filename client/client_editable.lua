ESX, QBCore = nil, nil

-- Functions

local function initializeFrameworkDependentComponents()
    if Config.Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "qb" then
        QBCore = exports["qb-core"]:GetCoreObject()
    end
end


CreateThread(function()
    local qbResourceState = GetResourceState("qb-core")
    if qbResourceState == "started" then
        Config.Framework = "qb"
        print("^2[qb-multicharacter]^7 Using QBCore Framework")
    else
        Config.Framework = "esx"
        print("^2[qb-multicharacter]^7 Using ESX Framework")
    end
    initializeFrameworkDependentComponents()
end)
