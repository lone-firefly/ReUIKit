import QtQuick
import "../Styles"

// Кнопка. Собрана из примитивов QtQuick (Rectangle + Text + MouseArea).
// Все свойства вынесены наверх и могут быть переопределены на месте использования.
Rectangle {
    id: root

    // --- API ---
    property alias text: label.text

    // Тип кнопки: "Accent" | "Simple"
    property string styleType: "Accent"

    signal clicked()
    signal pressed()
    signal released()

    // --- Стиль (переопределяемый) ---
    property int btnRadius: UiTheme.radiusMedium
    property int fontSize: UiTheme.fontSize

    property color txtColor: styleType === "Accent"
        ? (enabled ? UiTheme.textOnPrimary : UiTheme.textSecondary)
        : (enabled ? UiTheme.textOnSecondary : UiTheme.textSecondary)

    property color bgColor: styleType === "Accent" ? UiTheme.primary : UiTheme.secondary
    property color hoverColor: styleType === "Accent" ? UiTheme.primaryHover : UiTheme.secondaryHover
    property color pressColor: styleType === "Accent" ? UiTheme.primaryPressed : UiTheme.secondaryPressed
    property color disabledColor: UiTheme.disabledBackground

    // --- Размеры по умолчанию ---
    implicitWidth: label.implicitWidth + UiTheme.padding * 2
    implicitHeight: UiTheme.controlHeight

    radius: btnRadius
    opacity: enabled ? 1 : 0.7
    color: !enabled ? disabledColor
        : mouseArea.pressed ? pressColor
        : mouseArea.containsMouse ? hoverColor
        : bgColor

    Behavior on color { ColorAnimation { duration: UiTheme.animFast } }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.txtColor
        font.pixelSize: root.fontSize
        font.bold: true

        // Шрифт по умолчанию не трогаем — используется системный.
        // Меняем только если пользователь задал UiTheme.fontFamily.
        Component.onCompleted: {
            if (UiTheme.fontFamily.length > 0)
                label.font.family = UiTheme.fontFamily
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.pressed()
        onReleased: root.released()
        onClicked: root.clicked()
    }
}
