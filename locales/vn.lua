local Translations = {
    error = {
        bled_out = 'Bạn đang bị chảy máu...',
    },
    success = {
        wounds_healed = 'Vết thương của bạn đã lành',
    },
    info = {
        self_death = 'Tự sát hoặc NPC',
        wep_unknown = 'Vô danh',
        status = 'Kiểm tra trạng thái',
        healthy = 'Bạn đã được chữa lành!',
        pain_message = ' %{limb} đang bị %{severity}',
        many_places = 'Bạn bị đau nghiêm trọng...',
        bleed_alert = 'Bạn bị %{bleedstate}',
        revive_player_a = 'Hồi sinh bản thân hoặc ngươi chơi (Chỉ Admin)',
        player_id = 'ID người chơi (có thể để trống)',
        pain_level = 'Đặt mức độ bị thương cho chính bản thân hoặc người chơi (Chỉ Admin)',
        kill = 'Giết người chơi hoặc bản thân (Chỉ Admin)',
        heal_player_a = 'Hồi máu cho bản thân hoặc ngươi chơi (Chỉ Admin)',
    },
    states = {
        irritated = 'Nhức',
        quite_painful = 'Hơi đau',
        painful = 'Đau',
        really_painful = 'Đau nghiêm trọng',
        little_bleed = 'Mất máu ít...',
        bleed = 'Đang mất máu...',
        lot_bleed = 'Mất máu nhiều...',
        big_bleed = 'Mất máu nghiêm trọng...',
    },
    body = {
        head = 'Đầu',
        neck = 'Cổ',
        spine = 'Xương sống',
        upper_body = 'Thân trên',
        lower_body = 'Thân dưới',
        left_arm = 'Cánh tay trái',
        left_hand = 'Bàn tay trái',
        left_fingers = 'Ngón tay trái',
        left_leg = 'Chân trái',
        left_foot = 'Bàn chân trái',
        right_arm = 'Cánh tay phải',
        right_hand = 'Bàn tay phải',
        right_fingers = 'Ngón tay phải',
        right_leg = 'Chân phải',
        right_foot = 'Bàn chân phải',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) đã chết",
        death_log_message = "%{killername} đã giết %{playername} bằng một **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'vn' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
