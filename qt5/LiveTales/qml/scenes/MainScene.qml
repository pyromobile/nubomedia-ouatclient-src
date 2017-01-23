import VPlay 2.0
import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../common"
import "../common/ui"
import "../"

/*
   NOTA: QML file structure.
   1. Properties.
   2. Signals.
   3. Signal Handlers.
   4. Compoments.
   5. Functions.
*/

SceneBase {
    //---------------------------------------------------------------------------
    //1.Properties.
    id:mainScene

    //---------------------------------------------------------------------------
    //2.Signals.
    signal readTaleButtonPressed
    signal changeState


    //---------------------------------------------------------------------------
    //4.Components.
    Image {
        id:background
        source: "../../assets/images/logo_splash_screen.jpg"
        anchors.centerIn: mainScene
        z:-1
    }

    MultiResolutionImage {
        id:header
        source: "../../assets/images/bg_header_main.png"
        anchors.left: mainScene.gameWindowAnchorItem.left
        anchors.top: mainScene.gameWindowAnchorItem.top
        anchors.right: mainScene.gameWindowAnchorItem.right
        height:mainScene.dp(51)
        fillMode: Image.PreserveAspectFit
    }

    MyButton2 {
        id:readTaleButton
        normal: "../../../assets/images/btn_gui_main_normal.png"
        pressed: "../../../assets/images/btn_gui_main_pressed.png"
        width:mainScene.dp(350)
        height:mainScene.dp(75)
        x:-350
        y:mainScene.height/2 - readTaleButton.height/2
        labelText: "Read Tale"
        labelTextSize: mainScene.sp(20)
        labelAnchors.verticalCenterOffset: -5
        onClicked: readTaleButtonPressed()
    }

    SequentialAnimation {
        id:imageAnimationEnter

        //First animation.
        NumberAnimation {
            target:readTaleButton
            property:"x"
            from:-350
            to:mainScene.width/2 - readTaleButton.width/2
            duration: 750
        }
    }

    SequentialAnimation {
        id:imageAnimationExit

        onStopped: changeState()

        //First animation.
        NumberAnimation {
            target:readTaleButton
            property:"x"
            from: mainScene.width/2 - readTaleButton.width/2
            to: -350
            duration: 750
        }
    }

    MultiResolutionImage {
        id:footer
        source: "../../assets/images/bg_footer.png"
        anchors.left: mainScene.gameWindowAnchorItem.left
        anchors.bottom: mainScene.gameWindowAnchorItem.bottom
        anchors.right: mainScene.gameWindowAnchorItem.right
        height: mainScene.dp(77)
        fillMode: Image.PreserveAspectFit

        Row {
           anchors.verticalCenter: footer.top
           anchors.horizontalCenter: footer.horizontalCenter
           spacing: 10

           MyButton2 {
               normal: "../../../assets/images/btn_collections.png"
               pressed: "../../../assets/images/btn_collections.png"
               width:mainScene.dp(90)
               height:mainScene.dp(90)
               labelText: ""
               onClicked: {
                   console.log("PULSADO");
               }
           }

           MyButton2 {
               normal: "../../../assets/images/btn_info.png"
               pressed: "../../../assets/images/btn_info.png"
               width:mainScene.dp(90)
               height:mainScene.dp(90)
               labelText: ""
               onClicked: {
                   console.log("PULSADO");
               }
           }

        }
    }

    FastBlur {
        anchors.fill: background
        source: background
        radius: 50
        z:-1
    }

    //-------------------------------------------------------------------------
    //5.Functions.
    function showButtons(show)
    {
        if( show )
            imageAnimationEnter.start()
        else
            imageAnimationExit.start()
    }
}
