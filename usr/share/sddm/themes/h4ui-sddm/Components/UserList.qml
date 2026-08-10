//
// Selector de usuario standalone. En r4chi este componente existe pero
// Input.qml lo reimplementa inline y es el que Main.qml termina usando
// -- se mantiene acá igual, sin uso activo, solo por paridad de
// arquitectura con la base.
//

import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt5Compat.GraphicalEffects

Item {
    id: usernameField

    height: root.font.pointSize * 4.5
    width: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter

    property var selectedUser: selectUser.currentIndex
    property alias user: username.text

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
//                 icon.color: root.palette.text
                icon.source: Qt.resolvedUrl("../Assets/User.svgz")
        }

        background: Rectangle {
            color: "transparent"
            border.color: "transparent"
        }

        popup: Popup {
            y: parent.height - username.height / 3
            rightMargin: config.ForceRightToLeft == "true" ? usernameField.width / 2 : undefined
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
//                     icon.color: root.colAeroDeep
                }
            },
            State {
                name: "hovered"
                when: selectUser.hovered
                PropertyChanges {
                    target: usernameIcon
//                     icon.color: root.colAeroBlue
                }
            },
            State {
                name: "focused"
                when: selectUser.visualFocus
                PropertyChanges {
                    target: usernameIcon
//                     icon.color: root.colAeroBlue
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
