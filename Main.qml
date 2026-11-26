// Main.qml — демо всех компонентов UIKit
import QtQuick
import "./Components"
import "./Styles"

Window {
    id: mainWindow
    width: 680
    height: 940
    visible: true
    title: "ReUIKit — демо"
    color: UiTheme.background

    // Внутренние поля страницы: на узких экранах (телефон) — компактнее
    readonly property int pageMargin: width < 500 ? 12 : 24

    Flickable {
        id: flick

        anchors.fill: parent

        anchors.topMargin: SafeArea.margins.top
        anchors.bottomMargin: SafeArea.margins.bottom
        anchors.leftMargin: mainWindow.safeAreaMargins ? mainWindow.safeAreaMargins.left : 0
        anchors.rightMargin: mainWindow.safeAreaMargins ? mainWindow.safeAreaMargins.right : 0

        clip: true
        // Только вертикальная прокрутка — горизонтальной нет
        flickableDirection: Flickable.VerticalFlickable
        contentWidth: width
        contentHeight: column.height + mainWindow.pageMargin * 2

        Column {
            id: column
            x: mainWindow.pageMargin
            y: mainWindow.pageMargin
            width: flick.width - mainWindow.pageMargin * 2
            spacing: 24

            // ============ Настройки темы ============
            Rectangle {
                id: themePanel
                width: parent.width
                height: themePanelContent.implicitHeight + 32
                radius: UiTheme.radiusMedium

                // Подложка секции чуть плотнее фона страницы:
                // в светлом режиме — чуть темнее, в тёмном — чуть светлее
                // (просто «темнее» на тёмном фоне не видно).
                color: UiTheme.surfaceAlt

                Behavior on color { ColorAnimation { duration: UiTheme.animFast } }

                Column {
                    id: themePanelContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "Настройки темы"
                        color: UiTheme.textPrimary
                        font.pixelSize: UiTheme.fontSizeLarge
                        font.bold: true
                    }

                    // Flow: на широком экране всё в одну строку,
                    // на телефоне — переносится
                    Flow {
                        id: themeRow
                        width: parent.width
                        spacing: 12

                        ReComboBox {
                            id: presetBox
                            width: Math.min(240, themeRow.width)
                            model: UiPresets.names()
                            placeholder: "Палитра (пресет)"
                            currentIndex: -1

                            // При загрузке страницы показываем текущий пресет,
                            // а не пустой плейсхолдер
                            Component.onCompleted: {
                                const i = UiPresets.names().indexOf(UiTheme.preset)
                                currentIndex = i >= 0 ? i : -1
                            }

                            onActivated: function(index) {
                                UiTheme.preset = UiPresets.names()[index]
                            }
                        }

                        // Обёртка центрирует свитч по высоте строки:
                        // Flow выравнивает по верху, а свитч ниже комбобокса
                        Item {
                            width: darkSwitch.implicitWidth
                            height: UiTheme.controlHeight

                            ReSwitch {
                                id: darkSwitch
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Тёмная тема"

                                onToggled: function(isChecked) {
                                    UiTheme.mode = isChecked ? UiTheme.Dark : UiTheme.Light
                                }
                            }
                        }

                        ReBtn {
                            text: "Форма: " + ["Sharp", "Soft", "Round"][UiTheme.shape]
                            styleType: "Simple"

                            onClicked: UiTheme.shape = (UiTheme.shape + 1) % 3
                        }
                    }
                }
            }

            // ============ ReBtn ============
            Text {
                text: "ReBtn"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            Flow {
                width: parent.width
                spacing: 12

                ReBtn {
                    text: "Accent"
                    onClicked: console.log("Нажата Accent")
                }

                ReBtn {
                    text: "Simple"
                    styleType: "Simple"
                }

                ReBtn {
                    text: "Disabled"
                    enabled: false
                }
            }

            // Кастомная кнопка: переопределяем цвета и скругление на месте
            ReBtn {
                text: "Кастомный"
                bgColor: "#7C3AED"
                hoverColor: "#6D28D9"
                pressColor: "#5B21B6"
                txtColor: "white"
                btnRadius: 16
            }

            // ============ ReRoundBtn ============
            Text {
                text: "ReRoundBtn"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            Flow {
                width: parent.width
                spacing: 12

                ReRoundBtn {
                    text: "+"
                    onClicked: console.log("Нажата круглая +")
                }

                ReRoundBtn {
                    text: "−"
                    styleType: "Simple"
                }

                ReRoundBtn {
                    text: "x"
                    enabled: false
                }

                // Кастомная: увеличенный диаметр и свои цвета
                ReRoundBtn {
                    text: "menu"
                    diameter: 56
                    bgColor: "#7C3AED"
                    hoverColor: "#6D28D9"
                    pressColor: "#5B21B6"
                    txtColor: "white"
                }
            }

            // ============ ReInput ============
            Text {
                text: "ReInput"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReInput {
                width: parent.width
                placeholder: "Обычное поле"
            }

            ReInput {
                width: parent.width
                placeholder: "Скрытый ввод"
                echoMode: TextInput.Password
            }

            ReInput {
                width: parent.width
                placeholder: "Состояние ошибки"
                error: true
            }

            // ============ ReComboBox ============
            Text {
                text: "ReComboBox"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReComboBox {
                id: cityBox
                width: parent.width
                model: ["Москва", "Санкт-Петербург", "Казань", "Новосибирск", "Екатеринбург", "Краснодар", "Владивосток"]
                placeholder: "Выберите город"
                currentIndex: -1

                onActivated: function(index) {
                    console.log("Выбран город:", cityBox.currentText)
                }
            }

            Text {
                text: "Текущее значение: " + (cityBox.currentIndex >= 0 ? cityBox.currentText : "не выбрано")
                color: UiTheme.textSecondary
                font.pixelSize: UiTheme.fontSizeSmall
            }

            // Кастомный комбобокс со своими цветами
            ReComboBox {
                width: parent.width
                model: ["Высокий приоритет", "Средний приоритет", "Низкий приоритет"]
                placeholder: "Приоритет задачи"
                currentIndex: -1
                itemSelectedColor: "#7C3AED"
                activeBorderColor: "#7C3AED"
            }

            // ============ ReCheckBox ============
            Text {
                text: "ReCheckBox"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReCheckBox {
                id: agreeBox
                text: "Флажок А"
                checked: true
            }

            ReCheckBox {
                id: newsBox
                text: "Флажок Б"
                onToggled: function(isChecked) {
                    console.log("Флажок Б:", isChecked)
                }
            }

            Text {
                text: "Флажок А: " + (agreeBox.checked ? "да" : "нет")
                      + ", флажок Б: " + (newsBox.checked ? "да" : "нет")
                color: UiTheme.textSecondary
                font.pixelSize: UiTheme.fontSizeSmall
            }

            // ============ ReRadio + ReRadioGroup ============
            Text {
                text: "ReRadio + ReRadioGroup"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReRadioGroup {
                id: deliveryGroup

                ReRadio { text: "Вариант 1"; checked: true }
                ReRadio { text: "Вариант 2" }
                ReRadio { text: "Вариант 3" }
            }

            // ReRadioGroup {
            //     id: deliveryGroup2

            //     Row {
            //         spacing: 16

            //         ReRadio { text: "Вариант 1"; checked: true }
            //         ReRadio { text: "Вариант 2" }
            //         ReRadio { text: "Вариант 3" }
            //     }
            // }

            Text {
                text: "Выбрано: " + (deliveryGroup.current ? deliveryGroup.current.text : "—")
                color: UiTheme.textSecondary
                font.pixelSize: UiTheme.fontSizeSmall
            }

            // ============ ReSwitch ============
            Text {
                text: "ReSwitch"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            Flow {
                width: parent.width
                spacing: 24

                ReSwitch {
                    checked: true

                    onToggled: function(isChecked) {
                        console.log("Свитч:", isChecked)
                    }
                }

                ReSwitch {
                    text: "Опция"
                }

                // accent перекидывает компонент на другой акцент темы:
                // в duotone-темах (firefly, ocean, orchid, sage, bronze) свитчи
                // по умолчанию берут второй цвет (state-роль), этот — primary
                ReSwitch {
                    text: "accent: primary"
                    accent: "primary"
                }
            }

            // ============ ReSlider ============
            Text {
                text: "ReSlider"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReSlider {
                id: slider
                width: parent.width
                from: 0
                to: 100
                stepSize: 1
                value: 35
            }

            Text {
                text: "Значение: " + Math.round(slider.value)
                color: UiTheme.textSecondary
                font.pixelSize: UiTheme.fontSizeSmall
            }

            // ============ ReProgressBar ============
            Text {
                text: "ReProgressBar / ReSpinner"
                color: UiTheme.textPrimary
                font.pixelSize: UiTheme.fontSizeLarge
                font.bold: true
            }

            ReProgressBar {
                width: parent.width
                from: 0
                to: 100
                value: slider.value
            }

            Flow {
                width: parent.width
                spacing: UiTheme.spacing * 2

                ReProgressBar {
                    width: 200
                    indeterminate: true
                }

                ReSpinner {
                    id: spinner
                }
            }
        }
    }
}
