local Translations = {
    error = {
        bled_out = 'Vykrvácal si...',
    },
    success = {
        wounds_healed = 'Tvoje rany sú zahojené!',
    },
    info = {
        self_death = 'Sami alebo NPC',
        wep_unknown = 'Neznáme',
        status = 'Kontrola stavu',
        healthy = 'Si opäť úplne zdravý!',
        pain_message = 'Tvoje %{limb} cítia %{severity}',
        many_places = 'Máte bolesti na mnohých miestach...',
        bleed_alert = 'Si %{bleedstate}',
        revive_player_a = 'Oživiť seba samého alebo hráča (Len pre Adminov)',
        player_id = 'Hráčove ID (nepovinné)',
        pain_level = 'Nastaviť svoju úroveň bolesti alebo pre hráča (Len pre Adminov)',
        kill = 'Zabiť seba samého alebo hráča (Len pre Adminov)',
        heal_player_a = 'Uzdraviť seba samého alebo hráča (Admin Only)',
    },
    states = {
        irritated = 'podráždený',
        quite_painful = 'trochu bolestivé',
        painful = 'bolestivé',
        really_painful = 'veľmi bolestivé',
        little_bleed = 'menšie krvácanie...',
        bleed = 'krvácanie...',
        lot_bleed = 'veľa krvácanie...',
        big_bleed = 'masívne krvácanie...',
    },
    body = {
        head = 'Hlava',
        neck = 'Krk',
        spine = 'Chrbtica',
        upper_body = 'Horná časť tela',
        lower_body = 'Dolná časť tela',
        left_arm = 'Ľavé Rameno',
        left_hand = 'Ľavá Ruka',
        left_fingers = 'Prsty na Ľavej Ruke',
        left_leg = 'Ľavá noha',
        left_foot = 'Ľavé chodidlo',
        right_arm = 'Pravé rameno',
        right_hand = 'Pravá ruka',
        right_fingers = 'Prsty na Pravej Ruke',
        right_leg = 'Pravá noha',
        right_foot = 'Pravé chodidlo',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) je mrtvý",
        death_log_message = "%{killername} zabil %{playername} s **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'sk' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
