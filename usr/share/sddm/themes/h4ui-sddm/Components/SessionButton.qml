//
// Selector de sesión (sessionModel de sddm-greeter). Mismo binding
// sddm.login(..., sessionSelect.selectedSession) que usa Input.qml.
//
// PORT Qt6: los PropertyChanges apuntaban a selectSession.background, que
// Qt6 tipa como Item genérico (sin `border`). Se le da id `sessionBg` al
// Rectangle real y se retargetea a ese id.
//

import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt5Compat.GraphicalEffects

Item {
    id: sessionButton
    height: root.font.pointSize * 1.6
    width: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter

    property var selectedSession: selectSession.currentIndex
    property string textConstantSession

    ComboBox {
        id: selectSession

        hoverEnabled: true
        anchors.left: parent.left

        model: sessionModel
        currentIndex: model.lastIndex
        textRole: "name"

        delegate: ItemDelegate {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            contentItem: Text {
                text: model.name
                font.pointSize: root.font.pointSize * 0.8
                color: selectSession.highlightedIndex === index ? "#FFFFFFFF" : root.palette.text
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
                    visible: selectSession.highlightedIndex === index
                    gradient: Gradient {
                        GradientStop { position: 0.00; color: "#c7f0ffff" }
                        GradientStop { position: 0.30; color: "#7a5fcdff" }
                        GradientStop { position: 0.65; color: "#b31482e1" }
                        GradientStop { position: 1.00; color: "#b800cde6" }
                    }
                }
            }
        }

        indicator {
            visible: false
        }

        contentItem: Text {
            id: displayedItem
            text: (config.TranslateSession || (textConstantSession + ":")) + " " + selectSession.currentText
            color: root.palette.text
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.leftMargin: 3
            font.pointSize: root.font.pointSize * 0.8
        }

        background: Rectangle {
            id: sessionBg
            color: "transparent"
            border.width: parent.visualFocus ? 1 : 0
            border.color: "transparent"
            height: parent.visualFocus ? 2 : 0
            width: displayedItem.implicitWidth
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 3
        }

        popup: Popup {
            id: popupHandler
            y: parent.height - 1
            rightMargin: config.ForceRightToLeft == "true" ? root.padding + sessionButton.width / 2 : undefined
            width: sessionButton.width
            implicitHeight: contentItem.implicitHeight
            padding: 10

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight + 20
                model: selectSession.popup.visible ? selectSession.delegateModel : null
                currentIndex: selectSession.highlightedIndex
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
                when: selectSession.down
                PropertyChanges {
                    target: displayedItem
                    color: root.colAeroDeep
                }
                PropertyChanges {
                    target: sessionBg
                    border.color: root.colAeroDeep
                }
            },
            State {
                name: "hovered"
                when: selectSession.hovered
                PropertyChanges {
                    target: displayedItem
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: sessionBg
                    border.color: root.colAeroBlue
                }
            },
            State {
                name: "focused"
                when: selectSession.visualFocus
                PropertyChanges {
                    target: displayedItem
                    color: root.colAeroBlue
                }
                PropertyChanges {
                    target: sessionBg
                    border.color: root.colAeroBlue
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

}
