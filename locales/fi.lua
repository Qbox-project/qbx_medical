local Translations = {
    error = {
        bled_out = 'Olet vuotanut kuiviin...',
    },
    success = {
        wounds_healed = 'Haavasi on hoidettu!',
    },
    info = {
        self_death = 'Itsemurha tai NPC-tappo',
        wep_unknown = 'Tuntematon',
        status = 'Voinnin tarkastus',
        healthy = 'Olet taas täysin terve!',
        pain_message = 'Sinun %{limb} tuntuu %{severity}',
        many_places = 'Tunnet kipua monessa paikassa..',
        bleed_alert = 'Vuodat %{bleedstate}',
        revive_player_a = 'Elvytä itsesi tai pelaaja',
        player_id = 'Pelaajan ID(Nosta itsesi jättämällä tyhjäksi)',
        pain_level = 'Aseta sinun tai muun pelaajan kiputaso',
        kill = 'Tapa itsesi tai muu pelaaja',
        heal_player_a = 'Hoida itsesi tai muu pelaaja',
    },
    states = {
        irritated = 'ärtynyt',
        quite_painful = 'hieman kipeä',
        painful = 'kipeä',
        really_painful = 'todella kipeä',
        little_bleed = 'hieman verta',
        bleed = 'verta',
        lot_bleed = 'paljon verta',
        big_bleed = 'todella paljon verta',
    },
    body = {
        head = 'Pää',
        neck = 'Niska',
        spine = 'Selkäranka',
        upper_body = 'Yläkroppa',
        lower_body = 'Alakroppa',
        left_arm = 'Vasen käsivarsi',
        left_hand = 'Oikea käsi',
        left_fingers = 'Vasemmat sormet',
        left_leg = 'Vasen jalka',
        left_foot = 'Vasen jalkapöytä',
        right_arm = 'Oikea käsivarsi',
        right_hand = 'Oikea käsi',
        right_fingers = 'Oikeat sormet',
        right_leg = 'Oikea jalka',
        right_foot = 'Oikea jalkapöytä',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) on kuollut",
        death_log_message = "%{killername} on tappanut %{playername} välineellä **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'fi' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
