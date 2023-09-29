local Translations = {
    error = {
        bled_out = 'Esvaíste-te em sangue...',
    },
    success = {
        wounds_healed = 'Os teus ferimentos foram curados!',
    },
    info = {
        self_death = 'Eles próprios ou um NPC',
        wep_unknown = 'Desconhecido',
        status = 'Verificação de Estado',
        healthy = 'Estás novamente saudável!',
        pain_message = 'O(s) teu(s) %{limb} sente-se %{severity}',
        many_places = 'Tens dores em váios locais...',
        bleed_alert = 'Tu estás %{bleedstate}',
        revive_player_a = 'Reviver um Paciente ou tu mesmo (Somente Admin)',
        player_id = 'ID do Jogador (opcional)',
        pain_level = 'Define o nįvel de dor a ti ou a outro jogador (Somente Admin)',
        kill = 'Matar um jogador ou a ti próprio (Somente Admin)',
        heal_player_a = 'Curar um jogador ou a ti próprio (Somente Admin)',
    },
    states = {
        irritated = 'irritado',
        quite_painful = 'um pouco doloroso',
        painful = 'doloroso',
        really_painful = 'bastante doloroso',
        little_bleed = 'a sangrar um pouco...',
        bleed = 'a sangrar...',
        lot_bleed = 'a sangrar bastante...',
        big_bleed = 'a sangrar terrivelmente...',
    },
    body = {
        head = 'Cabeça',
        neck = 'Pescoço',
        spine = 'Coluna',
        upper_body = 'Membros Superiores',
        lower_body = 'Membros Inferiores',
        left_arm = 'Braço Esquerdo',
        left_hand = 'Mão Esquerda',
        left_fingers = 'Dedos Esquerdos',
        left_leg = 'Perna Esquerda',
        left_foot = 'Pé Esquerdo',
        right_arm = 'Braço Direito',
        right_hand = 'Mão Direita',
        right_fingers = 'Dedos Direitos',
        right_leg = 'Perna Direita',
        right_foot = 'Pé Direito',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) foi morto",
        death_log_message = "%{killername} foi morto %{playername} com uma **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'pt' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
