pragma Singleton
import QtQuick

// Библиотека пресетов тем. Здесь заданы одноцветные и комбинированные (duotone)
// пресеты, а также нейтральные цвета для светлого/тёмного режимов.
//
// Чтобы добавить свою тему, допишите строку в themes:
//   "mytheme": makeTheme("#123456", "#ff8000", "#ABCDEF", "#FEDCBA")
// или с собственными дополнительными цветами:
//   "mytheme": makeTheme("#123456", "#ff8000", "#ABCDEF", "#FEDCBA", {
//       light: { background: "#FAFAFA", error: "#B00020" },
//       dark:  { background: "#101010" }
//   })
// Двухцветная (duotone) тема — два сочетающихся акцента; второй автоматически
// уходит во «включённые» состояния контролов (свитчи, чекбоксы, радио):
//   "myduo": makeDuoTheme("#123456", "#ff8000", "#ABCDEF", "#FEDCBA")
QtObject {

    // --- Нейтральные цвета по умолчанию ---
    readonly property var stdLight: ({
        background: "#FFFFFF",
        surface: "#FFFFFF",
        surfaceAlt: "#F5F5F5",
        border: "#D1D5DB",
        text: "#1F2937",
        textSecondary: "#6B7280",
        error: "#DC2626",
        success: "#16A34A",
        warning: "#D97706"
    })

    readonly property var stdDark: ({
        background: "#111827",
        surface: "#1F2937",
        surfaceAlt: "#374151",
        border: "#4B5563",
        text: "#F9FAFB",
        textSecondary: "#9CA3AF",
        error: "#F87171",
        success: "#4ADE80",
        warning: "#FBBF24"
    })

    // Сборка темы: основные цвета для обоих режимов + стандартные нейтралы.
    // secondary — неакцентный цвет: у обычных тем в светлом режиме это бледный
    // пастельный тон (текст подбирается тёмным автоматически), в тёмном —
    // приглушённый глубокий. У комбинированных (duotone) тем secondary —
    // насыщенный второй акцент, контрастный текст считается так же автоматически.
    // extra — необязательные точечные переопределения нейтралов по режимам.
    function makeTheme(primary, secondary, primaryDark, secondaryDark, extra) {
        const light = Object.assign({}, stdLight, { primary: primary, secondary: secondary })
        const dark = Object.assign({}, stdDark, { primary: primaryDark, secondary: secondaryDark })
        if (extra) {
            if (extra.light) Object.assign(light, extra.light)
            if (extra.dark) Object.assign(dark, extra.dark)
        }
        return { light: light, dark: dark }
    }

    // Сборка duotone-темы: как makeTheme, но в state-роль («включено/выбрано»
    // у свитчей, чекбоксов, радио и выделения в комбобоксе) прописывается
    // второй акцент темы. Кнопки и измерители (slider/progress/spinner)
    // остаются на primary — двухцветная тема не выглядит монотонной.
    function makeDuoTheme(primary, secondary, primaryDark, secondaryDark, extra) {
        const t = makeTheme(primary, secondary, primaryDark, secondaryDark, extra)
        t.light.state = secondary
        t.dark.state = secondaryDark
        return t
    }

    readonly property var themes: {
        // --- Одноцветные: primary + пастельный secondary ---
        "blue":   makeTheme("#2563EB", "#BFDBFE", "#60A5FA", "#1E40AF"),
        "green":  makeTheme("#059669", "#A7F3D0", "#34D399", "#064E3B"),
        "violet": makeTheme("#7C3AED", "#DDD6FE", "#A78BFA", "#4C1D95"),

        // --- Комбинированные (duotone): два сочетающихся акцентных цвета ---
        // secondary — полноценный второй цвет: Simple-кнопки берут его,
        // а «включённые» свитчи/чекбоксы/радио и выделение в комбобоксе —
        // автоматически (state-роль, см. makeDuoTheme).
        "firefly": makeDuoTheme("#EA580C", "#14532D", "#F97316", "#16A34A", {
                light: { background: "#dedede" },
                dark:  { background: "#101010" }
            }
        ),
        "ocean":  makeDuoTheme("#0E7490", "#1E3A8A", "#06B6D4", "#3B82F6"),  // циан + глубокий синий
        "orchid": makeDuoTheme("#8B5CF6", "#BE185D", "#C4B5FD", "#EC4899"),  // сирень + фуксия
        "sage":   makeDuoTheme("#688B76", "#7B764A", "#9BB4A7", "#688B76", {  // шалфей + олива-хаки
                light: { surfaceAlt: "#D7D4D5", border: "#98928E",
                         text: "#292623", textSecondary: "#706651" },
                dark:  { background: "#292623", surface: "#3C3B32", surfaceAlt: "#505A52",
                         border: "#706651", text: "#D7D4D5", textSecondary: "#98928E" }
            }
        ),
        "bronze": makeDuoTheme("#977E37", "#68791E", "#B39754", "#7B764A", {  // бронза + олива
                light: { background: "#D7D4D5", surface: "#FFFFFF",
                         border: "#98928E", text: "#292623", textSecondary: "#706651" },
                dark:  { background: "#292623", surface: "#3C3B32", surfaceAlt: "#4C5950",
                         border: "#737243", text: "#D7D4D5", textSecondary: "#98928E" }
            }
        )
    }

    // Список имён пресетов (для комбобокса выбора темы и т.п.)
    function names() {
        return Object.keys(themes)
    }

    function has(name) {
        return themes[name] !== undefined
    }

    // Готовый набор цветов пресета для указанного режима
    function resolve(name, dark) {
        const t = themes[name]
        if (t)
            return dark ? t.dark : t.light
        return dark ? stdDark : stdLight
    }
}
