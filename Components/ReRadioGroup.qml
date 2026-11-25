import QtQuick
import "../Styles"

// Группа радио-кнопок с исключающим выбором.
// Каждая ReRadio внутри (на любой глубине вложенности — через Row/Column и т.п.)
// при создании сама находит ближайшую группу-предка и регистрируется в ней.
//
// Радио-кнопки, положенные прямо внутрь группы, раскладываются вертикально:
//   ReRadioGroup {
//       ReRadio { text: "Раз"; checked: true }
//       ReRadio { text: "Два" }
//   }
// Для своей раскладки оберните кнопки в Row/Column — регистрация сохранится.
Item {
    id: root

    // Маркер: по нему ReRadio ищет группу среди предков
    readonly property bool isReRadioGroup: true

    // --- API ---
    property int currentIndex: -1
    property alias spacing: layout.spacing

    readonly property var radios: internal.radios
    readonly property var current: currentIndex >= 0 && currentIndex < internal.radios.length
        ? internal.radios[currentIndex]
        : null

    // Кнопки, объявленные прямо в группе, попадают в вертикальную раскладку
    default property alias content: layout.data

    // --- Размеры по умолчанию ---
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: internal
        property var radios: []
    }

    Column {
        id: layout
        spacing: UiTheme.spacing
    }

    onCurrentIndexChanged: syncRadios()

    // Вызывается ReRadio из Component.onCompleted
    function registerRadio(r) {
        if (internal.radios.indexOf(r) !== -1)
            return
        internal.radios = internal.radios.concat(r)
        r.toggled.connect(function() { root.selectRadio(r) })
        if (r.checked)
            root.currentIndex = internal.radios.length - 1
    }

    function selectRadio(r) {
        const i = internal.radios.indexOf(r)
        if (i < 0 || i === root.currentIndex)
            return
        root.currentIndex = i
    }

    function syncRadios() {
        for (let i = 0; i < internal.radios.length; ++i)
            internal.radios[i].checked = (i === root.currentIndex)
    }
}
