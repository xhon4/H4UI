//
// Wrapper del InputPanel nativo de Qt -- el estilo del teclado en sí lo
// define el estilo QtQuick.VirtualKeyboard del sistema, no hay mucho para
// re-skinnear acá sin meterse con QtQuick.Controls.Style global.
//

import QtQuick 2.11
import QtQuick.VirtualKeyboard 2.3

InputPanel {
    id: virtualKeyboard
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
}
