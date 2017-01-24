//
//  RoomModel.swift
//  uoat
//
//  Created by Pyro User on 18/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class RoomModel:NSObject, RoomManagerDelegate, NBMRendererDelegate
{
    convenience init(delegate:RoomReadyDelegate,video1View:UIView,video2View:UIView,video3View:UIView,video4View:UIView /*,video5View:UIView*/)
    {
        /*super.init()
        
        self.video1View = video1View
        self.video2View = video2View
        self.video3View = video3View
        self.video4View = video4View
        self.video5View = video5View
        
        self.mediaConfig = NBMMediaConfiguration.defaultConfiguration()
        self.mediaConfig!.cameraPosition = NBMCameraPosition.Front
        self.mediaConfig!.rendererType = .OpenGLES
        
        self.roomManager = RoomManager( delegate:self )
 */
        self.init( delegate:delegate,isReadingRoom:false, video1View:video1View, video2View:video2View, video3View:video3View, video4View:video4View /*, video5View:video5View*/ )
    }
    
    init(delegate:RoomReadyDelegate,isReadingRoom:Bool,video1View:UIView,video2View:UIView,video3View:UIView,video4View:UIView /*,video5View:UIView*/)
    {
        super.init()
        self.delegate = delegate
        self.isReadingRoom = isReadingRoom
        self.video1View = video1View
        self.video2View = video2View
        self.video3View = video3View
        self.video4View = video4View
        //self.video5View = video5View
        
        self.mediaConfig = NBMMediaConfiguration.defaultConfiguration()
        self.mediaConfig!.cameraPosition = NBMCameraPosition.Front
        self.mediaConfig!.rendererType = .OpenGLES
        
        self.roomManager = RoomManager( delegate:self )
    }
    
    deinit
    {
        self.mediaConfig = nil
        self.room = nil
        self.peerIdToRenderer.removeAll()
        self.roomManager = nil
        
        print("RoomModel - deInit....OK")
    }
    
    func joinRoom(userName:String, roomName:String)
    {
        //TODO: URL ROOM colocar en el PLIST?
        //Local:https://10.0.0.98:8443/room
        //Paas: https://a6f5c4869.apps.nubomedia-paas.eu/room
        let roomURL:NSURL = NSURL( string: "https://10.0.0.98:8443/room" )!
        self.room = NBMRoom( username:userName, roomName:roomName, roomURL:roomURL )
        
        self.roomManager = RoomManager( delegate:self )
        self.roomManager!.joinRoom( self.room!, withConfiguration:self.mediaConfig! )
    }
    
    func prepareBook(bookId:String,langId:String)
    {
        let request:[String:String]=["type":"1","bookId":bookId,"langId":langId]
        self.roomManager!.customRequest( request )
    }
    
    func requestBook()
    {
        let request:[String:String]=["type":"2"]
        self.roomManager!.customRequest( request )
    }
    
    func actionPage(action:String)
    {
        let request:[String:String]=["type":"3","action":action]
        self.roomManager!.customRequest( request )
    }
    
    func putAccesory(accesoryId:String, pack:String)
    {
        let request:[String:String]=["type":"4","accesory":accesoryId, "pack":pack]
        self.roomManager!.customRequest( request )
    }
    
    func getPacks()
    {
        let request:[String:String]=["type":"6"]
        self.roomManager!.customRequest( request )
    }

    func leaveRoom(callback:()->Void)
    {
        self.roomManager!.leaveRoom { (error) in
            callback()
        }
    }
    
    /*====================================================*/
    /*              From RoomManagerDelegate              */
    /*====================================================*/
    func roomManagerDidFinish(broker:RoomManager)
    {
        print("roomManager - 1")
    }
    
    func roomManager(broker:RoomManager, didAddLocalStream localStream:RTCMediaStream)
    {
        print("* roomManager - 2")
        //Aqui obtenemos el renderer.
        let renderer:NBMRenderer = self.rendererForStream( localStream )!
        
        self.peerIdToRenderer[(self.room?.localPeer.identifier)!] = renderer
        
        renderer.rendererView.frame = CGRect( x:0, y:0, width:self.video1View!.frame.width, height:self.video1View!.frame.height )
        self.video1View!.addSubview( renderer.rendererView )
        print(" -- RENDER VIEW BOUNDS:\(renderer.rendererView.bounds) \nFRAME:\(renderer.rendererView.frame)")
        
        //btn.addTarget(self, action: #selector(ViewController.ponerSombrero(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        /* Quitamos esto e añadimos un delegado.
        if( self.isReadingRoom )
        {
            //preparamos el libro.
            let bookId:String = Library.getInstance().getBook().getId()
            let langId:String = LanguageMgr.getInstance.getId()
            let request:[String:String]=["type":"1","bookId":bookId,"langId":langId]
            self.roomManager!.customRequest( request )
        }
        
        //pedimos los paquetes de disfraces.
        self.getPacks();
        */
        self.delegate?.onReady()
    }
    
    func roomManager(broker:RoomManager, didRemoveLocalStream localStream:RTCMediaStream)
    {
        print("roomManager - 3")
        let renderer:NBMRenderer = self.peerIdToRenderer.removeValueForKey((self.room?.localPeer.identifier)!)!
        renderer.videoTrack = nil
    }
    
    func roomManager(broker:RoomManager, didAddStream remoteStream:RTCMediaStream, ofPeer remotePeer:NBMPeer)
    {
        print("* roomManager - 4")
        
        let renderer:NBMRenderer = self.rendererForStream( remoteStream )!
        
        self.peerIdToRenderer[remotePeer.identifier] = renderer
        self.addRendererToVideoViewFree( renderer, id:remotePeer.identifier )
    }
    
    func roomManager(broker:RoomManager, didRemoveStream remoteStream:RTCMediaStream, ofPeer remotePeer:NBMPeer)
    {
        print("roomManager - 5")
        let renderer:NBMRenderer = self.peerIdToRenderer.removeValueForKey(remotePeer.identifier)!
        self.removeRendererFromVideoView( renderer )
    }
    
    func roomManager(broker:RoomManager, peerJoined peer:NBMPeer)
    {
        print("* roomManager - 6")
        self.updateVideoViews()
    }
    
    func roomManager(broker:RoomManager, peerLeft peer:NBMPeer)
    {
        print("* roomManager - 7")
        self.updateVideoViews()
    }
    
    func roomManager(broker:RoomManager, peerEvicted peer:NBMPeer)
    {
        print("roomManager - 8")
        
    }
    
    func roomManager(broker:RoomManager, roomJoined error:NSError?)
    {
        print("* roomManager - 9")
        if( error != nil )
        {
            print("Error:\(error?.description)")
        }
        else
        {
            //Refrescar las vistas de los videos.
            self.updateVideoViews()
        }
    }
    
    func roomManager(broker:RoomManager, messageReceived message:String, ofPeer peer:NBMPeer)
    {
        print("roomManager - 10")
        let pt:NBMPeer? = peer
        if( pt == nil || broker.localPeer().isEqual(peer))
        {
            print("Recibo mi mensaje....:D")
            print("...\(message)")
        }
        else
        {
            print("Mensaje recibido: \(message)")
            
            let str = message;
            let data:NSData = str.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: false )!
            do
            {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                print("JSON:\(json)")
                //TODO: subir esto a la clase correspondiente.
                
                let type:Int = json["type"] as! Int
                if( type == 3 )
                {
                    /*
                    let action:String = json["action"] as! String
                
                    if( action == "next" )
                    {
                        self.currentPage += 1
                        self.StoryLabel.text = self.storyText[self.currentPage]
                    }
                    else if( action == "prev" )
                    {
                        self.currentPage -= 1
                        self.StoryLabel.text = self.storyText[self.currentPage]
                    }
                    */
                    let msg:Message = Message( type:MessageType.remoteChangePage, data:json["data"] as! [String:AnyObject] )
                    Observer.getInstance.sendMessage( msg )
                }
            }
            catch let error as NSError
            {
                print("Failed to load JSON: \(error.localizedDescription)")
            }
        }
    }
    
    func roomManagerPeerStatusChanged(broker:RoomManager)
    {
        print("* roomManager - 11")
        self.updateVideoViews()
    }
    
    func roomManager(broker:RoomManager, didFailWithError error:NSError)
    {
        print("* roomManager - 12")
        print("ERROR: \(error.localizedDescription)")
    }
    
    func roomManager(broker:RoomManager, iceStatusChanged state:RTCICEConnectionState, ofPeer peer:NBMPeer)
    {
        print("roomManager - 13 - cambio de estado del peer \(peer.identifier) - state:\(self.stringForConnectionState(state))")
    }
    
    func roomManager(broker:RoomManager, didSentCustomRequest error:NSError, didResponse response:NBMResponse)
    {
        print("roomManager - 14 - recibo respuesta de customRequest...")
        
        if( !response.isEqual(nil) && response.result != nil)
        {
            let resp:[String:AnyObject] = response.result as! [String : AnyObject]
            print("RESULT:\(resp)")
            if let _=resp["type"]
            {
                let type:Int = resp["type"] as! Int
                
                switch( type )
                {
                    case 1: //Prepare book response.
                        //do nothing.
                        break
                    
                    case 2: //Request book.
                        let msg:Message = Message( type:MessageType.syncBook, data:resp["data"] as! [String:AnyObject] )
                        Observer.getInstance.sendMessage( msg )
                        break

                    case 3: //Page activity.
                        //do nothing.
                        break

                    case 4: //Accesorie to show (AR Object).
                        //do nothing.
                        break
                    
                    case 6: //Get packs.
                        //do nothing.
                        break
                    
                    default:
                        break
                }
            }
        }
    }
    
    /*====================================================*/
    /*              From NBMRendererDelegate              */
    /*====================================================*/
    //- (void)renderer:(id<NBMRenderer>)renderer streamDimensionsDidChange:(CGSize)dimensions;
    func renderer(renderer:NBMRenderer, streamDimensionsDidChange dimensions:CGSize)
    {
        print("renderer...")
    }
    
    //- (void)rendererDidReceiveVideoData:(id<NBMRenderer>)renderer;
    func rendererDidReceiveVideoData(renderer: NBMRenderer!)
    {
        print("rendererDidReceiveVideoData...")
    }
    
    
    /*====================================================*/
    /*                    Private Section                 */
    /*====================================================*/
    private func rendererForStream(stream:RTCMediaStream) -> NBMRenderer?
    {
        var renderer:NBMRenderer? = nil
        let videoTrack:RTCVideoTrack = stream.videoTracks.first as! RTCVideoTrack
        let rendererType:NBMRendererType = self.mediaConfig!.rendererType
        
        if( rendererType == .OpenGLES )
        {
            renderer = NBMEAGLRenderer(delegate: self)
        }
        
        renderer?.videoTrack = videoTrack
        
        return renderer
    }
    
    private func updateVideoViews()
    {
        let remotePeersCount:Int = (self.roomManager?.remotePeers().count)!
        print("REMOTE PEERS: \(remotePeersCount)")
        
        //Videos
        for remotePeer:NBMPeer in (self.roomManager?.remotePeers())!
        {
            let renderer:NBMRenderer? = self.peerIdToRenderer[remotePeer.identifier]
            if( renderer != nil )
            {
                self.addRendererToVideoViewFree( renderer!, id:remotePeer.identifier )
            }
        }
    }
    
    private func addRendererToVideoViewFree( renderer:NBMRenderer, id:String )
    {
        if( self.video2View!.subviews.count == 0 )
        {
            renderer.rendererView.frame = CGRect( x:0, y:0, width:self.video2View!.frame.width, height:self.video2View!.frame.height )
            self.video2View!.addSubview( renderer.rendererView )
            
            let userIdLabel:UILabel = self.createUserIdLabel( id )
            self.video2View!.addSubview( userIdLabel );
        }
        else if( self.video3View!.subviews.count == 0 )
        {
            renderer.rendererView.frame = CGRect( x:0, y:0, width:self.video3View!.frame.width, height:self.video3View!.frame.height )
            self.video3View!.addSubview( renderer.rendererView )
            
        }
        else if( self.video4View!.subviews.count == 0 )
        {
            renderer.rendererView.frame = CGRect( x:0, y:0, width:self.video4View!.frame.width, height:self.video4View!.frame.height )
            self.video4View!.addSubview( renderer.rendererView )
            
        }
/*
        else if( self.video5View!.subviews.count == 0 )
        {
            renderer.rendererView.frame = CGRect( x:0, y:0, width:self.video5View!.frame.width, height:self.video5View!.frame.height )
            self.video5View!.addSubview( renderer.rendererView )
        }
*/
    }
    
    private func removeRendererFromVideoView(renderer:NBMRenderer)
    {
        if( existsRendererInView( renderer, view:self.video2View! ) )
        {
            self.resetVideoView( self.video2View! )
        }
        else if( existsRendererInView( renderer, view:self.video3View! ) )
        {
            self.resetVideoView( self.video3View! )
        }
        else if( existsRendererInView( renderer, view:self.video4View! ) )
        {
            self.resetVideoView( self.video4View! )
        }
/*
        else if( existsRendererInView( renderer, view:self.video5View! ) )
        {
            self.resetVideoView( self.video5View! )
        }
*/
    }
    
    private func existsRendererInView(renderer:NBMRenderer, view:UIView) -> Bool
    {
        let subviews:[UIView] = view.subviews
        
        var found:Bool = false
        for subview in subviews
        {
            if( subview == renderer.rendererView )
            {
                found = true
            }
        }
        
        return found
    }
    
    private func resetVideoView( view:UIView )
    {
        let subviews:[UIView] = view.subviews
        for subview in subviews
        {
            subview.removeFromSuperview()
        }
    }
    
    private func createUserIdLabel(id:String) -> UILabel
    {
        let label = UILabel()
        
        label.text = id
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        
        return label
    }
    
    private func stringForConnectionState(state:RTCICEConnectionState) -> String
    {
        switch (state)
        {
        case RTCICEConnectionNew:
            return "New"
        case RTCICEConnectionChecking:
            return "Checking"
        case RTCICEConnectionConnected:
            return "Connected"
        case RTCICEConnectionCompleted:
            return "Completed"
        case RTCICEConnectionFailed:
            return "Failed"
        case RTCICEConnectionDisconnected:
            return "Disconnected"
        case RTCICEConnectionClosed:
            return "Closed"
        default:
            return "Other state"
        }
    }
    private weak var delegate:RoomReadyDelegate? = nil
    private var isReadingRoom:Bool = false
    
    private weak var video1View:UIView? = nil
    private weak var video2View:UIView? = nil
    private weak var video3View:UIView? = nil
    private weak var video4View:UIView? = nil
    //private weak var video5View:UIView? = nil
    
    private var room:NBMRoom? = nil
    private var roomManager:RoomManager? = nil
    private var mediaConfig:NBMMediaConfiguration? = nil
    private var peerIdToRenderer:[String:NBMRenderer] = [String:NBMRenderer]()
    
}