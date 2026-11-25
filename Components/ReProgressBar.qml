import QtQuick
import "../Styles"

// Прогресс-бар из примитивов QtQuick.
// Поддерживает обычный режим (value) и неопределённый (indeterminate).
Item {
    id: root

    // --- API ---
    property real from: 0
    property real to: 1
    property real value: 0
    property bool indeterminate: false

    readonly property real position: {
        const range = root.to - root.from
        if (range <= 0)
            return 0
        return Math.max(0, Math.min(1, (root.value - root.from) / range))
    }

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для прогресса это meterColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int barHeight: UiTheme.progressBarHeight
    property color bgColor: UiTheme.border
    property color fillColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.meterColor

    // --- Размеры по умолчанию ---
    implicitWidth: 200
    implicitHeight: barHeight

    Rectangle {
        id: track
        width: parent.width
        height: root.barHeight
        radius: height / 2
        color: root.bgColor
        clip: true

        Rectangle {
            id: fillBar
            visible: !root.indeterminate
            height: parent.height
            radius: height / 2
            width: parent.width * root.position
            color: root.fillColor

            Behavior on width { NumberAnimation { duration: UiTheme.animNormal; easing.type: Easing.OutCubic } }
        }

        Rectangle {
            id: indeterminateBar
            visible: root.indeterminate
            height: parent.height
            radius: height / 2
            width: parent.width * 0.3
            color: root.fillColor
            x: -width

            NumberAnimation on x {
                running: root.indeterminate
                loops: Animation.Infinite
                duration: 1200
                from: -indeterminateBar.width
                to: track.width
            }
        }
    }
}
