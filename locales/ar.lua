local Translations = {
    error = {
        bled_out = 'لقد نزفت',
    },
    success = {
        wounds_healed = 'لقد التئمت جروحك',
    },
    info = {
        self_death = 'قتل نفسه او قتله سكان اصلي',
        wep_unknown = 'غير معروف',
        status = 'فحص الحالة',
        healthy = 'أنت بصحة جيدة مرة أخرى',
        pain_message = '%{limb} %{severity}',
        many_places = 'لديك ألم في أماكن كثيرة',
        bleed_alert = '%{bleedstate} انت',
        revive_player_a = 'إحياء لاعب أو نفسك (المسؤول فقط)',
        player_id = 'معرف اللاعب (قد يكون فارغا)',
        pain_level = 'قم بتعيين مستوى الألم الخاص بك أو مستوى اللاعبين (المسؤول فقط)',
        kill = 'اقتل لاعبًا أو قتل نفسك (المسؤول فقط)',
        heal_player_a = 'شفاء لاعب أو نفسك (المسؤول فقط)',
    },
    states = {
        irritated = 'منزعج',
        quite_painful = 'مؤلم جدا',
        painful = 'مؤلم',
        really_painful = 'مؤلم حقا',
        little_bleed = 'ينزف قليلا',
        bleed = 'نزيف',
        lot_bleed = 'ينزف كثيرا',
        big_bleed = 'ينزف كثيرا',
    },
    body = {
        head = 'رأس',
        neck = 'رقبه',
        spine = 'العمود الفقري',
        upper_body = 'الجزء العلوي',
        lower_body = 'الجسم السفلي',
        left_arm = 'الذراع الأيسر',
        left_hand = 'اليد اليسرى',
        left_fingers = 'الأصابع اليسرى',
        left_leg = 'الساق اليسرى',
        left_foot = 'القدم اليسرى',
        right_arm = 'الذراع الأيمن',
        right_hand = 'اليد اليمنى',
        right_fingers = 'الاصابع اليمنى',
        right_leg = 'الساق اليمنى',
        right_foot = 'القدم اليمنى',
    },
    logs = {
        death_log_title = "%{playername} (%{playerid}) ميت",
        death_log_message = "%{killername} قتل %{playername} ب **%{weaponlabel}** (%{weaponname})",
    }
}

if GetConvar('qb_locale', 'en') == 'ar' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
