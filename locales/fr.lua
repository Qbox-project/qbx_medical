local Translations = {
    error = {
        bled_out = 'Vous vous êtes vidé de votre sang...',
    },
    success = {
        wounds_healed = 'Vos blessures ont été soignées !',
    },
    info = {
        self_death = 'Eux-Même ou un PNJ',
        wep_unknown = 'Inconnu',
        status = 'Check Status',
        healthy = 'Vous êtes maintenant en parfaite santé !',
        pain_message = 'Votre %{limb} est %{severity}',
        many_places = 'Vous avez mal à plusieurs endroits ...',
        bleed_alert = 'Vous êtes %{bleedstate}',
        revive_player_a = 'Réanimer quelqu\'un ou vous même (Admin Only)',
        player_id = 'ID joueur (Peut être vide)',
        pain_level = 'Definir le niveau de douleur d\'un joueur ou de vous même (Admin Only)',
        kill = 'Tuer un joueur ou vous même (Admin Only)',
        heal_player_a = 'Soigner un joueur ou vous même (Admin Only)',
    },
    states = {
        irritated = 'irrité',
        quite_painful = 'assez douloureux',
        painful = 'douloureux',
        really_painful = 'Vraiment douloureux',
        little_bleed = 'Saigne un peu...',
        bleed = 'Saigne...',
        lot_bleed = 'Saigne beaucoup...',
        big_bleed = 'Saigne enormément...',
    },
    body = {
        head = 'Tête',
        neck = 'Nuque',
        spine = 'Colonne vertebrale',
        upper_body = 'Haut du corp',
        lower_body = 'Bas du corp',
        left_arm = 'Bras gauche',
        left_hand = 'Main gauche',
        left_fingers = 'Doigts gauches',
        left_leg = 'Jambe gauche',
        left_foot = 'Pied gauche',
        right_arm = 'Bras droit',
        right_hand = 'Main droite',
        right_fingers = 'Doigts Droite',
        right_leg = 'Jambe droite',
        right_foot = 'Pied Droit',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) est mort",
        death_log_message = "%{killername} a tué %{playername} avec **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
