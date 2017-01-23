import VPlay 2.0
import QtQuick 2.0
import QtQml 2.2
import QtQuick.Window 2.2
import "./scenes"
/*
   NOTA: QML file structure.
   1. Properties.
   2. Signals.
   3. Signal Handlers.
   4. Compoments.
   5. Functions.
*/

GameWindow {
  //---------------------------------------------------------------------------
  //1.Properties.
  id: gameWindow
  screenWidth: 1024
  screenHeight: 768

  state: "mainMenu"

  states: [
      State {
        name: "mainMenu"
        PropertyChanges {target: mainScene; opacity: 1}
        PropertyChanges {target: gameWindow; activeScene: mainScene}
      },
      State {
        name: "library"
        PropertyChanges {target: libraryScene; opacity: 1}
        PropertyChanges {target: gameWindow; activeScene: libraryScene}
      },
      State {
        name: "readTale"
        PropertyChanges {target: readScene; opacity: 1}
        PropertyChanges {target: gameWindow; activeScene: readScene}
      }
  ]

  property string currentBookId: ""
  property string language: "en"    //Default language
  property real porcentage: 1.0

  //---------------------------------------------------------------------------
  //3.Signal Handlers.
  onSplashScreenFinished: {
      activeScene.showButtons(true)
      activeScene.buttonsIsHidden = false;
  }



  //---------------------------------------------------------------------------
  //4.Compoments.
//  Rectangle {
//    width: gameWindow.width
//    height: gameWindow.height
//    color: "red"
//  }

  MainScene {
    id:mainScene

    property bool buttonsIsHidden: false

    onOpacityChanged: {
        if( buttonsIsHidden && mainScene.opacity == 1 )
        {
            console.log(mainScene.opacity);
            mainScene.showButtons(true);
            buttonsIsHidden = false;
        }
    }

    onReadTaleButtonPressed: {
        activeScene.showButtons(false)
    }
    onChangeState: {
        gameWindow.state = "library"
        buttonsIsHidden = true;
    }
  }

  LibraryScene {
      id:libraryScene

      onChooseTalePressed: {
          currentBookId = bookId;
          readScene.setCurrentBook( bookId );
          gameWindow.state = "readTale";
      }
  }

  ReadScene {
      id:readScene

      onShowLibrary: {
          gameWindow.state = "library";
      }
      onShowMainMenu: {
          gameWindow.state = "mainMenu";
      }
  }

  FontLoader {
    id: roundedBoldFont
    source: "../assets/fonts/Arial-Rounded-MT-Bold.ttf"
  }

  Component.onCompleted: {
      var sysLang = Qt.locale().name.substring(0,2);
      var suportedLangs = ["en","es","de"];

      for( var i=0; i<suportedLangs.length; i++)
      {
        if( suportedLangs[i] === sysLang )
            language = sysLang;
      }
      console.log( "CURRENT_LANGUAGE:"+language );

      console.log( "Window Size: w:" + Screen.width + " - h:" + Screen.height );
      console.log( "Window ratio:" + Screen.devicePixelRatio );
      var myRatio = Screen.width/Screen.height;
      console.log( "Window myratio:" + myRatio );
      var designRatio = 1024/768;
      console.log( "Window design ratio:" +  designRatio );

      var porcentage = myRatio/designRatio;
      console.log("PORCENTAGE="+porcentage);

  }
}
