return {
    weaponClasses = weaponClasses,
    
    woundLevels = {
        {
            movementRate = 0.98,
            label = Lang:t('states.irritated'),
        },
        {
            movementRate = 0.96,
            label = Lang:t('states.quite_painful'),
        },
        {
            movementRate = 0.94,
            label = Lang:t('states.painful'),
        },
        {
            movementRate = 0.92,
            label = Lang:t('states.really_painful'),
        },
    },

    bleedingStates = { -- Translate bleeding alerts
        Lang:t('states.little_bleed'),
        Lang:t('states.bleed'),
        Lang:t('states.lot_bleed'),
        Lang:t('states.big_bleed'),
    },

    ---@alias BodyPartKey string

    ---@class BodyPart
    ---@field label string
    ---@field causeLimp boolean

    ---@type table<BodyPartKey, BodyPart>
    bodyParts = {
        HEAD = { label = Lang:t('body.head'), causeLimp = false },
        NECK = { label = Lang:t('body.neck'), causeLimp = false },
        SPINE = { label = Lang:t('body.spine'), causeLimp = true },
        UPPER_BODY = { label = Lang:t('body.upper_body'), causeLimp = false },
        LOWER_BODY = { label = Lang:t('body.lower_body'), causeLimp = true },
        LARM = { label = Lang:t('body.left_arm'), causeLimp = false, },
        LHAND = { label = Lang:t('body.left_hand'), causeLimp = false, },
        LFINGER = { label = Lang:t('body.left_fingers'), causeLimp = false, },
        LLEG = { label = Lang:t('body.left_leg'), causeLimp = true, },
        LFOOT = { label = Lang:t('body.left_foot'), causeLimp = true, },
        RARM = { label = Lang:t('body.right_arm'), causeLimp = false, },
        RHAND = { label = Lang:t('body.right_hand'), causeLimp = false, },
        RFINGER = { label = Lang:t('body.right_fingers'), causeLimp = false, },
        RLEG = { label = Lang:t('body.right_leg'), causeLimp = true, },
        RFOOT = { label = Lang:t('body.right_foot'), causeLimp = true, },
    },

    ---@enum DeathState
    deathState = {
        ALIVE = 1,
        LAST_STAND = 2,
        DEAD = 3,
    },
}
