Config = {
    Framework = nil, -- dont touch auto framework selector has been activated.
    MaxCharacters = 4,
    LockedSlots = {

    },
    UseApartment = false,
    CanDeleteCharacters = true,
    Prefix = "char",-- for esx
    LockedSlotsIsPaid = true,
    LockedSlotsAllowedPlayers = {
        ["license:1234567890"] = true
    },
    RandomPeds = {
        'mp_m_freemode_01',
        'mp_f_freemode_01',
    },
    useQBSpawn = false,
    SkipSelection = true,
    -- SKIN MENUS


    
    SkinMenus = {
        ['skinchanger'] = {
            ['esx_skin'] = {event = 'esx_skin:openSaveableMenu', use = true},
            ['VexCreator'] = {event = 'VexCreator:loadCreator', use = false},
            ['cui_character'] = {event = 'cui_character:open', use = false},
            ['example_resource'] = {exports = 'exports.example:Creator', event = nil, use = false}, -- example support exports
        },
        ['illeniumappearance'] = {},
        ['fivemappearance'] = {},
        ['qb-clothing'] = {
            ['qb-clothing'] = { event = 'qb-clothing:client:openMenu', use = true},
        },
    },
    -- compatibility with IlleniumStudios version of fivemappearance for qbcore
    fivemappearanceConfig = {
        ped = true, headBlend = true, faceFeatures = true, headOverlays = true, components = true, componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true }, props = true, propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true }, tattoos = true, enableExit = true,
    },

    skinsupport = {
        ['illenium-appearance'] = true,
        ['skinchanger'] = true,
        ['qb-clothing'] = true,

    },



    PedCoords = vector4(-796.82, 337.45, 220.44, 91.33),
    HiddenCoords = vector4(-796.27, 328.15, 220.44, 91.33),
    DefaultSpawn = vector4(-309.07, -1041.74, 66.52, 69.4),
    randomPedAnimations = {
        [1] = {
            type = "sceneario",
            anim = "WORLD_HUMAN_GUARD_STAND",
        },

        -- [4] = {
        --     type = "anim",
        --     anim = "anim@mp_player_intselfiethe_bird",
        --     dict = "idle_a"
        -- },
        -- [5] = {
        --     --move_m@joggern
        --     type = "anim",
        --     anim = "move_m@jogger",
        --     dict = "idle"
        -- }
        
    },
    SpawnLocations = {
        [1] = {
            title = "LSPD Department",
            description = "The central headquarters of the Los Santos Police Department, committed to maintaining law and order with dedication and integrity.",
            coords = vector4(412.285, -976.30, 29.41, 90.0),
        },
    },
}

Config.skin = 'none' -- do not replace this. this resource automatically detect your skin resourc if its supported.
local skincount = {}
local lowpriority = 'skinchanger' -- for people who started 2 skin resource :facepalm
for skin,_ in pairs(Config.skinsupport) do
    -- print(GetResourceState(skin), skin)
	if GetResourceState(skin) == 'started' or GetResourceState(skin) == 'starting' then -- autodetect skin resource
		-- print("skin selected")
        Config.skin = skin
		table.insert(skincount,skin)
	end
end
if Config.skin == 'none' then
	warn('YOU DONT HAVE ANY SUPPORTED SKIN RESOURCE')
end
if #skincount > 1 then
	warn('you have multiple skin resource started. start only 1 supported skin resource. ex. illenium-appearance, skinchanger cannot be started at the same time!')
	for k,skin in pairs(skincount) do
		if lowpriority ~= skin then
            -- print(skin, "selected skin")
			Config.skin = skin
		end
	end
	warn('USING '..Config.skin..' Anyway')
end

--- do not edit
Config.SkinMenu = {}
for resource,v in pairs(Config.SkinMenus) do
	if resource == Config.skin then
		for k,v in pairs(v) do
			if v.use then
				Config.SkinMenu[resource] = {event = v.event or false, exports = v.exports or false}
			end
		end
	end
end


OpenSkinMenu = function(data)
    TriggerEvent("esx_skin:openSaveableMenu", data) -- for ESX skin
end

