---@enum WeaponClass
local weaponClasses = { -- Define gta weapon classe numbers
    SMALL_CALIBER = 1,
    MEDIUM_CALIBER = 2,
    HIGH_CALIBER = 3,
    SHOTGUN = 4,
    CUTTING = 5,
    LIGHT_IMPACT = 6,
    HEAVY_IMPACT = 7,
    EXPLOSIVE = 8,
    FIRE = 9,
    SUFFOCATING = 10,
    OTHER = 11,
    WILDLIFE = 12,
    NONE = 13,
}

return {
    weaponClasses = weaponClasses,
    fadeOutTimer = 2, -- How many bleed ticks occur before fadeout happens
    blackoutTimer = 10, -- How many bleed ticks occur before blacking out
    bleedDamageTimer = 8, -- The base damage that is multiplied by bleed level everytime a bleed tick occurs
    advanceBleedTimer = 10, -- How many bleed ticks occur before bleed level increases
    bleedTickRate = 30, -- How much time, in seconds, between bleed ticks
    bleedMovementTick = 10, -- How many seconds is taken away from the bleed tick rate if the player is walking, jogging, or sprinting
    bleedMovementAdvance = 3, -- How much time moving while bleeding adds
    armorDamage = 5, -- Minumum damage done to armor before checking for injuries
    messageTimer = 12, -- How long it will take to display limb/bleed message
    alertShowInfo = 2, -- How many injuries a player must have before being alerted about them
    headInjuryTimer = 30, -- How much time, in seconds, do head injury effects chance occur
    armInjuryTimer = 30, -- How much time, in seconds, do arm injury effects chance occur
    legInjuryTimer = 15, -- How much time, in seconds, do leg injury effects chance occur
    headInjuryChance = 25, -- The chance, in percent, that head injury side-effects get applied
    legInjuryChance = { -- The chance, in percent, that leg injury side-effects get applied
        running = 50,
        walking = 15,
    },
    laststandReviveInterval = 360,
    deathTime = 300,

    forceInjury = 35, -- Maximum amount of damage a player can take before limb damage & effects are forced to occur
    healthDamage = 5, -- Minimum damage done to health before checking for injuries
    maxInjuryChanceMulti = 3, -- Maximum chance of an injury from damage above healthDamage
    forceInjuryWeapons = { -- Define which weapons will always cause injuries
        [weaponClasses.HIGH_CALIBER] = true,
        [weaponClasses.HEAVY_IMPACT] = true,
        [weaponClasses.EXPLOSIVE] = true,
    },

    criticalAreas = { -- Define body areas that will always cause bleeding if wearing armor or not
        UPPER_BODY = { armored = false },
        LOWER_BODY = { armored = true },
        SPINE = { armored = true },
    },

    ---@class StaggerArea Defined body areas that will always cause staggering if wearing armor or not
    ---@field armored boolean
    ---@field major number
    ---@field minor number
    staggerAreas = {
        SPINE = { armored = true, major = 60, minor = 30 },
        UPPER_BODY = { armored = false, major = 60, minor = 30 },
        LLEG = { armored = true, major = 100, minor = 85 },
        RLEG = { armored = true, major = 100, minor = 85 },
        LFOOT = { armored = true, major = 100, minor = 100 },
        RFOOT = { armored = true, major = 100, minor = 100 },
    },

    majorArmoredBleedChance = 45, -- The chance, in percent, that a player will get a bleed effect when taking heavy damage while wearing armor
    minorInjurWeapons = { -- Define which weapons cause small injuries
        [weaponClasses.SMALL_CALIBER] = true,
        [weaponClasses.MEDIUM_CALIBER] = true,
        [weaponClasses.CUTTING] = true,
        [weaponClasses.WILDLIFE] = true,
        [weaponClasses.OTHER] = true,
        [weaponClasses.LIGHT_IMPACT] = true,
    },

    majorInjurWeapons = { -- Define which weapons cause large injuries
        [weaponClasses.HIGH_CALIBER] = true,
        [weaponClasses.HEAVY_IMPACT] = true,
        [weaponClasses.SHOTGUN] = true,
        [weaponClasses.EXPLOSIVE] = true,
    },

    damageMinorToMajor = 35, -- How much damage would have to be applied for a minor weapon to be considered a major damage event. Put this at 100 if you want to disable it
    alwaysBleedChanceWeapons = { -- Define which weapons will always cause bleedign
        [weaponClasses.SMALL_CALIBER] = true,
        [weaponClasses.MEDIUM_CALIBER] = true,
        [weaponClasses.CUTTING] = true,
        [weaponClasses.WILDLIFE] = false,
    },

    alwaysBleedChance = 70, -- Set the chance out of 100 that if a player is hit with a weapon, that also has a random chance, it will cause bleeding

    ---@type table<number, string>
    bones = { -- Correspond bone hash numbers to their label
        [0]     = 'NONE',
        [31085] = 'HEAD',
        [31086] = 'HEAD',
        [39317] = 'NECK',
        [57597] = 'SPINE',
        [23553] = 'SPINE',
        [24816] = 'SPINE',
        [24817] = 'SPINE',
        [24818] = 'SPINE',
        [10706] = 'UPPER_BODY',
        [64729] = 'UPPER_BODY',
        [11816] = 'LOWER_BODY',
        [45509] = 'LARM',
        [61163] = 'LARM',
        [18905] = 'LHAND',
        [4089]  = 'LFINGER',
        [4090]  = 'LFINGER',
        [4137]  = 'LFINGER',
        [4138]  = 'LFINGER',
        [4153]  = 'LFINGER',
        [4154]  = 'LFINGER',
        [4169]  = 'LFINGER',
        [4170]  = 'LFINGER',
        [4185]  = 'LFINGER',
        [4186]  = 'LFINGER',
        [26610] = 'LFINGER',
        [26611] = 'LFINGER',
        [26612] = 'LFINGER',
        [26613] = 'LFINGER',
        [26614] = 'LFINGER',
        [58271] = 'LLEG',
        [63931] = 'LLEG',
        [2108]  = 'LFOOT',
        [14201] = 'LFOOT',
        [40269] = 'RARM',
        [28252] = 'RARM',
        [57005] = 'RHAND',
        [58866] = 'RFINGER',
        [58867] = 'RFINGER',
        [58868] = 'RFINGER',
        [58869] = 'RFINGER',
        [58870] = 'RFINGER',
        [64016] = 'RFINGER',
        [64017] = 'RFINGER',
        [64064] = 'RFINGER',
        [64065] = 'RFINGER',
        [64080] = 'RFINGER',
        [64081] = 'RFINGER',
        [64096] = 'RFINGER',
        [64097] = 'RFINGER',
        [64112] = 'RFINGER',
        [64113] = 'RFINGER',
        [36864] = 'RLEG',
        [51826] = 'RLEG',
        [20781] = 'RFOOT',
        [52301] = 'RFOOT',
    },

    weapons = { -- Correspond weapon names to their class number
        [`WEAPON_STUNGUN`] = weaponClasses.NONE,
        [`WEAPON_STUNGUN_MP`] = weaponClasses.NONE,
        --[[ Small Caliber ]] --
        [`WEAPON_PISTOL`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_COMBATPISTOL`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_APPISTOL`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_COMBATPDW`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_MACHINEPISTOL`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_MICROSMG`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_MINISMG`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_PISTOL_MK2`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_SNSPISTOL`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_SNSPISTOL_MK2`] = weaponClasses.SMALL_CALIBER,
        [`WEAPON_VINTAGEPISTOL`] = weaponClasses.SMALL_CALIBER,

        --[[ Medium Caliber ]] --
        [`WEAPON_ADVANCEDRIFLE`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_ASSAULTSMG`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_BULLPUPRIFLE`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_BULLPUPRIFLE_MK2`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_CARBINERIFLE`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_CARBINERIFLE_MK2`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_COMPACTRIFLE`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_DOUBLEACTION`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_GUSENBERG`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_HEAVYPISTOL`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_MARKSMANPISTOL`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_PISTOL50`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_REVOLVER`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_REVOLVER_MK2`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_SMG`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_SMG_MK2`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_SPECIALCARBINE`] = weaponClasses.MEDIUM_CALIBER,
        [`WEAPON_SPECIALCARBINE_MK2`] = weaponClasses.MEDIUM_CALIBER,

        --[[ High Caliber ]] --
        [`WEAPON_ASSAULTRIFLE`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_ASSAULTRIFLE_MK2`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_COMBATMG`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_COMBATMG_MK2`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_HEAVYSNIPER`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_HEAVYSNIPER_MK2`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_MARKSMANRIFLE`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_MARKSMANRIFLE_MK2`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_MG`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_MINIGUN`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_MUSKET`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_RAILGUN`] = weaponClasses.HIGH_CALIBER,
        [`WEAPON_HEAVYRIFLE`] = weaponClasses.HIGH_CALIBER,

        --[[ Shotguns ]] --
        [`WEAPON_ASSAULTSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_BULLUPSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_DBSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_HEAVYSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_PUMPSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_PUMPSHOTGUN_MK2`] = weaponClasses.SHOTGUN,
        [`WEAPON_SAWNOFFSHOTGUN`] = weaponClasses.SHOTGUN,
        [`WEAPON_SWEEPERSHOTGUN`] = weaponClasses.SHOTGUN,

        --[[ Animals ]] --
        [`WEAPON_ANIMAL`] = weaponClasses.WILDLIFE, -- Animal
        [`WEAPON_COUGAR`] = weaponClasses.WILDLIFE, -- Cougar
        [`WEAPON_BARBED_WIRE`] = weaponClasses.WILDLIFE, -- Barbed Wire

        --[[ Cutting Weapons ]] --
        [`WEAPON_BATTLEAXE`] = weaponClasses.CUTTING,
        [`WEAPON_BOTTLE`] = weaponClasses.CUTTING,
        [`WEAPON_DAGGER`] = weaponClasses.CUTTING,
        [`WEAPON_HATCHET`] = weaponClasses.CUTTING,
        [`WEAPON_KNIFE`] = weaponClasses.CUTTING,
        [`WEAPON_MACHETE`] = weaponClasses.CUTTING,
        [`WEAPON_SWITCHBLADE`] = weaponClasses.CUTTING,

        --[[ Light Impact ]] --
        [`WEAPON_KNUCKLE`] = weaponClasses.LIGHT_IMPACT,

        --[[ Heavy Impact ]] --
        [`WEAPON_BAT`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_CROWBAR`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_FIREEXTINGUISHER`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_FIRWORK`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_GOLFLCUB`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_HAMMER`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_PETROLCAN`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_POOLCUE`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_WRENCH`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_RAMMED_BY_CAR`] = weaponClasses.HEAVY_IMPACT,
        [`WEAPON_RUN_OVER_BY_CAR`] = weaponClasses.HEAVY_IMPACT,

        --[[ Explosives ]] --
        [`WEAPON_EXPLOSION`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_GRENADE`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_COMPACTLAUNCHER`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_HOMINGLAUNCHER`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_PIPEBOMB`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_PROXMINE`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_RPG`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_STICKYBOMB`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_HELI_CRASH`] = weaponClasses.EXPLOSIVE,
        [`WEAPON_EMPLAUNCHER`] = weaponClasses.EXPLOSIVE,

        --[[ Other ]] --
        [`WEAPON_FALL`] = weaponClasses.OTHER, -- Fall
        [`WEAPON_HIT_BY_WATER_CANNON`] = weaponClasses.OTHER, -- Water Cannon

        --[[ Fire ]] --
        [`WEAPON_ELECTRIC_FENCE`] = weaponClasses.FIRE,
        [`WEAPON_FIRE`] = weaponClasses.FIRE,
        [`WEAPON_MOLOTOV`] = weaponClasses.FIRE,
        [`WEAPON_FLARE`] = weaponClasses.FIRE,
        [`WEAPON_FLAREGUN`] = weaponClasses.FIRE,

        --[[ Suffocate ]] --
        [`WEAPON_DROWNING`] = weaponClasses.SUFFOCATING, -- Drowning
        [`WEAPON_DROWNING_IN_VEHICLE`] = weaponClasses.SUFFOCATING, -- Drowning Veh
        [`WEAPON_EXHAUSTION`] = weaponClasses.SUFFOCATING, -- Exhaust
        [`WEAPON_BZGAS`] = weaponClasses.SUFFOCATING,
        [`WEAPON_SMOKEGRENADE`] = weaponClasses.SUFFOCATING,
    },
}
