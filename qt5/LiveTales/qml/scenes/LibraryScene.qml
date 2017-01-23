import VPlay 2.0
import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../common"
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
    id:libraryScene


    //---------------------------------------------------------------------------
    //2.Signals.
    signal chooseTalePressed(string bookId)


    //---------------------------------------------------------------------------
    //4.Components.
    Image {
        id:background
        source: "../../assets/images/logo_splash_screen.jpg"
        anchors.centerIn: libraryScene
        z:-2
    }

    MultiResolutionImage {
        id:header
        source: "../../assets/images/bg_header_main.png"
        anchors.left: libraryScene.gameWindowAnchorItem.left
        anchors.top: libraryScene.gameWindowAnchorItem.top
        anchors.right: libraryScene.gameWindowAnchorItem.right
        height:libraryScene.dp(51)
        fillMode: Image.PreserveAspectFit
    }

    MultiResolutionImage {
        id:backgroundLibrary
        source: "../../assets/images/bg_library.png"
        anchors.fill: libraryScene
        z:-1
    }

    MultiResolutionImage {
        id:shelf_library1
        source: "../../assets/images/shelf_library.png"
        height: 100
        anchors.top: backgroundLibrary.top
        anchors.topMargin: 260
        anchors.left: backgroundLibrary.left
        anchors.right: backgroundLibrary.right
    }

    MultiResolutionImage {
        id:bookCover1
        source: "../../assets/images/book_cover_1.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: backgroundLibrary.left
        anchors.leftMargin: 20

        MouseArea {
            id:mouseAreaBookCover1
            anchors.fill: parent
            onClicked: chooseTalePressed('03_cr')
        }
    }

    MultiResolutionImage {
        id:bookCover2
        source: "../../assets/images/book_cover_2.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: bookCover1.right
        anchors.leftMargin: 16

        MouseArea {
            id:mouseAreaBookCover2
            anchors.fill: parent
            onClicked: chooseTalePressed('02_l3c')
        }
    }

    MultiResolutionImage {
        id:bookCover3
        source: "../../assets/images/book_cover_3.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: bookCover2.right
        anchors.leftMargin: 16

        MouseArea {
            id:mouseAreaBookCover3
            anchors.fill: parent
            onClicked: chooseTalePressed('01_rdo')
        }
    }

    MultiResolutionImage {
        id:bookCoverEmpty1
        source: "../../assets/images/book_cover_0.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: bookCover3.right
        anchors.leftMargin: 16
    }

    MultiResolutionImage {
        id:bookCoverEmpty2
        source: "../../assets/images/book_cover_0.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: bookCoverEmpty1.right
        anchors.leftMargin: 16
    }

    MultiResolutionImage {
        id:bookCoverEmpty3
        source: "../../assets/images/book_cover_0.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library1.top
        anchors.left: bookCoverEmpty2.right
        anchors.leftMargin: 16
    }

    MultiResolutionImage {
        id:shelf_library2
        source: "../../assets/images/shelf_library.png"
        height: 100
        anchors.top: shelf_library1.bottom
        anchors.topMargin: 145
        anchors.left: backgroundLibrary.left
        anchors.right: backgroundLibrary.right
    }

    MultiResolutionImage {
        id:bookCoverEmpty13
        source: "../../assets/images/book_cover_0.png"
        height: 180
        width: 150
        anchors.bottom: shelf_library2.top
        anchors.left: backgroundLibrary.left
        anchors.leftMargin: 20
    }

    MultiResolutionImage {
        id:footer
        source: "../../assets/images/bg_footer.png"
        anchors.left: libraryScene.gameWindowAnchorItem.left
        anchors.bottom: libraryScene.gameWindowAnchorItem.bottom
        anchors.right: libraryScene.gameWindowAnchorItem.right
        height: Utils.dp(77)
    }

    FastBlur {
        anchors.fill: background
        source: background
        radius: 50
        z:-2
    }
}
