import QtQuick 2.0
import VPlay 2.0

/*
   NOTA: QML file structure.
   1. Properties.
   2. Signals.
   3. Signal Handlers.
   4. Compoments.
   5. Functions.
*/

Item {
    //---------------------------------------------------------------------------
    //1.Properties.
    id:myButton2
    width: 100
    height: 50

    property string normal:""
    property string pressed:""
    property alias labelText: label.text
    property alias labelTextSize: label.font.pixelSize
    property alias labelAnchors: label.anchors


    //---------------------------------------------------------------------------
    //2.Signals.
    signal clicked


    //---------------------------------------------------------------------------
    //4.Components.
    MultiResolutionImage {
        id:image
        source: mouseArea.pressed ? pressed : normal
        //anchors.fill: parent
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id:label
        text: "?????"
        font.family: roundedBoldFont.name
        font.pixelSize: 10
        color: "white"
        //anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -5
    }

    MouseArea {
        id:mouseArea
        anchors.fill: parent
        onClicked: {
            myButton2.clicked()
        }
    }
}
