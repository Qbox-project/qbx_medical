local Translations = {
    error = {
        bled_out = 'Du har blödit ut...',
    },
    success = {
        wounds_healed = 'Dina skador har blivit behandlade!',
    },
    info = {
        self_death = 'Själva eller en npc',
        wep_unknown = 'Okänd',
        status = 'Statuscheck',
        healthy = 'Du är helt frisk igen!',
        pain_message = '%{severity} i %{limb}',
        many_places = 'Du har smärta på många ställen...',
        bleed_alert = 'Du %{bleedstate}',
        revive_player_a = 'Återuppliva en spelare eller dig själv (Admin Only)',
        player_id = 'Spelar-ID (kan vara tomt)',
        pain_level = 'Ställ in dina eller en spelare smärtnivå (Admin Only)',
        kill = 'Döda en spelare eller dig själv (Admin Only)',
        heal_player_a = 'Läk en spelare eller dig själv (Admin Only)',
    },
    states = {
        irritated = 'Måttlig Smärta',
        quite_painful = 'Medelsvår Smärta',
        painful = 'Svår Smärta',
        really_painful = 'Outhärdlig Smärta',
        little_bleed = 'blöder lite..',
        bleed = 'blöder..',
        lot_bleed = 'blöder mycket..',
        big_bleed = 'blöder väldigt mycket..',
    },
    body = {
        head = 'Huvud',
        neck = 'Nacke',
        spine = 'Rygg',
        upper_body = 'Övrekroppen',
        lower_body = 'Underkroppen',
        left_arm = 'Vänster arm',
        left_hand = 'Vänster hand',
        left_fingers = 'Vänster fingrar',
        left_leg = 'Vänster ben',
        left_foot = 'Vänster fot',
        right_arm = 'Höger arm',
        right_hand = 'Höger hand',
        right_fingers = 'Höger fingrar',
        right_leg = 'Höger ben',
        right_foot = 'Höger fot',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) är död",
        death_log_message = "%{killername} har dödat %{playername} med en **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'sv' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end