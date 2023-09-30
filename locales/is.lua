local Translations = {
    error = {
        bled_out = 'Þér hefur blætt út...',
    },
    success = {
        wounds_healed = 'Sár þín hafa verið gróin!',
    },
    info = {
        self_death = 'Sjálfir eða an NPC',
        wep_unknown = 'Óþekktur',
        status = 'Stöðuskoðun',
        healthy = 'Þú ert alveg heilbrigð aftur!',
        pain_message = 'Þinn %{limb} finnst %{severity}',
        many_places = 'Þú ert með verki víða...',
        bleed_alert = 'Þú ert %{bleedstate}',
        revive_player_a = 'Endurlífga leikmann eða sjálfan þig (Aðeins stjórnandi)',
        player_id = 'Leikmaður ID (gæti verið tómt)',
        pain_level = 'Stilltu verkjastig þitt eða leikmanns (Aðeins stjórnandi)',
        kill = 'Drepa leikmann eða sjálfan þig (Aðeins stjórnandi)',
        heal_player_a = 'Lækna leikmann eða sjálfan þig (Aðeins stjórnandi)',
    },
    states = {
        irritated = 'pirruð',
        quite_painful = 'frekar sárt',
        painful = 'sársaukafullt',
        really_painful = 'virkilega sárt',
        little_bleed = 'blæðir smá...',
        bleed = 'blæðingar...',
        lot_bleed = 'blæðir mikið...',
        big_bleed = 'blæðir mjög mikið...',
    },
    body = {
        head = 'Höfuð',
        neck = 'Háls',
        spine = 'Hrygg',
        upper_body = 'Efri líkami',
        lower_body = 'Neðri líkami',
        left_arm = 'Vinstri armur',
        left_hand = 'Vinstri hönd',
        left_fingers = 'Vinstri fingur',
        left_leg = 'Vinstri fótur',
        left_foot = 'Vinstri fótur',
        right_arm = 'Hægri armur',
        right_hand = 'Hægri hönd',
        right_fingers = 'Hægri fingur',
        right_leg = 'Hægri fótur',
        right_foot = 'Hægri fótur',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) er dáinn",
        death_log_message = "%{killername} has killed %{playername} með **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'is' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
