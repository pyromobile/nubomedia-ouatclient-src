import VPlay 2.0
import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../common"
import "../common/ui"
import "../common/dialogs"
import "../"
import "../Book.js" as Book

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
    id:readScene

    //property string bookId:""
    property var book:null
    property bool isFirstTime:true
    property bool isTranstionWorking:false

    //---------------------------------------------------------------------------
    //2.Signals.
    signal showLibrary
    signal showMainMenu


    //---------------------------------------------------------------------------
    //3.Signal Handlers.
//    onOpacityChanged: {
//        console.log("libraryScene - CurrentBookId:"+bookId);
//        book = Book.create();
//        book.load( bookId, 'en' ,function(pageToShow){
//            updateView( pageToShow );
//        });
//    }


    //---------------------------------------------------------------------------
    //4.Components.
    Image {
        id:backgroundTalePage
        source: ""
        anchors.centerIn: readScene
        z:-1
    }

    Image {
        id:menu
        source: "../../assets/images/btn_menu.png"
        anchors.left: readScene.left
        anchors.top:readScene.top
        width:34
        height:35

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if( menuDialog.opacity == 0 )
              menuDialog.opacity = 1
            else
                menuDialog.opacity = 0
          }
        }
    }

    Rectangle{
        id:containerCurrentPage
        anchors.horizontalCenter: parent.horizontalCenter
        height:parent.height * 0.9 * (1/gameWindow.porcentage)
        width:parent.width * 0.9 * (1/gameWindow.porcentage)
        opacity: 1
        smooth: true

        property var callback

        signal fadeoutFinished()

        Image {
            id:imageCurrentPage
            anchors.fill: containerCurrentPage
            source: ""
        }

        DropShadow {
            anchors.fill: imageCurrentPage
            horizontalOffset: 15
            verticalOffset: 15
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: imageCurrentPage
        }

        NumberAnimation {
            id:fadeoutCurrentImage
            target:containerCurrentPage
            properties:"opacity"
            from:1
            to:0.4
            duration: 750
            onStopped: {
                containerCurrentPage.fadeoutFinished()
            }
        }
        NumberAnimation {
            id:fadeinCurrentImage
            target:containerCurrentPage
            properties:"opacity"
            from:0.2
            to:1
            duration: 750
        }

        Component.onCompleted: {
            containerCurrentPage.fadeoutFinished.connect(doCallback)
        }

        function setCallback( _callback )
        {
            callback = _callback;
        }

        function doCallback()
        {
            callback();
        }
    }

    Rectangle{
        id:textArea
        color:"white"
        anchors.left: containerCurrentPage.left
        anchors.bottom: parent.bottom
        anchors.right: containerCurrentPage.right
        height: parent.height * ( 1 -  0.9 * (1/gameWindow.porcentage) )

        MyButton2 {
            id:btnLeft
            normal: "../../../assets/images/btn_next_available.png"
            pressed: "../../../assets/images/btn_next_available.png"
            width:17
            height:26
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            scale: -1
            labelText: ""
            onClicked: {
                console.log("Press left button...");
                doPrevPage();
            }
        }

        Text {
            id: taleText
            anchors.left:btnLeft.right
            anchors.leftMargin: 20
            anchors.right: btnRight.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 22
            color: "black"
            width:parent.width
            text: "XXXXXX"
            wrapMode:Text.WordWrap
        }

        MyButton2 {
            id:btnRight
            normal: "../../../assets/images/btn_next_available.png"
            pressed: "../../../assets/images/btn_next_available.png"
            width:17
            height:26
            anchors.right:parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            labelText: ""
            onClicked: {
                console.log("Press right button...");
                doNextPage();
            }
        }
    }

    Timer {
        id:moveRelease
        interval: isTranstionWorking ? 1500 : 750
    }

    MouseArea {
        id:swiftArea
        anchors.fill: containerCurrentPage //readScene.gameWindowAnchorItem

        property int startX
        property string direction
        property bool moving:false

        onPressed: {
            startX = mouse.x
            moving = false
        }

        onReleased: {
            moving = false
        }

        onPositionChanged: {
            var deltaX = mouse.x - startX
            if( moving === false )
            {
                if( Math.abs(deltaX) > 40 )
                {
                    moving = true;
                }

                if( deltaX > 30 && moveRelease.running === false )
                {
                    doPrevPage();
                    moveRelease.start()
                }
                else if( deltaX < -30 && moveRelease.running == false )
                {
                    doNextPage();
                    moveRelease.start()
                }
            }
        }
    }


    DropShadow {
        anchors.fill: textArea
        horizontalOffset: 15
        verticalOffset: 15
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: textArea
    }

    FastBlur {
        id:blurimg
        anchors.fill: backgroundTalePage
        source: backgroundTalePage
        radius: 50
        z:-1
    }

    MenuDialog{
        id:menuDialog
        opacity: 0
        onChooseLanguagePressed: showLanguageDialog(menuDialog)
        onGoLibraryPressed: goLibrary(menuDialog)
        onBackMainMenuPressed: backMainMenu(menuDialog)
    }


    EndTaleDialog{
        id:endTaleDialog
        opacity: 0        
        onRestartTalePressed : restartTale(endTaleDialog)
        onGoLibraryPressed: goLibrary(endTaleDialog)
        onBackMainMenuPressed: backMainMenu(endTaleDialog)
    }

    LanguageDialog{
        id:languageDialog
        opacity: 0
        onChooseLanguagePressed:{
            changeTaleLanguage(languageId)
            languageDialog.opacity = 0
        }
    }


    //---------------------------------------------------------------------------
    //5.Functions.
    function setCurrentBook( currentBookId )
    {
        var languageId = gameWindow.language;
        book = Book.create();
        book.onLoaded = function(pageToShow)
        {
            updateView( pageToShow );
        };
        book.load( currentBookId, languageId );
    }

    function doPrevPage()
    {
        if( !book.isAtFirstPage() )
        {
            var pageToShow = book.prevPage();
            updateView( pageToShow );
        }
    }

    function doNextPage()
    {
        console.log("HEIGHT-IMG:"+containerCurrentPage.height + " -- HEIGHT-TEXT:"+textArea.height)
        if( !book.isAtLastPage() )
        {
            var pageToShow = book.nextPage();
            updateView( pageToShow );
        }
        else
        {
            endTaleDialog.opacity = 1
        }
    }

    function updateView(pageToShow)
    {
        if( pageToShow.isChangeImage )
        {
            backgroundTalePage.source = '../../assets/tales/'+pageToShow.image;

            if( !isFirstTime )
            {
                isTranstionWorking = true;
                fadeoutCurrentImage.start();
                containerCurrentPage.setCallback(function(){
                    imageCurrentPage.source = '../../assets/tales/'+pageToShow.image;
                    fadeinCurrentImage.start();
                    isTranstionWorking = false;
                });
            }
            else
            {
                isFirstTime = false;
                imageCurrentPage.source = '../../assets/tales/'+pageToShow.image;
            }
        }

        taleText.text = pageToShow.text;
    }

    function showLanguageDialog(currentDialog)
    {
        currentDialog.opacity = 0;
        languageDialog.opacity = 1;
    }

    function goLibrary(currentDialog)
    {
        releaseSceneState( currentDialog );
        readScene.showLibrary();
    }

    function backMainMenu(currentDialog)
    {
        releaseSceneState( currentDialog );
        readScene.showMainMenu();
    }

    function restartTale(currentDialog)
    {
        currentDialog.opacity = 0;

        var pageToShow = book.goBegin();
        updateView( pageToShow );
    }

    function releaseSceneState(currentDialog)
    {
        isFirstTime = true;
        book = null;
        currentDialog.opacity = 0;
    }

    function changeTaleLanguage(languageId)
    {
        book.requestChangeLanguage( languageId );
    }
}
