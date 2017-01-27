//
//  RoomManager.swift
//  uoat
//
//  Created by Pyro User on 18/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

//NOTA: Para usar protocolos parece que tenemos que hederar de alguna clase.
class RoomManager:NSObject, NBMWebRTCPeerDelegate, NBMRoomClientDelegate
{
    /*====================================================*/
    /*                      Properties                    */
    /*====================================================*/
    var connected:Bool
    {
        return self.isConnected()
    }
    
    var joined:Bool
    {
        return self.isJoined()
    }
    
    
    /*====================================================*/
    /*                      Class API                     */
    /*====================================================*/
    init( delegate:RoomManagerDelegate )
    {
        self.delegate = delegate
        self.config = nil
        self.roomClient = nil
        self.retryCount = 0
        self.mutableRemoteStreams = [RTCMediaStream]()
        self.loopBack = false
    }
    
    deinit
    {
        self.config = nil
        self.roomClient = nil
        self.mutableRemoteStreams.removeAll()
        print("RoomManager - deInit....OK")
    }
    
    func joinRoom( room:NBMRoom, withConfiguration config:NBMMediaConfiguration )
    {
        self.config = config
        
        self.setupRoomClient( room )
        self.setupReachability()
        self.setupWebRTCSession()
    }
    
    //-(void)leaveRoom:(void (^)(NSError *))block
    //func leaveRoom( block:((error:NSError)->Void)? )
    func leaveRoom(block:(NSError! ->())!)
    {
        self.roomClient?.leaveRoom({ (error:NSError!) in
            if( block != nil )
            {
                block( error )
            }
        })
    }
    
    func remotePeers() -> [NBMPeer]
    {
        var peerAux:[NBMPeer] = [NBMPeer]()
        
        if( self.roomClient?.peers != nil )
        {
            //let remotePeers:Set<NSObject> = (self.roomClient!.peers)!
            let remotePeers:[AnyObject] = (self.roomClient!.peers)!
            for obj:AnyObject in remotePeers
            {
                if( obj is NBMPeer )
                {
                    let peer:NBMPeer = obj as! NBMPeer
                    peerAux.append( peer )
                }
            }
        }
        return peerAux
    }
    
    func customRequest(request:[String:String])
    {
        self.roomClient!.sendCustomRequest(request)
    }
    
    /*====================================================*/
    /*             From NBMWebRTCPeerDelegate             */
    /*====================================================*/
    func webRTCPeer(peer:NBMWebRTCPeer, didGenerateOffer sdpOffer:RTCSessionDescription, forConnection connection:NBMPeerConnection!)
    {
        print("* webRTC - 1")
        let localConnection:NBMPeerConnection? = self.connectionOfPeer( self.localPeer() )
        if( connection.isEqual(localConnection) )
        {
            self.roomClient?.publishVideo(sdpOffer.description, loopback: true, completion: { [weak self](sdpAnswer:String!, error:NSError!) -> Void in
                self?.webRTCPeer?.processAnswer( sdpAnswer, connectionId:connection.connectionId )
            })
        }
        else
        {
            let remotePeer:NBMPeer = self.peerOfConnection( connection )!
            self.roomClient?.receiveVideoFromPeer(remotePeer, offer: sdpOffer.description, completion: { [weak self](sdpAnswer:String!, error:NSError!) -> Void in
                self?.webRTCPeer?.processAnswer(sdpAnswer, connectionId: connection.connectionId)
            })
        }
    }
    
    func webRTCPeer(peer:NBMWebRTCPeer, didGenerateAnswer sdpAnswer:RTCSessionDescription, forConnection connection:NBMPeerConnection)
    {
        print("webRTC - 2")
    }
    
    func webRTCPeer(peer:NBMWebRTCPeer, hasICECandidate candidate:RTCIceCandidate, forConnection connection:NBMPeerConnection)
    {
        print("* webRTC - 3")
        let remotePeer:NBMPeer = self.peerOfConnection( connection )!
        self.roomClient?.sendICECandidate(candidate, forPeer: remotePeer)
    }
    
    func webrtcPeer(peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, ofConnection connection: NBMPeerConnection!)
    {
        print("* webRTC - 4")
        switch( state )
        {
        case .New,
             .Checking,
             .Completed,
             .Connected:
            break;
            
        case .Count,
             .Closed:
            self.webRTCPeer?.closeConnectionWithConnectionId(connection.connectionId)
            break;
            
        case .Disconnected:
            // We had an active connection, but we lost it.
            // Recover with an ice-restart?
            //    let closeConnection:Bool = !self.reachability.isReachable
            //    if( closeConnection )
            //    {
            //        self.webRTCPeer?.closeConnectionWithConnectionId(connection.connectionId)
            //    }
            break;
            
        case .Failed:
            // The connection failed during the ICE candidate phase.
            // While the peer is available on the signaling server we should retry with an ice-restart.
            //let canAttemptRestart:Bool = connection.iceAttempts <= self.kConnectionMaxIceAttempts //&& self.isConnected()
            
            //let restartICE:Bool = isInitiator && peerReachable && canAttemptRestart
            //let closeConnection = !peerReachable || !canAttemptRestart
            
            self.webRTCPeer?.closeConnectionWithConnectionId(connection.connectionId)
            //            if (canAttemptRestart) {
            //                DDLogDebug(@"Should restart ICE?");
            //                if ([connection.connectionId isEqualToString:[self localConnectionId]]) {
            //                    [self unpublishVideo:^(NSError *error) {
            //
            //                    }];
            //                }
            ////                [self restoreConnections];
            //                //[self safeICERestartForConnection:connection];
            //                //[self.webRTCPeer generateOffer:connection.connectionId];
            //            }
            //            else {
            //                [self.webRTCPeer closeConnectionWithConnectionId:connection.connectionId];
            //            }
            
            if( self.isConnected() && self.mutableRemoteStreams.count == 0 )
            {
                let iceFailedError:NSError = NSError(domain: "com.zed.nubomedia.uoat", code: 0, userInfo: ["key3":"Connection failed during ICE candidate phase"])
                self.delegate!.roomManager(self, didFailWithError: iceFailedError)
            }
            break;
        default:
            break
        }
        
        if let remotePeer:NBMPeer = self.peerOfConnection(connection)
        {
            //let remotePeer:NBMPeer = self.peerOfConnection(connection)!
            self.delegate!.roomManager(self, iceStatusChanged: state, ofPeer: remotePeer)
        }
    }
    
    func webRTCPeer(peer:NBMWebRTCPeer!, didAddStream remoteStream:RTCMediaStream, ofConnection connection:NBMPeerConnection!)
    {
        print("* webRTC - 5")
        self.mutableRemoteStreams.append(remoteStream)
        let remotePeer:NBMPeer = self.peerOfConnection(connection)!
        if( remotePeer.isEqual( self.localPeer() ) && !self.loopBack )
        {
            //Mute audio track to avoid sound overlap.
            for audioTrack:RTCAudioTrack in remoteStream.audioTracks
            {
                //audioTrack.setEnabled(false)
                audioTrack.isEnabled = false
            }
            
            dispatch_async( dispatch_get_main_queue(), { [weak self]() -> Void in
                self?.delegate!.roomManager(self!, didAddLocalStream: remoteStream )
            })
            
            return;
        }
        self.delegate!.roomManager(self, didAddStream: remoteStream, ofPeer: remotePeer)
    }
    
    func webRTCPeer(peer:NBMWebRTCPeer, didRemoveStream remoteStream:RTCMediaStream, ofConnection connection:NBMPeerConnection)
    {
        print("* webRTC - 6")
        let position:Int = self.mutableRemoteStreams.indexOf( remoteStream )!
        self.mutableRemoteStreams.removeAtIndex( position )
        
        let remotePeer:NBMPeer? = self.peerOfConnection( connection )
        if( remotePeer == nil )
        {
            //peer has left
            return
        }
        self.delegate!.roomManager( self, didRemoveStream:remoteStream, ofPeer:remotePeer! )
    }
    
    //- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddDataChannel:(RTCDataChannel *)dataChannel ofConnection:(NBMPeerConnection *)connection;
    func webRTCPeer(peer:NBMWebRTCPeer, didAddDataChannel dataChannel:RTCDataChannel, ofConnection connection:NBMPeerConnection)
    {
        
    }
    
    /*====================================================*/
    /*             From NBMRoomClientDelegate             */
    /*====================================================*/
    //------------------------------------------------------
    // Connection
    func client(client:NBMRoomClient, isConnected connected:Bool)
    {
        print("* client - 1")
        if( connected )
        {
            self.retryCount = 0
            if( !self.isJoined() )
            {
                self.joinToRoom()
            }
        }
        else
        {
            self.manageRoomClientConnection()
        }
    }
    
    func client(client:NBMRoomClient, didFailWithError error:NSError)
    {
        print("* client - 2")
        //deal with timeout connection
        self.delegate!.roomManager( self, didFailWithError:error )
    }
    
