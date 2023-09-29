local Translations = {
    error = {
        bled_out = 'Du bist ausgeblutet...',
    },
    success = {
        wounds_healed = 'Deine Wunden wurden geheilt!',
    },
    info = {
        self_death = 'Er selbst oder ein NPC',
        wep_unknown = 'Unbekannt',
        status = 'Status Prüfung',
        healthy = 'Du bist wieder ganz gesund!',
        pain_message = 'Dein %{limb} fühlt sich %{severity} an',
        many_places = 'Du hast schmerzen an verschiedenen Stellen...',
        bleed_alert = 'Du bist %{bleedstate}',
        revive_player_a = 'Belebe einen Spieler oder dich selbst (Admin Only)',
        player_id = 'Spieler ID (may be empty)',
        pain_level = 'Setzt dein oder eines Spielers schmerzlevel (Admin Only)',
        kill = 'Töte einen Spieler oder dich selbst (Admin Only)',
        heal_player_a = 'Keile einen Spieler oder dich selbst (Admin Only)',
    },
    states = {
        irritated = 'irritiert',
        quite_painful = 'leicht schmerzhaft',
        painful = 'schmerzhaft',
        really_painful = 'sehr schmerzhaft',
        little_bleed = 'wenig blutend...',
        bleed = 'blutend...',
        lot_bleed = 'etwas mehr blutend...',
        big_bleed = 'sehr stark blutend...',
    },
    body = {
        head = 'Kopf',
        neck = 'Nacken',
        spine = 'Wirbelsäule',
        upper_body = 'Oberer Körper',
        lower_body = 'Unterer Körper',
        left_arm = 'Linker Arm',
        left_hand = 'Linke Hand',
        left_fingers = 'Linke Finger',
        left_leg = 'Linkes Bein',
        left_foot = 'Linker Fuß',
        right_arm = 'Rechter Arm',
        right_hand = 'Rechte Hand',
        right_fingers = 'Rechte Finger',
        right_leg = 'Rechtes Bein',
        right_foot = 'Rechter Fuß',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) is gestorben",
        death_log_message = "%{killername} tötete %{playername} mit einer/einem **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
