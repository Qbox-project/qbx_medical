local Translations = {
    error = {
        bled_out = 'You have bled out...',
    },
    success = {
        wounds_healed = 'Your wounds have been healed!',
    },
    info = {
        self_death = 'Themselves or an NPC',
        wep_unknown = 'Unknown',
        status = 'Status Check',
        healthy = 'You are completely healthy again!',
        pain_message = 'Your %{limb} feels %{severity}',
        many_places = 'You have pain in many places...',
        bleed_alert = 'You are %{bleedstate}',
        revive_player_a = 'Revive A Player or Yourself (Admin Only)',
        player_id = 'Player ID (may be empty)',
        pain_level = 'Set Yours or A Players Pain Level (Admin Only)',
        kill = 'Kill A Player or Yourself (Admin Only)',
        heal_player_a = 'Heal A Player or Yourself (Admin Only)',
    },
    states = {
        irritated = 'irritated',
        quite_painful = 'quite painful',
        painful = 'painful',
        really_painful = 'really painful',
        little_bleed = 'bleeding a little bit...',
        bleed = 'bleeding...',
        lot_bleed = 'bleeding a lot...',
        big_bleed = 'bleeding very much...',
    },
    body = {
        head = 'Head',
        neck = 'Neck',
        spine = 'Spine',
        upper_body = 'Upper Body',
        lower_body = 'Lower Body',
        left_arm = 'Left Arm',
        left_hand = 'Left Hand',
        left_fingers = 'Left Fingers',
        left_leg = 'Left Leg',
        left_foot = 'Left Foot',
        right_arm = 'Right Arm',
        right_hand = 'Right Hand',
        right_fingers = 'Right Fingers',
        right_leg = 'Right Leg',
        right_foot = 'Right Foot',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) is dead",
        death_log_message = "%{killername} has killed %{playername} with a **%{weaponlabel}** (%{weaponname})",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
