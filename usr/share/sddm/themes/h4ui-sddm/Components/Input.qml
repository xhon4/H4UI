//
// Selector de usuario + contraseña + checkbox mostrar/ocultar + mensaje de
// error + botón de login + selector de sesión, todo en un solo componente
// (igual que en r4chi). La lógica de sddm.login(), Connections a
// loginSucceeded/loginFailed y el manejo de foco/teclado es la misma;
// solo cambia el skin a cápsulas de vidrio Frutiger Aero.
//
// PORT Qt6: los PropertyChanges que apuntaban a X.background / X.contentItem
// (tipados Item genérico por Qt6, sin `border`/`color`) se retargetean a ids
// concretos: revealBg (Rectangle) y loginText (Text).
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import Qt5Compat.GraphicalEffects

Column {
    id: inputContainer
    Layout.fillWidth: true
    spacing: root.font.pointSize * 0.5

    property Control exposeLogin: loginButton
    property bool failed

    // USERNAME INPUT
    Item {
        id: usernameField

        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        ComboBox {

            id: selectUser

            width: parent.height
            height: parent.height
            anchors.left: parent.left
            z: 2

            model: userModel
            currentIndex: model.lastIndex
            textRole: "name"
            hoverEnabled: true
            onActivated: {
                username.text = currentText
            }

            delegate: ItemDelegate {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                contentItem: Text {
                    text: model.realName != "" ? model.realName : model.name
                    font.pointSize: root.font.pointSize * 0.8
                    font.capitalization: Font.Capitalize
                    color: selectUser.highlightedIndex === index ? "#FFFFFFFF" : root.palette.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                highlighted: parent.highlightedIndex === index
                background: Rectangle {
                    radius: root.radiusButton * 0.6
                    color: "transparent"

                    // "Gel bubble" -- mismo patrón que "element selected" de rofi.
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        visible: selectUser.highlightedIndex === index
                        gradient: Gradient {
                            GradientStop { position: 0.00; color: "#c7f0ffff" }
                            GradientStop { position: 0.30; color: "#7a5fcdff" }
                            GradientStop { position: 0.65; color: "#b31482e1" }
                            GradientStop { position: 1.00; color: "#b800cde6" }
                        }
                    }
                }
            }

            indicator: Button {
                    id: usernameIcon
                    width: selectUser.height * 0.8
                    height: parent.height
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: selectUser.height * 0.125
                    icon.height: parent.height * 0.25
                    icon.width: parent.height * 0.25
                    enabled: false
                    
                    // Descomentamos el color para que el ícono (User.svgz) tome el color del texto (Accent/Deep)
                    icon.color: root.palette.text
                    icon.source: Qt.resolvedUrl("../Assets/User.svgz")

                    // FIX: Eliminamos el fondo negro por defecto del botón
                    background: Item {}
            }

            background: Rectangle {
                color: "transparent"
                border.color: "transparent"
            }

            popup: Popup {
                y: parent.height - username.height / 3
                rightMargin: config.ForceRightToLeft == "true" ? root.padding + usernameField.width / 2 : undefined
                width: usernameField.width
                implicitHeight: contentItem.implicitHeight
                padding: 10

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight + 20
                    model: selectUser.popup.visible ? selectUser.delegateModel : null
                    currentIndex: selectUser.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    radius: root.radiusPanel * 0.7
                    color: "#EBFDFF"
                    border.color: "#FFFFFF"
                    border.width: 2
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 18
                        samples: 25
                        cached: true
                        color: "#40003C78"
                    }
                }

                enter: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1 }
                }
            }

            states: [
                State {
                    name: "pressed"
                    when: selectUser.down
                    PropertyChanges {
                        target: usernameIcon
//                         icon.color: root.colAeroDeep
                    }
                },
                State {
                    name: "hovered"
                    when: selectUser.hovered
                    PropertyChanges {
                        target: usernameIcon
//                         icon.color: root.colAeroBlue
                    }
                },
                State {
                    name: "focused"
                    when: selectUser.visualFocus
                    PropertyChanges {
                        target: usernameIcon
//                         icon.color: root.colAeroBlue
                    }
                }
            ]

            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "color, border.color, icon.color"
                        duration: 150
                    }
                }
            ]

        }

        TextField {
            id: username
            text: config.ForceLastUser == "true" ? selectUser.currentText : null
            font.capitalization: Font.Capitalize
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            placeholderText: config.TranslateUsernamePlaceholder || textConstants.userName
            selectByMouse: true
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.QtRendering
            color: root.palette.text
            // Cápsula glossy blanco->azul, mismo patrón que el inputbar de rofi.
            background: Rectangle {
                radius: root.radiusInput
                border.color: parent.activeFocus ? root.colAeroBlue : "#CCFFFFFF"
                border.width: parent.activeFocus ? 2 : 1
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#ffffffff" }
                    GradientStop { position: 0.18; color: "#efffffff" }
                    GradientStop { position: 0.55; color: "#91ffffff" }
                    GradientStop { position: 1.00; color: "#24ffffff" }
                }
            }
            Keys.onReturnPressed: loginButton.clicked()
            KeyNavigation.down: password
            z: 1

            states: [
                State {
                    name: "focused"
                    when: username.activeFocus
                    PropertyChanges {
                        target: username
                        color: root.colAeroDeep
                    }
                }
            ]
        }

    }

    // PASSWORD INPUT
    Item {
        id: passwordField
        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: password
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            focus: config.ForcePasswordFocus == "true" ? true : false
            selectByMouse: true
            echoMode: revealSecret.checked ? TextInput.Normal : TextInput.Password
            placeholderText: config.TranslatePasswordPlaceholder || textConstants.password
            horizontalAlignment: TextInput.AlignHCenter
            passwordCharacter: "•"
            passwordMaskDelay: config.ForceHideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            color: root.palette.text
            background: Rectangle {
                radius: root.radiusInput
                border.color: parent.activeFocus ? root.colAeroBlue : "#CCFFFFFF"
                border.width: parent.activeFocus ? 2 : 1
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#ffffffff" }
                    GradientStop { position: 0.18; color: "#efffffff" }
                    GradientStop { position: 0.55; color: "#91ffffff" }
                    GradientStop { position: 1.00; color: "#24ffffff" }
                }
            }
            Keys.onReturnPressed: loginButton.clicked()
            KeyNavigation.down: revealSecret
        }

        states: [
            State {
                name: "focused"
                when: password.activeFocus
                PropertyChanges {
                    target: password
                    color: root.colAeroDeep
                }
            }
        ]

        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color, border.color"
                    duration: 150
                }
            }
        ]
    }

    // SHOW/HIDE PASS
    Item {
        id: secretCheckBox
        height: root.font.pointSize * 7
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        CheckBox {
            id: revealSecret
            width: parent.width
            hoverEnabled: true

            indicator: Rectangle {
                id: indicator
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.leftMargin: 4
                implicitHeight: root.font.pointSize
                implicitWidth: root.font.pointSize
                radius: 4
                color: "#91FFFFFF"
                border.color: parent.visualFocus ? root.colAeroBlue : "#CCFFFFFF"
                border.width: parent.visualFocus ? 2 : 1
                Rectangle {
                    id: dot
                    anchors.centerIn: parent
                    implicitHeight: parent.width - 6
                    implicitWidth: parent.width - 6
                    radius: 2
                    color: root.colAeroBlue
                    opacity: revealSecret.checked ? 1 : 0
                }
            }

            contentItem: Text {
                id: indicatorLabel
                text: config.TranslateShowPassword || "Show Password"
                anchors.verticalCenter: indicator.verticalCenter
                anchors.verticalCenterOffset: 0
                horizontalAlignment: Text.AlignLeft
                anchors.left: indicator.right
                anchors.leftMargin: indicator.width / 2
                font.pointSize: root.font.pointSize * 0.8
                color: root.palette.text
            }

            Keys.onReturnPressed: toggle()
            KeyNavigation.down: loginButton

            background: Rectangle {
                id: revealBg
                color: "transparent"
                border.width: parent.visualFocus ? 1 : 0
                border.color: parent.visualFocus ? root.colAeroBlue : "transparent"
                height: parent.visualFocus ? 2 : 0
                width: (indicator.width + indicatorLabel.contentWidth + indicatorLabel.anchors.leftMargin + 2)
                anchors.top: indicatorLabel.bottom
                anchors.left: parent.left
                anchors.leftMargin: 3
                anchors.topMargin: 8
            }
        }

        states: [
            State {
                name: "pressed"
                when: revealSecret.down
                PropertyChanges {
                    target: indicatorLabel
                    color: root.colAeroDeep
                }
                PropertyChanges {
                    target: dot
                    color: root.colAeroDeep
                }
                PropertyChanges {
                    target: indicator
                    border.color: root.colAeroDeep
                }
                PropertyChanges {
                    target: revealBg
                    border.color: root.colAeroDeep
                }
            },
            State {
                name: "hovered"
                when: revealSecret.hovered
                PropertyChanges {
                    target: indicatorLabel
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: indicator
                    border.color: root.colAeroBlue
                }
                PropertyChanges {
                    target: dot
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: revealBg
                    border.color: root.colAeroBlue
                }
            },
            State {
                name: "focused"
                when: revealSecret.visualFocus
                PropertyChanges {
                    target: indicatorLabel
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: indicator
                    border.color: root.colAeroBlue
                }
                PropertyChanges {
                    target: dot
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: revealBg
                    border.color: root.colAeroBlue
                }
            }
        ]

        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color, border.color, opacity"
                    duration: 150
                }
            }
        ]

    }

    // ERROR FIELD
    Item {
        height: root.font.pointSize * 2.3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: errorMessage
            width: parent.width
            text: failed ? config.TranslateLoginFailed || textConstants.loginFailed + "!" : keyboard.capsLock ? textConstants.capslockWarning : null
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: root.font.pointSize * 0.8
            font.italic: true
            // rojo "danger" para login fallido, tinta normal para el aviso de capslock
            color: failed ? root.colDanger : root.palette.text
            opacity: 0
            states: [
                State {
                    name: "fail"
                    when: failed
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                    }
                },
                State {
                    name: "capslock"
                    when: keyboard.capsLock
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "opacity"
                        duration: 100
                    }
                }
            ]
        }
    }

    // LOGIN BUTTON
    Item {
        id: login
        height: root.font.pointSize * 3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: config.TranslateLogin || textConstants.login
            height: root.font.pointSize * 3
            implicitWidth: parent.width
            enabled: username.text != "" && password.text != "" ? true : false
            hoverEnabled: true

            contentItem: Text {
                id: loginText
                text: parent.text
                color: "#0A2A3F"
                font.pointSize: root.font.pointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: 0.55
            }

            // Botón "gel bubble" -- mismo gradiente que "element selected" de rofi.
            background: Rectangle {
                id: buttonBackground
                radius: root.radiusButton
                border.width: 2
                border.color: "#66FFFFFF"
                opacity: 0.55
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#c7f0ffff" }
                    GradientStop { position: 0.30; color: "#7a5fcdff" }
                    GradientStop { position: 0.65; color: "#b31482e1" }
                    GradientStop { position: 1.00; color: "#b800cde6" }
                }
            }

            states: [
                State {
                    name: "pressed"
                    when: loginButton.down
                    PropertyChanges {
                        target: buttonBackground
                        border.color: "#FFFFFFFF"
                        opacity: 1
                    }
                    PropertyChanges {
                        target: loginText
                        color: "#0A2A3F"
                        opacity: 1
                    }
                },
                State {
                    name: "hovered"
                    when: loginButton.hovered
                    PropertyChanges {
                        target: buttonBackground
                        border.color: "#FFFFFFFF"
                        opacity: 1
                    }
                    PropertyChanges {
                        target: loginText
                        opacity: 1
                        color: "#0A2A3F"
                    }
                },
                State {
                    name: "focused"
                    when: loginButton.visualFocus
                    PropertyChanges {
                        target: buttonBackground
                        border.color: "#FFFFFFFF"
                        opacity: 1
                    }
                    PropertyChanges {
                        target: loginText
                        opacity: 1
                        color: "#0A2A3F"
                    }
                },
                State {
                    name: "enabled"
                    when: loginButton.enabled
                    PropertyChanges {
                        target: buttonBackground
                        border.color: "#FFFFFFFF"
                        opacity: 1
                    }
                    PropertyChanges {
                        target: loginText
                        opacity: 1
                    }
                }
            ]

            transitions: [
                Transition {
                    from: ""; to: "enabled"
                    PropertyAnimation {
                        properties: "opacity, color";
                        duration: 500
                    }
                },
                Transition {
                    from: "enabled"; to: ""
                    PropertyAnimation {
                        properties: "opacity, color";
                        duration: 300
                    }
                }
            ]

            Keys.onReturnPressed: clicked()
            onClicked: sddm.login(username.text, password.text, sessionSelect.selectedSession)
        }
    }

    // SESSION SELECT
    SessionButton {
        id: sessionSelect
        textConstantSession: textConstants.session
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            failed = true
            resetError.running ? resetError.stop() && resetError.start() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: failed = false
        running: false
    }
}
