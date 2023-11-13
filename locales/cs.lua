local Translations = {
    error = {
        bled_out = 'Vykrvácel(a) jsi...',
    },
    success = {
        wounds_healed = 'Tvá zranění byla uzdravena!',
    },
    info = {
        self_death = 'Sami sebe nebo NPC',
        wep_unknown = 'Neznámý',
        status = 'Kontrola stavu',
        healthy = 'Jsi opět zcela zdravý(á)!',
        pain_message = 'Tvůj %{limb} cítí %{severity}',
        many_places = 'Máš bolest na mnoha místech...',
        bleed_alert = 'Krvácíš %{bleedstate}',
        revive_player_a = 'Oživit hráče nebo sebe (pouze pro administrátory)',
        player_id = 'ID hráče (může být prázdné)',
        pain_level = 'Nastavit úroveň bolesti pro sebe nebo hráče (pouze pro administrátory)',
        kill = 'Zabít hráče nebo sebe (pouze pro administrátory)',
        heal_player_a = 'Uzdravit hráče nebo sebe (pouze pro administrátory)',
    },
    states = {
        irritated = 'podrážděný(á)',
        quite_painful = 'docela bolestivý(á)',
        painful = 'bolestivý(á)',
        really_painful = 'opravdu bolestivý(á)',
        little_bleed = 'krev trochu uniká...',
        bleed = 'krev uniká...',
        lot_bleed = 'krev uniká hodně...',
        big_bleed = 'krev uniká velmi mnoho...',
    },
    body = {
        head = 'Hlava',
        neck = 'Krk',
        spine = 'Hřbet',
        upper_body = 'Horní část těla',
        lower_body = 'Dolní část těla',
        left_arm = 'Levá ruka',
        left_hand = 'Levá ruka',
        left_fingers = 'Levé prsty',
        left_leg = 'Levá noha',
        left_foot = 'Levá noha',
        right_arm = 'Pravá ruka',
        right_hand = 'Pravá ruka',
        right_fingers = 'Pravé prsty',
        right_leg = 'Pravá noha',
        right_foot = 'Pravá noha',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) je mrtvý(á)",
        death_log_message = "%{killername} zabil(a) %{playername} s **%{weaponlabel}** (%{weaponname})",
    }
}


if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic