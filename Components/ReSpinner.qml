import QtQuick
import "../Styles"

// Круговой индикатор загрузки из примитивов QtQuick:
// дуга на Canvas, вращение — NumberAnimation на rotation.
Item {
    id: root

    // --- API ---
    property bool running: true

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для спиннера это meterColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int circleSize: 28
    property int arcWidth: 3
    property color ringColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.meterColor
    // Фоновое кольцо; "transparent" — без фона
    property color trackColor: "transparent"

    // --- Размеры по умолчанию ---
    implicitWidth: circleSize
    implicitHeight: circleSize

    opacity: enabled ? 1 : 0.6

    Canvas {
        id: spinnerCanvas
        anchors.fill: parent

        property color ring: root.ringColor
        onRingChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        NumberAnimation on rotation {
            running: root.running && root.visible
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const cx = width / 2
            const cy = height / 2
            const r = Math.min(width, height) / 2 - root.arcWidth / 2 - 1

            ctx.lineWidth = root.arcWidth
            ctx.lineCap = "round"

            // Фоновое кольцо
            if (root.trackColor.a > 0) {
                ctx.strokeStyle = root.trackColor
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.stroke()
            }

            // Дуга (3/4 окружности), вращается анимацией rotation
            ctx.strokeStyle = root.ringColor
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * 0.75)
            ctx.stroke()
        }
    }
}
