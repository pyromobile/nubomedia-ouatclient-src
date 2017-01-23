import QtQuick 2.0
import VPlay 2.0
import QtGraphicalEffects 1.0
import "../ui"

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
    //1.Properties.    id:endTaleDialog
    width: readScene.gameWindowAnchorItem.width
    height:readScene.gameWindowAnchorItem.height
    anchors.centerIn: parent

    visible: opacity === 0 ? false : true
    enabled: visible


    //---------------------------------------------------------------------------
    //2.Signals.
    signal restartTalePressed
    signal goLibraryPressed
    signal backMainMenuPressed


    //---------------------------------------------------------------------------
    //4.Components.
    Behavior on opacity {
        NumberAnimation { duration: 150}
    }

    Rectangle {
        color:"black"
        anchors.fill: parent
        opacity: 0.7
    }

    MouseArea {
      anchors.fill: parent
    }

    Rectangle {
        anchors.centerIn: parent

        MultiResolutionImage {
            id:imageBackgroundPopup
            source: "../../../assets/images/bg_popups.png"
            anchors.centerIn: parent
        }

        DropShadow {
            anchors.fill: imageBackgroundPopup
            horizontalOffset: 15
            verticalOffset: 15
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: imageBackgroundPopup
        }

        MultiResolutionImage {
            id:headerPopup
            source: "../../../assets/images/header_login.png"
            anchors.left: imageBackgroundPopup.left
            anchors.top: imageBackgroundPopup.top
        }

        Text {
            id:headerTextPopup
            text:"The End"
            color:"#AC5538"
            font.family: roundedBoldFont.name
            font.pixelSize: 28
            anchors.verticalCenter: headerPopup.verticalCenter
            anchors.horizontalCenter: headerPopup.horizontalCenter
        }

        Column
        {
            anchors.centerIn: imageBackgroundPopup
            spacing: imageBackgroundPopup.height * 0.10

            MyButton2 {
                id:restartTaleButton
                normal: "../../../assets/images/btn_gui_normal.png"
                pressed: "../../../assets/images/btn_gui_pressed.png"
                labelText: "Restart tale"
                labelTextSize: 16
                labelAnchors.verticalCenterOffset: -4
                width:215
                height:44
                onClicked: restartTalePressed()
            }

            MyButton2 {
                id:goLibraryButton
                normal: "../../../assets/images/btn_gui_main_normal.png"
                pressed: "../../../assets/images/btn_gui_main_pressed.png"
                labelText: "Choose other tale"
                labelTextSize: 16
                labelAnchors.verticalCenterOffset: -4
                width:215
                height:44
                onClicked: goLibraryPressed()
            }

            MyButton2 {
                id:backMainMenu
                normal: "../../../assets/images/btn_gui_main_normal.png"
                pressed: "../../../assets/images/btn_gui_main_pressed.png"
                labelText: "Back main menu"
                labelTextSize: 16
                labelAnchors.verticalCenterOffset: -4
                width:215
                height:44
                onClicked: backMainMenuPressed()
            }
        }
    }
}
