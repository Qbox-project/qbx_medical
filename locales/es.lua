local Translations = {
    error = {
        bled_out = 'Te desangraste...',
    },
    success = {
        wounds_healed = '¡Tus heridas han sido curadas!',
    },
    info = {
        self_death = 'Suicidio o un NPC',
        wep_unknown = 'Desconocido',
        status = 'Revisión de estado',
        healthy = 'Ya estás saludable de nuevo',
        pain_message = 'Sientes %{severity} en %{limb}',
        many_places = 'Te duele todo...',
        bleed_alert = 'Estás %{bleedstate}',
        revive_player_a = 'Reanimar jugador (Admin)',
        player_id = 'ID de jugador (puede quedar vacio)',
        pain_level = 'Establecer nivel de dolor (Admin)',
        kill = 'Matar un jugador o a ti mismo (Admin)',
        heal_player_a = 'Curar un jugador o a ti mismo (Admin)',
    },
    states = {
        irritated = 'molestias',
        quite_painful = 'mucho dolor',
        painful = 'dolor',
        really_painful = 'dolor insoportable',
        little_bleed = 'sangrando un poco...',
        bleed = 'sangrando...',
        lot_bleed = 'sangrando mucho...',
        big_bleed = 'desangrándote gravemente...',
    },
    body = {
        head = 'cabeza',
        neck = 'cuello',
        spine = 'columna',
        upper_body = 'parte superior',
        lower_body = 'parte inferior',
        left_arm = 'brazo izquierdo',
        left_hand = 'mano izquierda',
        left_fingers = 'dedos izquierdos',
        left_leg = 'pierna izquierda',
        left_foot = 'pie izquierdo',
        right_arm = 'brazo derecho',
        right_hand = 'mano derecha',
        right_fingers = 'dedos derechos',
        right_leg = 'pierna derecha',
        right_foot = 'pie derecho',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) está muerto",
        death_log_message = "%{killername} ha matado %{playername} con **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
