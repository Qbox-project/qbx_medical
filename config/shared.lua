return {
    woundLevels = {
        {
            movementRate = 0.98,
            label = locale('states.irritated'),
        },
        {
            movementRate = 0.96,
            label = locale('states.quite_painful'),
        },
        {
            movementRate = 0.94,
            label = locale('states.painful'),
        },
        {
            movementRate = 0.92,
            label = locale('states.really_painful'),
        },
    },

    bleedingStates = { -- Translate bleeding alerts
        locale('states.little_bleed'),
        locale('states.bleed'),
        locale('states.lot_bleed'),
        locale('states.big_bleed'),
    },

    ---@alias BodyPartKey string

    ---@class BodyPart
    ---@field label string
    ---@field causeLimp boolean

    ---@type table<BodyPartKey, BodyPart>
    bodyParts = {
        HEAD = { label = locale('body.head'), causeLimp = false },
        NECK = { label = locale('body.neck'), causeLimp = false },
        SPINE = { label = locale('body.spine'), causeLimp = true },
        UPPER_BODY = { label = locale('body.upper_body'), causeLimp = false },
        LOWER_BODY = { label = locale('body.lower_body'), causeLimp = true },
        LARM = { label = locale('body.left_arm'), causeLimp = false, },
        LHAND = { label = locale('body.left_hand'), causeLimp = false, },
        LFINGER = { label = locale('body.left_fingers'), causeLimp = false, },
        LLEG = { label = locale('body.left_leg'), causeLimp = true, },
        LFOOT = { label = locale('body.left_foot'), causeLimp = true, },
        RARM = { label = locale('body.right_arm'), causeLimp = false, },
        RHAND = { label = locale('body.right_hand'), causeLimp = false, },
        RFINGER = { label = locale('body.right_fingers'), causeLimp = false, },
        RLEG = { label = locale('body.right_leg'), causeLimp = true, },
        RFOOT = { label = locale('body.right_foot'), causeLimp = true, },
    },

    ---@enum DeathState
    deathState = {
        ALIVE = 1,
        LAST_STAND = 2,
        DEAD = 3,
    },
}