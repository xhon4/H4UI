//
// H4UI SDDM theme.
// Base de esqueleto QML / bindings a sddm-greeter tomada de r4chi-sddm
// (Sugar Dark, GPL-3.0-or-later, Copyright 2018 Marian Arlt), re-skinneada
// por completo a Frutiger Aero. La lógica de navegación, PAM, sesiones y
// virtual keyboard es la misma; solo cambia el aspecto visual.
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import Qt5Compat.GraphicalEffects
import "Components"

Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width

    LayoutMirroring.enabled: config.ForceRightToLeft == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    padding: config.ScreenPadding
    palette.button: "transparent"

    // Paleta leída de theme.conf -- a diferencia de r4chi (que hardcodeaba
    // los hex acá adentro), acá sí importan los valores del .conf.
    palette.window: config.MainColor || "#0757C8"
    palette.base: config.PanelColor || "#DDFBFF"
    palette.text: config.TextColor || "#0A2A3F"
    palette.highlight: config.AccentColor || "#168CFF"
    palette.buttonText: config.ButtonTextColor || "#0A2A3F"

    // Tokens Aero adicionales que no tienen slot en QPalette, pero que
    // los componentes hijos necesitan para replicar el vidrio de
    // waybar/rofi (accedidos como root.colXxx desde los Components).
    readonly property color colAeroLight: "#DDFBFF"
    readonly property color colAeroBlue: config.AccentColor || "#168CFF"
    readonly property color colAeroDeep: config.MainColor || "#0757C8"
    readonly property color colAeroCyan: "#00DDF2"
    readonly property color colDanger: config.DangerColor || "#FF5B5B"
    readonly property color colGlassBorder: config.BorderColor || "#FFFFFF"
    readonly property real radiusPanel: config.CornerRadius ? parseInt(config.CornerRadius) : 22
    readonly property real radiusInput: config.InputCornerRadius ? parseInt(config.InputCornerRadius) : 18
    readonly property real radiusButton: config.ButtonCornerRadius ? parseInt(config.ButtonCornerRadius) : 16

    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80)
    focus: true

    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.PartialBlur == "false" &&
                            config.FormPosition == "left" &&
                            config.BackgroundImageAlignment == "left"

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "left" &&
                              config.BackgroundImageAlignment == "center"

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "right" &&
                              config.BackgroundImageAlignment == "right"

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.PartialBlur == "false" &&
                               config.FormPosition == "right" &&
                               config.BackgroundImageAlignment == "center"

    Item {
        id: sizeHelper

        anchors.fill: parent
        height: parent.height
        width: parent.width

        // Fondo por defecto: degradé cielo->profundo (aero_light -> aero_deep).
        // Si theme.conf trae un wallpaper en Background, la Image de abajo
        // lo tapa; si no, este degradé queda como fondo final.
        Rectangle {
            id: skyFallback
            anchors.fill: parent
            z: 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#DDFBFF" }
                GradientStop { position: 1.0; color: "#0757C8" }
            }
        }

        // Panel de vidrio grande detrás del form: cápsula redondeada estilo
        // waybar (mismo patrón de gradient stops que window#waybar > box),
        // con "inset" simulado en dos capas finas (QML no tiene box-shadow).
        Item {
            id: formBackground
            anchors.fill: form
            anchors.centerIn: form
            anchors.margins: -root.font.pointSize * 3.4
            z: 1

            Rectangle {
                id: glassBase
                anchors.fill: parent
                radius: root.radiusPanel
                border.width: config.BorderWidth ? parseInt(config.BorderWidth) : 2
                border.color: root.colGlassBorder
                opacity: config.PanelOpacity ? parseFloat(config.PanelOpacity) : 0.92
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#D1EBDFFF" } // rgba(235, 253, 255, 0.82)
                    GradientStop { position: 0.07; color: "#8C78DDFF" } // rgba(120, 221, 255, 0.55)
                    GradientStop { position: 0.25; color: "#C7199BEE" } // rgba(25, 155, 238, 0.78)
                    GradientStop { position: 0.68; color: "#D10A7ADC" } // rgba(10, 122, 220, 0.82)
                    GradientStop { position: 1.00; color: "#D100D3E8" } // rgba(0, 211, 232, 0.82)
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 3
                    radius: 24
                    samples: 33
                    color: "#40003C78"
                }
            }

            // Inset highlight blanco arriba (simula box-shadow inset superior)
            Rectangle {
                anchors.top: glassBase.top
                anchors.left: glassBase.left
                anchors.right: glassBase.right
                anchors.topMargin: 1
                height: 2
                radius: root.radiusPanel
                color: "#F2FFFFFF"
            }

            // Inset glow cian abajo (simula box-shadow inset inferior)
            Rectangle {
                anchors.bottom: glassBase.bottom
                anchors.left: glassBase.left
                anchors.right: glassBase.right
                anchors.bottomMargin: 1
                height: 2
                radius: root.radiusPanel
                color: "#B200F6FF"
            }
        }

        LoginForm {
            id: form

            height: virtualKeyboard.state == "visible" ? parent.height - virtualKeyboard.implicitHeight : parent.height
            width: parent.width / 2.5
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            virtualKeyboardActive: virtualKeyboard.state == "visible" ? true : false
            z: 2
        }

        Button {
            id: vkb
            onClicked: virtualKeyboard.switchState()
            visible: virtualKeyboard.status == Loader.Ready && config.ForceHideVirtualKeyboardButton == "false"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: implicitHeight
            anchors.horizontalCenter: form.horizontalCenter
            z: 2
            contentItem: Text {
                text: config.TranslateVirtualKeyboardButton || "Virtual Keyboard"
                color: parent.visualFocus ? root.palette.highlight : root.palette.text
                font.pointSize: root.font.pointSize * 0.8
            }
            background: Rectangle {
                id: vkbbg
                radius: root.radiusButton * 0.6
                color: "#8CFFFFFF"
                border.width: 1
                border.color: root.colGlassBorder
            }
        }

        Loader {
            id: virtualKeyboard
            source: "Components/VirtualKeyboard.qml"
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: keyboardActive ? state = "visible" : state = "hidden"
            width: parent.width
            z: 2
            function switchState() { state = state == "hidden" ? "visible" : "hidden" }
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: form
                        systemButtonVisibility: false
                        clockVisibility: false
                    }
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - virtualKeyboard.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                virtualKeyboard.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

        Image {
            id: backgroundImage

            // FIX: Hacemos que la imagen ocupe SIEMPRE toda la pantalla.
            anchors.fill: parent

            // Mantenemos la lógica de alineación de la imagen por si querés enfocar un lado
            horizontalAlignment: config.BackgroundImageAlignment == "left" ?
                                 Image.AlignLeft :
                                 config.BackgroundImageAlignment == "right" ?
                                 Image.AlignRight :
                                 Image.AlignHCenter

            source: config.background || config.Background
            visible: source != ""
            fillMode: config.ScaleImageCropped == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            cache: true
            clip: true
            mipmap: true
            z: 0
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: parent.forceActiveFocus()
        }
    }
}
