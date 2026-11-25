import QtQuick
import "../Styles"

// Переключатель (switch/toggle) из примитивов QtQuick.
Item {
    id: root

    // --- API ---
    property alias text: label.text
    property bool checked: false

    signal toggled(bool isChecked)

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для свитча это stateColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int switchWidth: UiTheme.switchWidth
    property int switchHeight: UiTheme.switchHeight
    property color trackOnColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.stateColor
    property color trackOffColor: UiTheme.borderStrong
    property color handleColor: UiTheme.surface
    property color handleBorderColor: UiTheme.border
    property color txtColor: UiTheme.textPrimary
    property int fontSize: UiTheme.fontSize

    // --- Размеры по умолчанию ---
    implicitWidth: layout.implicitWidth
    implicitHeight: Math.max(switchHeight, label.implicitHeight)

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
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: root.switchWidth
            height: root.switchHeight
            radius: height / 2
            color: root.checked ? root.trackOnColor : root.trackOffColor

            Behavior on color { ColorAnimation { duration: UiTheme.animNormal } }

            Rectangle {
                id: handle
                anchors.verticalCenter: parent.verticalCenter
                width: root.switchHeight - 4
                height: root.switchHeight - 4
                radius: width / 2
                color: root.handleColor
                border.width: 1
                border.color: root.handleBorderColor
                x: root.checked ? root.switchWidth - width - 2 : 2

                Behavior on x { NumberAnimation { duration: UiTheme.animNormal; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            id: label
            visible: text.length > 0
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
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }
}
