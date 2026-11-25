import QtQuick
import "../Styles"

// Радио-кнопка из примитивов QtQuick: Rectangle + Text + MouseArea.
// Для исключающего выбора положите несколько ReRadio внутрь ReRadioGroup
// (можно через Row/Column — группа найдёт их по дереву предков автоматически).
// Вне группы ведёт себя как независимый переключатель.
Item {
    id: root

    // --- API ---
    property alias text: label.text
    property bool checked: false

    signal toggled()
    signal clicked()

    // --- Стиль (переопределяемый) ---
    // Акцент: "auto" — роль из темы (для радио это stateColor),
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"
    property int indicatorSize: UiTheme.radioSize
    property color bgColor: UiTheme.surface
    property color checkedColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.stateColor
    property color borderColor: UiTheme.border
    property color borderHoverColor: UiTheme.borderStrong
    property color txtColor: UiTheme.textPrimary
    property int fontSize: UiTheme.fontSize

    // --- Размеры по умолчанию ---
    implicitWidth: layout.implicitWidth
    implicitHeight: Math.max(indicatorSize, label.implicitHeight)

    opacity: enabled ? 1 : 0.6

    Component.onCompleted: {
        // Ищем ближайшую группу-предка (ReRadioGroup) и регистрируемся в ней
        let p = root.parent
        while (p) {
            if (p.isReRadioGroup === true) {
                p.registerRadio(root)
                break
            }
            p = p.parent
        }
        // Шрифт по умолчанию не трогаем — используется системный.
        // Меняем только если пользователь задал UiTheme.fontFamily.
        if (UiTheme.fontFamily.length > 0)
            label.font.family = UiTheme.fontFamily
    }

    function toggle() {
        if (!root.enabled || root.checked)
            return
        root.checked = true
        root.toggled()
    }

    Row {
        id: layout
        spacing: UiTheme.spacing

        Rectangle {
            id: circle
            anchors.verticalCenter: parent.verticalCenter
            width: root.indicatorSize
            height: root.indicatorSize
            radius: width / 2
            color: root.bgColor
            border.width: UiTheme.borderWidth
            border.color: root.checked ? root.checkedColor
                : (radioMouse.containsMouse ? root.borderHoverColor : root.borderColor)

            Behavior on border.color { ColorAnimation { duration: UiTheme.animFast } }

            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: root.indicatorSize * 0.5
                height: root.indicatorSize * 0.5
                radius: width / 2
                color: root.checkedColor
                opacity: root.checked ? 1 : 0
                scale: root.checked ? 1 : 0.2

                Behavior on opacity { NumberAnimation { duration: UiTheme.animFast } }
                Behavior on scale { NumberAnimation { duration: UiTheme.animNormal; easing.type: Easing.OutBack } }
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: root.txtColor
            font.pixelSize: root.fontSize
        }
    }

    MouseArea {
        id: radioMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
            root.toggle()
        }
    }
}
