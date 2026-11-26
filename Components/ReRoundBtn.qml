import QtQuick
import "../Styles"

// Круглая кнопка: для коротких действий — плюс, минус,
// галочка и прочие одиночные символы. API повторяет ReBtn: те же стили
// Accent/Simple, сигналы и переопределяемые цвета; вместо радиуса задаётся
// диаметр (кнопка всегда остаётся кругом при любых принудительных размерах).
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
    property int diameter: UiTheme.controlHeight
    property int fontSize: UiTheme.fontSize

    property color txtColor: styleType === "Accent"
        ? (enabled ? UiTheme.textOnPrimary : UiTheme.textSecondary)
        : (enabled ? UiTheme.textOnSecondary : UiTheme.textSecondary)

    property color bgColor: styleType === "Accent" ? UiTheme.primary : UiTheme.secondary
    property color hoverColor: styleType === "Accent" ? UiTheme.primaryHover : UiTheme.secondaryHover
    property color pressColor: styleType === "Accent" ? UiTheme.primaryPressed : UiTheme.secondaryPressed
    property color disabledColor: UiTheme.disabledBackground

    // --- Размеры по умолчанию ---
    implicitWidth: diameter
    implicitHeight: diameter

    // Круг при любых принудительных width/height
    radius: Math.min(width, height) / 2

    opacity: enabled ? 1 : 0.7
    color: !enabled ? disabledColor
        : mouseArea.pressed ? pressColor
        : mouseArea.containsMouse ? hoverColor
        : bgColor

    // Лёгкий тактильный отклик при нажатии (как у ручки слайдера)
    scale: mouseArea.pressed ? 0.92 : 1

    Behavior on color { ColorAnimation { duration: UiTheme.animFast } }
    Behavior on scale { NumberAnimation { duration: UiTheme.animFast } }

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
