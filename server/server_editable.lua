ESX, QBCore = nil, nil

-- Functions

local function initializeFrameworkDependentComponents()
    if Config.Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "qb" then
        QBCore = exports["qb-core"]:GetCoreObject()
    end
end

-- bi saniye bekle 

CreateThread(function()
    local resourceState = GetResourceState("qb-spawn")
    if Config.useQBSpawn then
        if resourceState ~= "started" then
            print("^1[qb-multicharacter]^7 qb-spawn resource is not started. qb-spawn has been started automatically if resource is exists.")
            StartResource("qb-spawn")
        end
    else
        if resourceState == "started" then
            print("^1[qb-multicharacter]^7 qb-spawn resource is started. qb-spawn has been stopped automatically if resource is exists.")
            StopResource("qb-spawn")
        end
    end
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

function getPlayerIdentifier(src)
    --print("identifier fetch test")
    if Config.Framework == "esx" then
        return ESX.GetIdentifier(src)
    else
        return QBCore.Functions.GetIdentifier(src, 'license')
    end
end

--resourcestopped
AddEventHandler("onResourceStop", function(resource)
    local src = source
    if resource == GetCurrentResourceName() then
        TriggerEvent("esx:playerLogout", src)

    end
end)


CreateThread(function()
    Wait(1000)
    if Config.Framework == "esx" then
        ESX.RegisterCommand("logout", "admin", function(xPlayer, args, _)

            local src = xPlayer.source
            TriggerEvent("esx:playerLogout", src)
            ESX.Players[src] = nil
            local license = getPlayerIdentifier(src)
            -- print("license: " .. license)
            SetPlayerRoutingBucket(src,math.random(99,999))
            local plyChars = {}
            local availableSlots = {}
        
            if Config.LockedSlotsIsPaid and not Config.LockedSlotsAllowedPlayers[license] then
                local unlockedSlots = MySQL.query.await("SELECT * FROM 0r_unlockedslots WHERE license = ?", { license })
                if unlockedSlots[1] ~= nil then
                    -- print("no nil found something")
                    availableSlots = json.decode(unlockedSlots[1].slots)
                end
            end
            MySQL.query('SELECT * FROM users WHERE identifier LIKE ?', { "%"..license }, function(result)
                -- print("result: " .. json.encode(result))
                for i = 1, (#result), 1 do
                    local accounts = json.decode(result[i].accounts)
                    local job, grade = result[i].job or "unemployed", tostring(result[i].job_grade)
                    if ESX.DoesJobExist(job, grade) then
                        grade = job ~= "unemployed" and ESX.Jobs[job].grades[grade].label or ""
                        job = ESX.Jobs[job].label
                    else
                        job = ESX.Jobs["unemployed"].label
                        grade = ""
                    end -- Example identifier
                    local num = string.match(result[i].identifier, Config.Prefix.."(%d+)") -- Extract number after "char"
                    --print(147, num)
                    if num then
                        result[i].cid = tonumber(num) -- Convert to number and assign to cid
                    end
                   -- print(result[i].cid)
                    result[i].citizenid = result[i].cid
                    result[i].charinfo = {
                        citizenid = i,
                        firstname = result[i].firstname,
                        lastname = result[i].lastname,
                        birthdate = result[i].dateofbirth,
                        sex = result[i].sex,
                        nationality = "N/A",
                    }
                    result[i].money = {cash = accounts.money, bank = accounts.bank}
                    result[i].job = {
                        label = job,
                        grade = {
                            name = grade,
                        },
                    }
                    plyChars[#plyChars + 1] = result[i]
                end
                TriggerClientEvent("qb-multicharacter:client:setChars", src, plyChars, availableSlots)
            end)
        end, true, {})
        
        ESX.RegisterCommand("closeNUI", "user", function(xPlayer, args, _)
            TriggerClientEvent('qb-multicharacter:client:closeNUI', xPlayer.source)
        end, true, {})
    elseif Config.Framework == "qb" then
    
    
        QBCore.Commands.Add("ahmadmohmmedsalem60890", "Logout to character screen.", {}, false, function(source)
            local src = source
            local license = QBCore.Functions.GetIdentifier(src, 'license')
            SetPlayerRoutingBucket(source,math.random(99,999))
            local plyChars = {}
            local availableSlots = {}
        
            if Config.LockedSlotsIsPaid and not Config.LockedSlotsAllowedPlayers[license] then
                local unlockedSlots = MySQL.query.await("SELECT * FROM 0r_unlockedslots WHERE license = ?", { license })
                if unlockedSlots[1] ~= nil then
                    -- print("no nil found something")
                    availableSlots = json.decode(unlockedSlots[1].slots)
                end
            end
            local player = QBCore.Functions.GetPlayer(src)
            QBCore.Player.Logout(player)
            MySQL.query('SELECT * FROM players WHERE license = ?', { license }, function(result)
                for i = 1, (#result), 1 do
                    result[i].charinfo = json.decode(result[i].charinfo)
                    result[i].money = json.decode(result[i].money)
                    result[i].job = json.decode(result[i].job)
                    plyChars[#plyChars + 1] = result[i]
                end
                TriggerClientEvent("qb-multicharacter:client:setChars", src, plyChars, availableSlots)
            end)
        end, "admin")
    
        QBCore.Commands.Add("closeNUI", "Close Multichar UI", {}, false, function(source)
            local src = source
            TriggerClientEvent('qb-multicharacter:client:closeNUI', src)
        end)
    end
end)