    //------------------------------------------------------
    // Room API
    func client(client:NBMRoomClient, didJoinRoom error:NSError!)
    {
        print("* client - 3")
        self.delegate!.roomManager( self, roomJoined:error )
        
        //publish video
        if( error == nil )
        {
            self.generateLocalOffer()
            //receive remote peers media
            
            //let remotePeers:Set<NSObject> = (self.roomClient?.peers)!
            let remotePeers:[AnyObject] = (self.roomClient?.peers)!
            for obj:AnyObject in remotePeers
            {
                if( obj is NBMPeer )
                {
                    let peer:NBMPeer = obj as! NBMPeer
                    let peerConnection:NBMPeerConnection? = self.connectionOfPeer( peer )
                    if( peerConnection == nil && peer.streams.count > 0 )
                    {
                        self.generateOfferForPeer( peer )
                    }
                }
            }
        }
    }
    
    func client(client:NBMRoomClient, didLeaveRoom error:NSError)
    {
        print("client - 4")
    }
    
    func client(client:NBMRoomClient, didPublishVideo sdpAnswer:String, loopback doLoopback:Bool, error isError:NSError)
    {
        print("client - 5")
    }
    
    func client(client:NBMRoomClient, didUnPublishVideo error:NSError)
    {
        print("client - 6")
    }
    
    func client(client:NBMRoomClient, didReceiveVideoFrom peer:NBMPeer, sdpAnswer sdpanswer:String, error isError:NSError)
    {
        print("client - 7")
    }
    
    func client(client:NBMRoomClient, didUnsubscribeVideoFrom peer:NBMPeer, sdpAnswer sdpanswer:String, error isError:NSError)
    {
        print("client - 8")
    }
    
    func client(client:NBMRoomClient, didSentICECandidate error:NSError, forPeer peer:NBMPeer)
    {
        print("client - 9 - peer:\(peer.identifier)")
    }
    
    func client(client:NBMRoomClient, didSentMessage error:NSError)
    {
        print("client - 10")
    }
    
    func client(client:NBMRoomClient, didSentCustomRequest error:NSError, didResponse response:NBMResponse)
    {
        print("* client - 11")
        self.delegate!.roomManager( self, didSentCustomRequest:error, didResponse:response )
    }
    
    //------------------------------------------------------
    // Room events
    func client(client:NBMRoomClient, participantJoined peer:NBMPeer)
    {
        print("* client - 12")
        self.delegate!.roomManager( self, peerJoined:peer )
    }
    
    func client(client:NBMRoomClient, participantLeft peer:NBMPeer)
    {
        print("* client - 13")
        let connectionId:String = self.connectionIdOfPeer( peer )
        self.webRTCPeer?.closeConnectionWithConnectionId( connectionId )
        self.delegate!.roomManager( self, peerLeft: peer )
    }
    
    func client(client:NBMRoomClient, participantEvicted peer:NBMPeer)
    {
        print("* client - 14")
        self.delegate!.roomManager( self, peerEvicted: peer )
    }
    
    func client(client:NBMRoomClient, participantPublished peer:NBMPeer)
    {
        print("* client - 15")
        let peerConnection:NBMPeerConnection? = self.connectionOfPeer( peer )
        if( peerConnection == nil && peer.streams.count > 0 )
        {
            self.generateOfferForPeer( peer )
        }
    }
    
    func client(client:NBMRoomClient, participantUnpublished peer:NBMPeer)
    {
        print("* client - 16")
        let connectionId:String = self.connectionIdOfPeer( peer )
        self.webRTCPeer?.closeConnectionWithConnectionId( connectionId )
    }
    
    func client(client:NBMRoomClient, didReceiveICECandidate candidate:RTCIceCandidate, fromParticipant peer:NBMPeer)
    {
        print("* client - 17 -peer:\(peer.identifier)")
        let connectionId:String = self.connectionIdOfPeer( peer )
        self.webRTCPeer?.addICECandidate( candidate, connectionId:connectionId )
    }
    
    func client(client:NBMRoomClient, didReceiveMessage message:String, fromParticipant peer:NBMPeer)
    {
        print("* client - 18")
        self.delegate!.roomManager( self, messageReceived:message, ofPeer:peer )
    }
    
    func client(client:NBMRoomClient, mediaErrorOccurred error:NSError)
    {
        print("client - 19")
    }
    
    func client(client:NBMRoomClient, roomWasClosed room:NBMRoom)
    {
        print("client - 20")
    }
    
    
    /*====================================================*/
    /*                    Private Section                 */
    /*====================================================*/
    private func setupRoomClient(room:NBMRoom)
    {
        self.roomClient = NBMRoomClient(room: room, delegate: self)
    }
    