DefaultSkin = {
    [0] = {
        mom = 43,
        dad = 29,
        face_md_weight = 61,
        skin_md_weight = 27,
        nose_1 = -5,
        nose_2 = 6,
        nose_3 = 5,
        nose_4 = 8,
        nose_5 = 10,
        nose_6 = 0,
        cheeks_1 = 2,
        cheeks_2 = -10,
        cheeks_3 = 6,
        lip_thickness = -2,
        jaw_1 = 0,
        jaw_2 = 0,
        chin_1 = 0,
        chin_2 = 0,
        chin_13 = 0,
        chin_4 = 0,
        neck_thickness = 0,
        hair_1 = 76,
        hair_2 = 0,
        hair_color_1 = 61,
        hair_color_2 = 29,
        tshirt_1 = 4,
        tshirt_2 = 2,
        torso_1 = 23,
        torso_2 = 2,
        decals_1 = 0,
        decals_2 = 0,
        arms = 1,
        arms_2 = 0,
        pants_1 = 28,
        pants_2 = 3,
        shoes_1 = 70,
        shoes_2 = 2,
        mask_1 = 0,
        mask_2 = 0,
        bproof_1 = 0,
        bproof_2 = 0,
        chain_1 = 22,
        chain_2 = 2,
        helmet_1 = -1,
        helmet_2 = 0,
        glasses_1 = 0,
        glasses_2 = 0,
        watches_1 = -1,
        watches_2 = 0,
        bracelets_1 = -1,
        bracelets_2 = 0,
        bags_1 = 0,
        bags_2 = 0,
        eye_color = 0,
        eye_squint = 0,
        eyebrows_2 = 0,
        eyebrows_1 = 0,
        eyebrows_3 = 0,
        eyebrows_4 = 0,
        eyebrows_5 = 0,
        eyebrows_6 = 0,
        makeup_1 = 0,
        makeup_2 = 0,
        makeup_3 = 0,
        makeup_4 = 0,
        lipstick_1 = 0,
        lipstick_2 = 0,
        lipstick_3 = 0,
        lipstick_4 = 0,
        ears_1 = -1,
        ears_2 = 0,
        chest_1 = 0,
        chest_2 = 0,
        chest_3 = 0,
        bodyb_1 = -1,
        bodyb_2 = 0,
        bodyb_3 = -1,
        bodyb_4 = 0,
        age_1 = 0,
        age_2 = 0,
        blemishes_1 = 0,
        blemishes_2 = 0,
        blush_1 = 0,
        blush_2 = 0,
        blush_3 = 0,
        complexion_1 = 0,
        complexion_2 = 0,
        sun_1 = 0,
        sun_2 = 0,
        moles_1 = 0,
        moles_2 = 0,
        beard_1 = 11,
        beard_2 = 10,
        beard_3 = 0,
        beard_4 = 0,
    },
    [1] = {
        mom = 28,
        dad = 6,
        face_md_weight = 63,
        skin_md_weight = 60,
        nose_1 = -10,
        nose_2 = 4,
        nose_3 = 5,
        nose_4 = 0,
        nose_5 = 0,
        nose_6 = 0,
        cheeks_1 = 0,
        cheeks_2 = 0,
        cheeks_3 = 0,
        lip_thickness = 0,
        jaw_1 = 0,
        jaw_2 = 0,
        chin_1 = -10,
        chin_2 = 10,
        chin_13 = -10,
        chin_4 = 0,
        neck_thickness = -5,
        hair_1 = 43,
        hair_2 = 0,
        hair_color_1 = 29,
        hair_color_2 = 35,
        tshirt_1 = 111,
        tshirt_2 = 5,
        torso_1 = 25,
        torso_2 = 2,
        decals_1 = 0,
        decals_2 = 0,
        arms = 3,
        arms_2 = 0,
        pants_1 = 12,
        pants_2 = 2,
        shoes_1 = 20,
        shoes_2 = 10,
        mask_1 = 0,
        mask_2 = 0,
        bproof_1 = 0,
        bproof_2 = 0,
        chain_1 = 85,
        chain_2 = 0,
        helmet_1 = -1,
        helmet_2 = 0,
        glasses_1 = 33,
        glasses_2 = 12,
        watches_1 = -1,
        watches_2 = 0,
        bracelets_1 = -1,
        bracelets_2 = 0,
        bags_1 = 0,
        bags_2 = 0,
        eye_color = 8,
        eye_squint = -6,
        eyebrows_2 = 7,
        eyebrows_1 = 32,
        eyebrows_3 = 52,
        eyebrows_4 = 9,
        eyebrows_5 = -5,
        eyebrows_6 = -8,
        makeup_1 = 0,
        makeup_2 = 0,
        makeup_3 = 0,
        makeup_4 = 0,
        lipstick_1 = 0,
        lipstick_2 = 0,
        lipstick_3 = 0,
        lipstick_4 = 0,
        ears_1 = -1,
        ears_2 = 0,
        chest_1 = 0,
        chest_2 = 0,
        chest_3 = 0,
        bodyb_1 = -1,
        bodyb_2 = 0,
        bodyb_3 = -1,
        bodyb_4 = 0,
        age_1 = 0,
        age_2 = 0,
        blemishes_1 = 0,
        blemishes_2 = 0,
        blush_1 = 0,
        blush_2 = 0,
        blush_3 = 0,
        complexion_1 = 0,
        complexion_2 = 0,
        sun_1 = 0,
        sun_2 = 0,
        moles_1 = 12,
        moles_2 = 8,
        beard_1 = 0,
        beard_2 = 0,
        beard_3 = 0,
        beard_4 = 0,
    },
}