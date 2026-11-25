import QtQuick
import "../Styles"

// Слайдер из примитивов QtQuick: клик и перетаскивание по дорожке,
// опциональный шаг (stepSize). Управляющий элемент — обычный Rectangle.
Item {
    id: root

    // --- API ---
    property real from: 0
    property real to: 100
    property real value: 0
    // 0 — непрерывное значение, иначе привязка к шагу
    property real stepSize: 0

    signal moved(real value)

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для слайдера это meterColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int trackHeight: UiTheme.sliderTrackHeight
    property int handleSize: UiTheme.sliderHandleSize
    property color trackColor: UiTheme.border
    property color fillColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.meterColor
    property color handleColor: UiTheme.surface
    property color handleBorderColor: UiTheme.borderStrong

    // --- Размеры по умолчанию ---
    implicitWidth: 200
    implicitHeight: handleSize + 4

    opacity: enabled ? 1 : 0.6

    function ratioOf(v) {
        const range = root.to - root.from
        if (range <= 0)
            return 0
        return Math.max(0, Math.min(1, (v - root.from) / range))
    }

    function syncValueFromHandle() {
        const max = root.width - handle.width
        let v = max > 0 ? root.from + (handle.x / max) * (root.to - root.from) : root.from
        if (root.stepSize > 0)
            v = root.from + Math.round((v - root.from) / root.stepSize) * root.stepSize
        v = Math.max(root.from, Math.min(root.to, v))
        root.value = v
        root.moved(v)
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.trackHeight
        radius: height / 2
        color: root.trackColor

        Rectangle {
            id: fill
            height: parent.height
            radius: height / 2
            width: handle.x + handle.width / 2
            color: root.fillColor
        }
    }

    Rectangle {
        id: handle
        anchors.verticalCenter: parent.verticalCenter
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: root.handleColor
        border.width: UiTheme.borderWidth
        border.color: root.handleBorderColor
        x: 0
        scale: sliderMouse.pressed ? 1.2 : (sliderMouse.containsMouse ? 1.1 : 1)

        Behavior on scale { NumberAnimation { duration: UiTheme.animFast } }

        // Пока ручку не тащат — её позиция следует за value.
        // Во время перетаскивания binding отключён, value обновляется из позиции.
        Binding on x {
            when: !sliderMouse.drag.active
            value: root.ratioOf(root.value) * (root.width - handle.width)
        }
    }

    MouseArea {
        id: sliderMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag.target: handle
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: root.width - handle.width

        onPressed: function(mouse) {
            // Клик по дорожке — прыгаем в точку клика (ручка центрируется под курсором)
            if (!sliderMouse.drag.active) {
                handle.x = Math.max(0, Math.min(mouse.x - handle.width / 2, root.width - handle.width))
                root.syncValueFromHandle()
            }
        }

        onPositionChanged: {
            if (sliderMouse.drag.active)
                root.syncValueFromHandle()
        }
    }
}