    private func setupReachability()
    {
        self.reachability = ReachabilityUtil( hostName: self.roomClient!.room.url.absoluteString )
        
        self.reachability?.reachableBlock = {
            [weak self] reach in
            print("REACHABLE: connected \(self?.isConnected()) - joined \(self?.isJoined())")
            //if( self != nil && !self!.isConnected() )
            if( self?.roomClient?.connectionState == NBMRoomClientConnectionState.Closed )
            {
                
                self!.manageRoomClientConnection()
            }
        }
        
        //dispatch_async( dispatch_get_main_queue(), { () -> Void in
        self.reachability?.startNotifier()
        //})
    }
    
    func localPeer() -> NBMPeer
    {
        return self.roomClient!.room.localPeer
    }
    
    private func manageRoomClientConnection()
    {
        let isReachable:Bool = self.reachability!.isReachable()
        let retryAllowed:Bool = self.retryCount < 3
        
        if( retryAllowed && isReachable )
        {
            self.retryCount += 1
            self.roomClient?.connect()
        }
        else if( !retryAllowed || !isReachable )
        {
            print("Imposible to establish connection")
            
            let retryError:NSError = NSError(domain: "com.zed.nubomedia.uoat", code: 0, userInfo: ["key2":"Imposible to establish WebSocket connection to Room Server, check internet connection"])
            self.delegate!.roomManager(self, didFailWithError: retryError)
        }
    }
    
    private func setupWebRTCSession()
    {
        let webRTCManager = NBMWebRTCPeer( delegate:self, configuration:self.config )
        if( webRTCManager == nil )
        {
            let retryError:NSError = NSError(domain: "com.zed.nubomedia.uoat", code: 0, userInfo: ["key1":"Impossible to setup local media stream, check AUDIO & VIDEO permission"])
            self.delegate!.roomManager( self, didFailWithError:retryError )
            return
        }
        
        self.webRTCPeer = webRTCManager
        let startedLocalMedia:Bool = (self.webRTCPeer?.startLocalMedia())!
        if( startedLocalMedia )
        {
            print("Localmedia started!")
        }
        //dispatch_async( dispatch_get_main_queue(), { () -> Void in
        //    self.delegate.roomManager(self, didAddLocalStream: self.localStream())
        //})
    }
    
    private func localStream() -> RTCMediaStream
    {
        return self.webRTCPeer!.localStream
    }
    
    private func isConnected() -> Bool
    {
        return (self.roomClient?.connected)!
    }
    
    private func isJoined() -> Bool
    {
        return (self.roomClient?.joined)!
    }
    
    private func joinToRoom()
    {
        self.roomClient?.joinRoom()
    }
    
    private func generateLocalOffer()
    {
        self.generateOfferForPeer( self.localPeer() )
    }
    
    private func connectionOfPeer(peer:NBMPeer) -> NBMPeerConnection?
    {
        let connectionId:String = self.connectionIdOfPeer( peer )
        let connection:NBMPeerConnection? = self.webRTCPeer?.connectionWithConnectionId(connectionId)
        
        return connection
    }
    
    private func generateOfferForPeer(peer:NBMPeer)
    {
        let connectionId:String = self.connectionIdOfPeer( peer )
        self.webRTCPeer?.generateOffer( connectionId )
    }
    
    private func connectionIdOfPeer(peer:NBMPeer?) -> String
    {
        var peerTmp:NBMPeer? = peer
        if( peer == nil )
        {
            peerTmp = self.localPeer();
        }
        let connectionId:String = peerTmp!.identifier;
        
        return connectionId;
    }
    
    private func peerOfConnection(connection:NBMPeerConnection) -> NBMPeer?
    {
        let connectionId:String = connection.connectionId
        var peer:NBMPeer? = nil
        
        for peerTmp:NBMPeer in self.allPeers()
        {
            let connectionIdOfPeerTmp:String = self.connectionIdOfPeer(peerTmp)
            if( connectionIdOfPeerTmp == connectionId )
            {
                peer = peerTmp
                break
            }
        }
        
        return peer
    }
    
    private func allPeers() ->[NBMPeer]
    {
        var allPeersTmp:[NBMPeer] = self.remotePeers()
        allPeersTmp.append( self.localPeer() )
        
        return allPeersTmp
    }
    
    
    private weak var delegate:RoomManagerDelegate?
    private var config:NBMMediaConfiguration?
    private var roomClient:NBMRoomClient?
    private var webRTCPeer:NBMWebRTCPeer?
    private var reachability:ReachabilityUtil?
    private var retryCount:Int
    private var mutableRemoteStreams:[RTCMediaStream]
    private var loopBack:Bool
}
