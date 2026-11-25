import QtQuick
import "../Styles"

// Комбобокс, собранный из примитивов QtQuick (Item + Rectangle + ListView + MouseArea).
// Готовый ComboBox/Popup из QtQuick.Controls не используется.
//
// Выпадающий список и оверлей закрытия переносятся на уровень окна (Window.contentItem):
// - оверлей ловит клик мимо списка и закрывает его;
// - popup имеет z выше оверлея, поэтому клики по элементам списка доходят до делегатов.
//
// Список выполнен как «плавающая карточка» с отступом от поля (popupGap):
// не конфликтует со скруглениями поля и одинаково выглядит при раскрытии вниз и вверх.
// Popup отслеживает скролл родительских Flickable/ListView — при прокрутке страницы
// позиция пересчитывается, а не «отлипает».
Item {
    id: root

    // --- API: данные ---
    // model — массив строк
    property var model: []
    property int currentIndex: 0
    property string placeholder: ""

    readonly property string currentText: currentIndex >= 0 && currentIndex < model.length ? model[currentIndex] : ""

    signal activated(int index)
    signal opened()
    signal closed()

    // --- API: стиль (переопределяемый) ---
    property int boxRadius: UiTheme.radiusMedium
    property int fontSize: UiTheme.fontSize
    property int borderWidth: UiTheme.borderWidth
    property int itemHeight: UiTheme.listItemHeight
    property int maxVisibleItems: 6

    // Отступ выпавшего списка от поля
    property int popupGap: 4
    // Внутренние отступы элементов списка (чтобы подсветка не наезжала на углы карточки)
    property int itemMargin: 4
    property int itemVMargin: 3
    property int itemRadius: UiTheme.radiusSmall

    property color bgColor: UiTheme.surface
    property color disabledBgColor: UiTheme.disabledBackground
    property color txtColor: UiTheme.textPrimary
    property color disabledTxtColor: UiTheme.textSecondary
    property color placeholderColor: UiTheme.textSecondary
    property color arrowColor: UiTheme.textSecondary

    // Акцент: "auto" — выделение берёт state-роль из темы,
    // "primary"/"secondary" — явно заданный акцент темы
    property string accent: "auto"

    property color borderColor: UiTheme.border
    property color borderHoverColor: UiTheme.borderStrong
    property color activeBorderColor: accent === "secondary" ? UiTheme.secondary : UiTheme.primary

    property color itemBgColor: "transparent"
    property color itemHoverColor: UiTheme.hoverBackground
    property color itemSelectedColor: accent === "primary" ? UiTheme.primary
        : accent === "secondary" ? UiTheme.secondary
        : UiTheme.stateColor
    property color itemSelectedTextColor: accent === "primary" ? UiTheme.textOnPrimary
        : accent === "secondary" ? UiTheme.textOnSecondary
        : UiTheme.textOnState

    // --- Размеры по умолчанию ---
    implicitWidth: 200
    implicitHeight: UiTheme.controlHeight
    width: implicitWidth
    height: implicitHeight

    // --- Внутреннее состояние ---
    property int highlightIndex: -1

    opacity: enabled ? 1 : 0.7

    // --- Публичные функции ---
    function openPopup() {
        if (!root.enabled || popup.visible)
            return
        root.highlightIndex = root.currentIndex
        popup.visible = true
        popup.updatePosition()
        popup.trackAncestors()
        if (root.currentIndex >= 0)
            listView.positionViewAtIndex(root.currentIndex, ListView.Contain)
        root.forceActiveFocus()
        root.opened()
    }

    function closePopup() {
        if (!popup.visible)
            return
        popup.visible = false
        popup.untrackAncestors()
        root.closed()
    }

    function togglePopup() {
        popup.visible ? root.closePopup() : root.openPopup()
    }

    function selectIndex(i) {
        if (i >= 0 && i < root.model.length && i !== root.currentIndex) {
            root.currentIndex = i
            root.activated(i)
        }
        root.closePopup()
    }

    onEnabledChanged: {
        if (!root.enabled)
            root.closePopup()
    }

    // --- Клавиатура ---
    Keys.onEscapePressed: root.closePopup()
    Keys.onSpacePressed: {
        if (!popup.visible)
            root.openPopup()
    }
    Keys.onUpPressed: root.moveHighlight(-1)
    Keys.onDownPressed: root.moveHighlight(1)
    Keys.onReturnPressed: function(event) {
        if (popup.visible && root.highlightIndex >= 0)
            root.selectIndex(root.highlightIndex)
        event.accepted = popup.visible
    }
    Keys.onEnterPressed: function(event) {
        if (popup.visible && root.highlightIndex >= 0)
            root.selectIndex(root.highlightIndex)
        event.accepted = popup.visible
    }

    function moveHighlight(delta) {
        if (!popup.visible || root.model.length === 0)
            return
        const i = Math.max(0, Math.min(root.model.length - 1, root.highlightIndex + delta))
        root.highlightIndex = i
        listView.positionViewAtIndex(i, ListView.Contain)
    }

    // При разрушении компонента отписываемся от скролла предков и возвращаем
    // popup в своё дерево, иначе он останется ребёнком окна с битыми ссылками.
    Component.onDestruction: {
        if (popup) {
            popup.untrackAncestors()
            if (popup.parent !== root)
                popup.parent = root
        }
    }

    // Пересчёт позиции при изменении размеров окна
    Connections {
        target: root.Window.window
        function onWidthChanged() {
            if (popup.visible)
                popup.updatePosition()
        }
        function onHeightChanged() {
            if (popup.visible)
                popup.updatePosition()
        }
    }

    // --- Закрывающая кнопка (поле + индикатор) ---
    Rectangle {
        id: controlButton
        anchors.fill: parent
        radius: root.boxRadius
        color: root.enabled ? root.bgColor : root.disabledBgColor
        border.width: root.borderWidth
        border.color: {
            if (!root.enabled)
                return root.borderColor
            if (popup.visible)
                return root.activeBorderColor
            return buttonMouseArea.containsMouse ? root.borderHoverColor : root.borderColor
        }

        Behavior on border.color { ColorAnimation { duration: UiTheme.animFast } }

        Text {
            id: displayText
            anchors.left: parent.left
            anchors.right: arrowIndicator.left
            anchors.leftMargin: UiTheme.padding
            anchors.rightMargin: UiTheme.padding / 2
            anchors.verticalCenter: parent.verticalCenter

            text: root.currentIndex >= 0 ? root.currentText : root.placeholder
            color: root.currentIndex < 0 ? root.placeholderColor
                : (root.enabled ? root.txtColor : root.disabledTxtColor)
            font.pixelSize: root.fontSize
            elide: Text.ElideRight

            // Шрифт по умолчанию не трогаем — используется системный.
            // Меняем только если пользователь задал UiTheme.fontFamily.
            Component.onCompleted: {
                if (UiTheme.fontFamily.length > 0)
                    displayText.font.family = UiTheme.fontFamily
            }
        }

        // Стрелочка, нарисованная на Canvas — не зависит от шрифта и иконок
        Canvas {
            id: arrowIndicator
            anchors.right: parent.right
            anchors.rightMargin: UiTheme.padding
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            rotation: popup.visible ? 180 : 0

            Behavior on rotation { NumberAnimation { duration: UiTheme.animFast } }

            property color stroke: root.arrowColor
            onStrokeChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = root.arrowColor
                ctx.lineWidth = 2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.beginPath()
                ctx.moveTo(2, 4.5)
                ctx.lineTo(6, 8.5)
                ctx.lineTo(10, 4.5)
                ctx.stroke()
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.togglePopup()
        }
    }

    // --- Оверлей: клик в любом месте окна вне списка закрывает popup ---
    MouseArea {
        id: outsideClickDismiss
        parent: root.Window.contentItem ? root.Window.contentItem : root
        anchors.fill: parent
        z: 999
        visible: popup.visible
        onPressed: root.closePopup()
    }

    // --- Выпадающий список (на уровне окна, выше оверлея) ---
    Item {
        id: popup
        parent: root.Window.contentItem ? root.Window.contentItem : root
        visible: false
        z: outsideClickDismiss.z + 1

        x: 0
        y: root.height + root.popupGap
        width: root.width

        // Желаемая высота без ограничений окна
        readonly property real desiredHeight: root.borderWidth * 2
            + Math.min(Math.max(root.model.length, 1), root.maxVisibleItems) * root.itemHeight
        // Ограничение по свободному месту у краёв окна (-1 — без ограничения)
        property real heightLimit: -1
        height: heightLimit > 0 ? Math.min(desiredHeight, heightLimit) : desiredHeight

        // Позиция списка: под полем, а если снизу не хватает места — над полем.
        // Если не помещается ни сверху, ни снизу — высота ограничивается доступным местом.
        function updatePosition() {
            const p = root.mapToItem(popup.parent, 0, 0)
            popup.x = p.x
            popup.heightLimit = -1

            const win = root.Window.window
            const h = popup.desiredHeight

            if (!win) {
                popup.y = p.y + root.height + root.popupGap
                return
            }

            const belowY = p.y + root.height + root.popupGap
            const spaceBelow = win.height - belowY - 8
            const spaceAbove = p.y - root.popupGap - 8

            if (h <= spaceBelow) {
                popup.y = belowY
                return
            }
            if (h <= spaceAbove) {
                popup.y = p.y - root.popupGap - h
                return
            }
            const minHeight = root.itemHeight + root.borderWidth * 2
            if (spaceBelow >= spaceAbove) {
                popup.heightLimit = Math.max(minHeight, spaceBelow)
                popup.y = belowY
            } else {
                popup.heightLimit = Math.max(minHeight, spaceAbove)
                popup.y = p.y - root.popupGap - popup.height
            }
        }

        // --- Слежение за родительскими Flickable/ListView ---
        // Если страница прокручивается (изменяются contentX/contentY),
        // popup пересчитывает позицию и не «отлипает» от поля.
        property var trackedFlickables: []

        function trackAncestors() {
            untrackAncestors()
            const list = []
            let p = root.parent
            while (p) {
                // Эвристика «похоже на Flickable/ListView»: наличие характерных свойств
                if (p.contentY !== undefined && p.flicking !== undefined && p.interactive !== undefined) {
                    const handler = function() {
                        if (popup.visible)
                            popup.updatePosition()
                    }
                    p.contentXChanged.connect(handler)
                    p.contentYChanged.connect(handler)
                    list.push({ item: p, handler: handler })
                }
                p = p.parent
            }
            popup.trackedFlickables = list
        }

        function untrackAncestors() {
            const list = popup.trackedFlickables
            for (let i = 0; i < list.length; ++i) {
                list[i].item.contentXChanged.disconnect(list[i].handler)
                list[i].item.contentYChanged.disconnect(list[i].handler)
            }
            popup.trackedFlickables = []
        }

        Rectangle {
            id: popupBackground
            anchors.fill: parent
            color: root.bgColor
            border.width: root.borderWidth
            border.color: root.borderColor
            radius: root.boxRadius
        }

        // Поглощаем события колеса над popup, которые не съел сам список:
        // Qt прокидывает их дальше по стеку, и страница под списком начинает
        // листаться вместе с ним. Вне popup события не перехватываются —
        // страница скроллится как обычно.
        WheelHandler {
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: root.borderWidth
            clip: true
            model: root.model
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                width: listView.width
                height: root.itemHeight

                Rectangle {
                    id: itemBackground
                    x: root.itemMargin
                    y: root.itemVMargin
                    width: parent.width - root.itemMargin * 2
                    height: parent.height - root.itemVMargin * 2
                    radius: root.itemRadius

                    // Подсветка наведения меняется мгновенно, без анимации:
                    // анимация цвета оставляла «шлейф» из подсвеченных строк,
                    // из-за чего казалось, что выделены сразу две позиции
                    color: (delegateMouse.pressed || index === root.currentIndex)
                        ? root.itemSelectedColor
                        : (index === root.highlightIndex ? root.itemHoverColor : root.itemBgColor)

                    Text {
                        id: delegateLabel
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: UiTheme.padding - root.itemMargin
                        anchors.rightMargin: 14

                        text: modelData
                        color: (delegateMouse.pressed || index === root.currentIndex)
                            ? root.itemSelectedTextColor
                            : root.txtColor
                        font.pixelSize: root.fontSize
                        elide: Text.ElideRight

                        Component.onCompleted: {
                            if (UiTheme.fontFamily.length > 0)
                                delegateLabel.font.family = UiTheme.fontFamily
                        }
                    }
                }

                MouseArea {
                    id: delegateMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.highlightIndex = index
                    onClicked: root.selectIndex(index)
                }
            }
        }

        // --- Примитивный скроллбар (без QtQuick.Controls ScrollBar) ---
        // Объявлен вне ListView: прямые дети Flickable/ListView попадают в contentItem
        // и скроллятся вместе с контентом, а скроллбар должен стоять на месте.
        Item {
            id: scrollbarTrack
            anchors.right: popup.right
            anchors.top: popup.top
            anchors.bottom: popup.bottom
            // Вертикальные отступы по радиусу карточки: при скруглённой теме
            // бегунок не должен выезжать за границу скруглённого угла
            anchors.topMargin: Math.min(root.boxRadius, root.itemHeight)
            anchors.bottomMargin: Math.min(root.boxRadius, root.itemHeight)
            anchors.rightMargin: 3
            width: 6
            visible: listView.contentHeight > listView.height

                Rectangle {
                    id: scrollbarThumb
                    width: parent.width
                    // Высота бегунка — от высоты ДОРОЖКИ (она короче списка из-за
                    // отступов под скругления), иначе бегунок вылезает за нижнюю границу
                    height: Math.min(scrollbarTrack.height,
                        Math.max(20, scrollbarTrack.height * listView.visibleArea.heightRatio))
                    radius: width / 2
                    color: scrollbarMouse.pressed ? root.itemSelectedColor : UiTheme.borderStrong

                    Binding on y {
                        when: !scrollbarMouse.drag.active
                        value: {
                            // yPosition меняется от 0 до (1 - heightRatio),
                            // поэтому нормируем на этот диапазон — иначе бегунок
                            // не доезжает до конца дорожки
                            const span = scrollbarTrack.height - scrollbarThumb.height
                            const maxPos = 1 - listView.visibleArea.heightRatio
                            return maxPos > 0 ? listView.visibleArea.yPosition / maxPos * span : 0
                        }
                    }

                MouseArea {
                    id: scrollbarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    drag.target: scrollbarThumb
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: scrollbarTrack.height - scrollbarThumb.height

                    onPositionChanged: {
                        if (drag.active) {
                            const track = scrollbarTrack.height - scrollbarThumb.height
                            listView.contentY = track > 0
                                ? scrollbarThumb.y / track * (listView.contentHeight - listView.height)
                                : 0
                        }
                    }
                }
            }
        }
    }
}
