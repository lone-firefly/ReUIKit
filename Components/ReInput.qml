import QtQuick
import "../Styles"

// Поле ввода. Собрано из примитивов QtQuick (Rectangle + TextInput + Text),
// готовый TextField из QtQuick.Controls не используется.
Rectangle {
    id: root

    // --- API ---
    property alias text: inputField.text

    // Текст-заполнитель (плейсхолдер)
    property string placeholder: ""

    // Режим отображения символов: TextInput.Normal | TextInput.Password | ...
    property int echoMode: TextInput.Normal

    // Признак ошибки (подсветка рамки)
    property bool error: false

    // --- Стиль (переопределяемый) ---
    // Акцент: "primary" (по умолчанию) или "secondary" — цвет фокуса и выделения
    property string accent: "primary"
    property color bgColor: UiTheme.surface
    property color disabledColor: UiTheme.disabledBackground
    property color textColor: UiTheme.textPrimary
    property color placeholderColor: UiTheme.textSecondary
    property color borderColor: UiTheme.border
    property color borderHoverColor: UiTheme.borderStrong
    property color focusBorderColor: accent === "secondary" ? UiTheme.secondary : UiTheme.primary
    property color errorColor: UiTheme.error
    property int borderWidth: UiTheme.borderWidth
    property int fontSize: UiTheme.fontSize

    // --- Размеры по умолчанию ---
    implicitWidth: 220
    implicitHeight: UiTheme.controlHeight

    color: enabled ? bgColor : disabledColor
    radius: UiTheme.radiusMedium
    border.width: borderWidth
    border.color: !enabled ? borderColor
        : error ? errorColor
        : inputField.activeFocus ? focusBorderColor
        : inputHover.hovered ? borderHoverColor
        : borderColor
    clip: true

    Behavior on border.color { ColorAnimation { duration: UiTheme.animFast } }

    // --- Поле ввода (примитив TextInput) ---
    TextInput {
        id: inputField
        anchors.fill: parent
        anchors.leftMargin: UiTheme.padding
        anchors.rightMargin: UiTheme.padding

        verticalAlignment: TextInput.AlignVCenter
        color: root.enabled ? root.textColor : UiTheme.textDisabled
        selectionColor: root.accent === "secondary" ? UiTheme.secondary : UiTheme.primary
        selectedTextColor: root.accent === "secondary" ? UiTheme.textOnSecondary : UiTheme.textOnPrimary
        font.pixelSize: root.fontSize
        echoMode: root.echoMode
        selectByMouse: true

        // Шрифт по умолчанию не трогаем — используется системный.
        // Меняем только если пользователь задал UiTheme.fontFamily.
        Component.onCompleted: {
            if (UiTheme.fontFamily.length > 0)
                inputField.font.family = UiTheme.fontFamily
        }
    }

    // --- Плейсхолдер (виден, пока текст пустой) ---
    Text {
        id: placeholderText
        anchors.fill: parent
        anchors.leftMargin: UiTheme.padding
        anchors.rightMargin: UiTheme.padding

        verticalAlignment: Text.AlignVCenter
        text: root.placeholder
        color: root.placeholderColor
        font.pixelSize: root.fontSize
        elide: Text.ElideRight
        visible: inputField.text.length === 0

        Component.onCompleted: {
            if (UiTheme.fontFamily.length > 0)
                placeholderText.font.family = UiTheme.fontFamily
        }
    }

    // HoverHandler не перехватывает события мыши у TextInput (в отличие от MouseArea)
    HoverHandler {
        id: inputHover
    }
}
