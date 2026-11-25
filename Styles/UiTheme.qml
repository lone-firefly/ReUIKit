pragma Singleton
import QtQuick

// Глобальная тема UIKit. Единственное место управления внешним видом:
//
//   UiTheme.preset = "blue"               // пресет из UiPresets
//   UiTheme.mode = UiTheme.Dark            // светлый/тёмный режим
//   UiTheme.shape = UiTheme.ShapeSoft      // Sharp / Soft / Round
//   UiTheme.primary = "#6750A4"            // точечная замена цвета
//   UiTheme.apply({ primary: "...", background: "...", controlHeight: 36 })
//
// Все компоненты читают значения отсюда; на конкретном экземпляре компонента
// любое значение по-прежнему можно переопределить его собственным свойством.
//
// Смена preset/mode заново загружает базовые цвета из пресета,
// переопределения (прямые присваивания и apply) при этом сбрасываются.
QtObject {
    id: root

    // --- Перечисления ---
    enum Mode { Light, Dark }
    enum Shape { Sharp, Soft, Round }

    // --- Глобальные настройки ---
    // Внутри этого файла значения enum недоступны (UiTheme.Dark → undefined),
    // поэтому mode/shape и все сравнения используют числа:
    // mode:  0 = Light, 1 = Dark;  shape: 0 = Sharp, 1 = Soft, 2 = Round
    property string preset: "blue"
    property int mode: 0
    property int shape: 1

    // --- Базовые цвета (загружаются из пресета, можно переопределить) ---
    // Начальные значения соответствуют пресету "blue" (светлый режим)
    property color primary: "#2563EB"
    property color secondary: "#BFDBFE"
    property color background: "#FFFFFF"
    property color surface: "#FFFFFF"
    property color surfaceAlt: "#F5F5F5"
    property color border: "#D1D5DB"
    property color textPrimary: "#1F2937"
    property color textSecondary: "#6B7280"
    property color error: "#DC2626"
    property color success: "#16A34A"
    property color warning: "#D97706"

    // --- Семантические роли (второй акцент для duotone-тем) ---
    // stateColor — «включено/выбрано» (ReSwitch, ReCheckBox, ReRadio,
    // выделенный пункт ReComboBox), meterColor — «активность/значение»
    // (ReSlider, ReProgressBar, ReSpinner). По умолчанию обе равны primary —
    // обычные темы не меняются; duotone-пресеты (makeDuoTheme) прописывают
    // в state свой второй акцент. На экземпляре компонента роль перекрывается
    // его свойством accent ("auto" | "primary" | "secondary").
    property color stateColor: "#2563EB"
    property color meterColor: "#2563EB"

    // --- Контрастный текст на цветном фоне (по яркости цвета) ---
    // Обычные свойства, пересчитываемые императивно в updateContrastColors():
    // биндинг с вызовом JS-функции (isLightColor(primary)) при присваиваниях
    // из reloadColors() перечитывается ненадёжно — после смены пресета/режима
    // текст оставался цветом от предыдущей палитры (тёмный текст на тёмной кнопке).
    property color textOnPrimary: "#FFFFFF"
    property color textOnSecondary: "#FFFFFF"
    property color textOnState: "#FFFFFF"

    // --- Производные цвета (readonly, считаются автоматически) ---

    // Состояния основного цвета
    readonly property color primaryHover: mode === 1 ? Qt.lighter(primary, 1.2) : Qt.darker(primary, 1.12)
    readonly property color primaryPressed: mode === 1 ? Qt.lighter(primary, 1.4) : Qt.darker(primary, 1.28)

    // Состояния вторичного цвета
    readonly property color secondaryHover: mode === 1 ? Qt.lighter(secondary, 1.2) : Qt.darker(secondary, 1.12)
    readonly property color secondaryPressed: mode === 1 ? Qt.lighter(secondary, 1.4) : Qt.darker(secondary, 1.28)

    // Нейтральные состояния (ховер/нажатие серых поверхностей)
    readonly property color hoverBackground: mode === 1 ? Qt.lighter(surfaceAlt, 1.3) : Qt.darker(surfaceAlt, 1.08)
    readonly property color pressedBackground: mode === 1 ? Qt.lighter(surfaceAlt, 1.55) : Qt.darker(surfaceAlt, 1.2)

    // Усиленная рамка (ховер у рамок, дорожки, скроллбары)
    readonly property color borderStrong: mode === 1 ? Qt.lighter(border, 1.45) : Qt.darker(border, 1.3)

    // Недоступное состояние
    readonly property color textDisabled: mode === 1 ? "#6B7280" : "#9CA3AF"
    readonly property color disabledBackground: mode === 1 ? "#1F2937" : "#E5E7EB"

    // --- Форма (скругления зависят от style) ---
    readonly property real radiusSmall: shape === 0 ? 0 : shape === 1 ? 4 : 8
    readonly property real radiusMedium: shape === 0 ? 2 : shape === 1 ? 8 : 14
    readonly property real radiusLarge: shape === 0 ? 4 : shape === 1 ? 14 : 999

    // --- Типографика ---
    // "" — системный стандартный шрифт (компоненты в этом случае не трогают font.family)
    property string fontFamily: ""
    property int fontSize: 14
    property int fontSizeSmall: 12
    property int fontSizeLarge: 16
    property int fontSizeTitle: 20

    // --- Плотность и размеры ---
    property int controlHeight: 40
    property int controlHeightSmall: 32
    property int borderWidth: 1
    property int padding: 10
    property int spacing: 10
    property int listItemHeight: 35
    property int checkBoxSize: 20
    property int radioSize: 20
    property int switchWidth: 44
    property int switchHeight: 24
    property int sliderTrackHeight: 6
    property int sliderHandleSize: 18
    property int progressBarHeight: 8

    // --- Анимации (мс) ---
    property int animFast: 100
    property int animNormal: 200

    // --- Управление ---

    // Выбрать пресет (и, при желании, режим одной строкой)
    function use(name, m) {
        preset = name
        if (m !== undefined)
            mode = m
    }

    // Применить набор значений одним вызовом.
    // Ключи — имена перезаписываемых свойств: primary, background, shape,
    // controlHeight, fontSize и т.д. (readonly-производные задавать нельзя)
    function apply(obj) {
        for (const key in obj)
            root[key] = obj[key]
    }

    // Загрузка базовых цветов из пресета.
    // Вызывается при смене preset/mode: прямые переопределения цветов сбрасываются.
    function reloadColors() {
        const p = UiPresets.resolve(preset, mode === 1)
        primary = p.primary
        secondary = p.secondary
        background = p.background
        surface = p.surface
        surfaceAlt = p.surfaceAlt
        border = p.border
        textPrimary = p.text
        textSecondary = p.textSecondary
        error = p.error
        success = p.success
        warning = p.warning
        stateColor = p.state !== undefined ? p.state : p.primary
        meterColor = p.meter !== undefined ? p.meter : p.primary
        updateContrastColors()
    }

    // Пересчёт контрастного текста. Вызывается из reloadColors() и из
    // обработчиков смены primary/secondary — так покрыты смена пресета,
    // смена режима, точечные присваивания (UiTheme.primary = ...) и apply().
    function updateContrastColors() {
        textOnPrimary = isLightColor(primary) ? "#111827" : "#FFFFFF"
        textOnSecondary = isLightColor(secondary) ? "#111827" : "#FFFFFF"
        textOnState = isLightColor(stateColor) ? "#111827" : "#FFFFFF"
    }

    onPresetChanged: reloadColors()
    onModeChanged: reloadColors()
    onPrimaryChanged: updateContrastColors()
    onSecondaryChanged: updateContrastColors()
    onStateColorChanged: updateContrastColors()
    Component.onCompleted: reloadColors()

    // Яркий ли цвет: относительная светимость (WCAG).
    // Порог 0.28: насыщенные акценты светлого режима остаются с белым текстом,
    // а светлые акценты тёмного режима (blue, violet) получают тёмный текст.
    // Цвет разбираем из hex-строки (String(color) → "#RRGGBB"/"#AARRGGBB") —
    // чтение каналов .r/.g/.b из JS ненадёжно по масштабу значений.
    // При любом нераспознаваемом формате считаем цвет тёмным → белый текст.
    function isLightColor(c) {
        let h = String(c)
        if (h.charAt(0) === "#")
            h = h.substring(1)
        if (h.length === 8)
            h = h.substring(2)
        if (h.length !== 6 || /[^0-9a-fA-F]/.test(h))
            return false
        const r = parseInt(h.substring(0, 2), 16) / 255
        const g = parseInt(h.substring(2, 4), 16) / 255
        const b = parseInt(h.substring(4, 6), 16) / 255
        function lin(v) {
            return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b) > 0.28
    }
}
