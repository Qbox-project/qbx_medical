local Translations = {
    error = {
        bled_out = 'Sei dissanguato...',
    },
    success = {
        wounds_healed = 'Le tue ferite sono state guarite!',
    },
    info = {
        self_death = 'Se stesso o un NPC',
        wep_unknown = 'Sconosciuto',
        status = 'Verifica stato',
        healthy = 'Sei di completamente in salute!',
        pain_message = 'Hai %{limb} e ti senti %{severity}',
        many_places = 'Hai dolori in molti posti...',
        bleed_alert = 'Sei %{bleedstate}',
        revive_player_a = 'Rianima un giocatore o te stesso (Solo Admin)',
        player_id = 'ID Giocatore (può essere vuoto)',
        pain_level = 'Imposta il tuo o un livello di dolore di un giocatore (Solo Admin)',
        kill = 'Uccidi un giocatore o te stesso (Solo Admin)',
        heal_player_a = 'Cura un giocatore o te stesso (Solo Admin)',
    },
    states = {
        irritated = 'irritato',
        quite_painful = 'abbastanza doloroso',
        painful = 'doloroso',
        really_painful = 'davvero doloroso',
        little_bleed = 'sanguindo un po\'...',
        bleed = 'sanguindo...',
        lot_bleed = 'sanguindo molto...',
        big_bleed = 'sanguindo tantissimo...',
    },
    body = {
        head = 'Testa',
        neck = 'Collo',
        spine = 'Dorso',
        upper_body = 'Torace',
        lower_body = 'Bacino',
        left_arm = 'Braccio sinistro',
        left_hand = 'Mano sinistra',
        left_fingers = 'Dita sinistra',
        left_leg = 'Gamba sinistra',
        left_foot = 'Piede sinistro',
        right_arm = 'Braccio destro',
        right_hand = 'Mano destra',
        right_fingers = 'Dita destra',
        right_leg = 'Gamba destra',
        right_foot = 'Piede destro',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) è morto",
        death_log_message = "%{killername} ha ucciso %{playername} con **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'it' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
