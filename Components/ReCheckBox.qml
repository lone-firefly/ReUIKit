import QtQuick
import "../Styles"

// Чекбокс из примитивов QtQuick: Rectangle + Canvas (галочка) + Text + MouseArea.
Item {
    id: root

    // --- API ---
    property alias text: label.text
    property bool checked: false

    signal toggled(bool isChecked)
    signal clicked()

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для чекбокса это stateColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int boxSize: UiTheme.checkBoxSize
    property int boxRadius: UiTheme.radiusSmall
    property color bgColor: UiTheme.surface
    property color checkedColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.stateColor
    property color borderColor: UiTheme.border
    property color borderHoverColor: UiTheme.borderStrong
    property color checkMarkColor: accent === "primary" ? UiTheme.textOnPrimary
        : accent === "secondary" ? UiTheme.textOnSecondary
        : UiTheme.textOnState
    property color txtColor: UiTheme.textPrimary
    property int fontSize: UiTheme.fontSize

    // --- Размеры по умолчанию ---
    implicitWidth: layout.implicitWidth
    implicitHeight: Math.max(boxSize, label.implicitHeight)

    opacity: enabled ? 1 : 0.6

    function toggle() {
        if (!root.enabled)
            return
        root.checked = !root.checked
        root.toggled(root.checked)
    }

    Row {
        id: layout
        spacing: UiTheme.spacing

        Rectangle {
            id: box
            anchors.verticalCenter: parent.verticalCenter
            width: root.boxSize
            height: root.boxSize
            radius: root.boxRadius
            color: root.checked ? root.checkedColor : root.bgColor
            border.width: UiTheme.borderWidth
            border.color: root.checked ? root.checkedColor
                : (boxMouse.containsMouse ? root.borderHoverColor : root.borderColor)

            Behavior on color { ColorAnimation { duration: UiTheme.animFast } }
            Behavior on border.color { ColorAnimation { duration: UiTheme.animFast } }

            // Галочка, нарисованная на Canvas — без иконочных шрифтов
            Canvas {
                id: checkMark
                anchors.centerIn: parent
                width: root.boxSize * 0.65
                height: root.boxSize * 0.65
                opacity: root.checked ? 1 : 0
                scale: root.checked ? 1 : 0.4

                Behavior on opacity { NumberAnimation { duration: UiTheme.animFast } }
                Behavior on scale { NumberAnimation { duration: UiTheme.animFast; easing.type: Easing.OutBack } }

                property color stroke: root.checkMarkColor
                onStrokeChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = root.checkMarkColor
                    ctx.lineWidth = 2
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(width * 0.1, height * 0.55)
                    ctx.lineTo(width * 0.4, height * 0.85)
                    ctx.lineTo(width * 0.9, height * 0.15)
                    ctx.stroke()
                }
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: root.txtColor
            font.pixelSize: root.fontSize

            // Шрифт по умолчанию не трогаем — используется системный.
            // Меняем только если пользователь задал UiTheme.fontFamily.
            Component.onCompleted: {
                if (UiTheme.fontFamily.length > 0)
                    label.font.family = UiTheme.fontFamily
            }
        }
    }

    MouseArea {
        id: boxMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
            root.toggle()
        }
    }
}
