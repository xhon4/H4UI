//
// Suspend / Hibernate / Reboot / Shutdown. Misma lógica y bindings a
// sddm.suspend()/hibernate()/reboot()/powerOff() que r4chi -- los iconos
// svgz son monocromáticos (se recolorean vía icon.color), así que se
// reusan tal cual, solo cambia el color y se agrega un glow al hacer hover.
//
// PORT Qt6: los PropertyChanges apuntaban a parent.children[index], que
// Qt6 tipa como Item genérico (no tiene la grouped-property `icon`). Se
// retargetea al id `icon` (el RoundButton real, que sí tiene icon.color).
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4

RowLayout {

    spacing: root.font.pointSize * 1.4

    property var suspend: ["Suspend", config.TranslateSuspend || textConstants.suspend, sddm.canSuspend]
    property var hibernate: ["Hibernate", config.TranslateHibernate || textConstants.hibernate, sddm.canHibernate]
    property var reboot: ["Reboot", config.TranslateReboot || textConstants.reboot, sddm.canReboot]
    property var shutdown: ["Shutdown", config.TranslateShutdown || textConstants.shutdown, sddm.canPowerOff]

    property Control exposedLogin

    Repeater {

        model: [suspend, hibernate, reboot, shutdown]

        RoundButton {
            id: icon
            text: modelData[1]
            font.pointSize: root.font.pointSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            icon.source: modelData ? Qt.resolvedUrl("../Assets/" + modelData[0] + ".svgz") : ""
            icon.height: 2 * Math.round((root.font.pointSize * 3) / 2)
            icon.width: 2 * Math.round((root.font.pointSize * 3) / 2)
            display: AbstractButton.TextUnderIcon
            visible: modelData[2]
            hoverEnabled: true
            palette.buttonText: root.palette.text
// //             icon.color: root.palette.text

            background: Rectangle {
                id: glow
                radius: height / 2
                width: height
                height: parent.height * 0.92
                anchors.centerIn: parent
                color: "#00FFFFFF"
                border.width: 0
                border.color: "#00FFFFFF"
            }

            Keys.onReturnPressed: clicked()
            onClicked: {
                parent.forceActiveFocus()
                index == 0 ? sddm.suspend() : index == 1 ? sddm.hibernate() : index == 2 ? sddm.reboot() : sddm.powerOff()
            }
            KeyNavigation.up: exposedLogin
            KeyNavigation.left: index == 0 ? exposedLogin : parent.children[index-1]

            states: [
                State {
                    name: "pressed"
                    when: icon.down
                    PropertyChanges {
                        target: icon
                        palette.buttonText: root.colAeroDeep
// //                         icon.color: root.colAeroDeep
                    }
                    PropertyChanges {
                        target: glow
                        color: "#661482E1"
                        border.width: 2
                        border.color: "#FFFFFFFF"
                    }
                },
                State {
                    name: "hovered"
                    when: icon.hovered
                    PropertyChanges {
                        target: icon
                        palette.buttonText: root.colAeroBlue
// //                         icon.color: root.colAeroBlue
                    }
                    PropertyChanges {
                        target: glow
                        color: "#5500DDF2"
                        border.width: 2
                        border.color: "#CCFFFFFF"
                    }
                },
                State {
                    name: "focused"
                    when: icon.visualFocus
                    PropertyChanges {
                        target: icon
                        palette.buttonText: root.colAeroBlue
// //                         icon.color: root.colAeroBlue
                    }
                    PropertyChanges {
                        target: glow
                        color: "#3300DDF2"
                        border.width: 2
                        border.color: "#FFFFFFFF"
                    }
                }
            ]

            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "palette.buttonText, icon.color, color, border.color, border.width"
                        duration: 150
                    }
                }
            ]

        }

    }

}
