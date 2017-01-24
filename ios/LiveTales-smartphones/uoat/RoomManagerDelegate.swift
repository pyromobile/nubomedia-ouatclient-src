//
//  RoomManagerDelegate.swift
//  uoat
//
//  Created by Pyro User on 18/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

protocol RoomManagerDelegate:class
{
    func roomManagerDidFinish(broker:RoomManager);
    
    func roomManager(broker:RoomManager, didAddLocalStream localStream:RTCMediaStream);
    
    func roomManager(broker:RoomManager, didRemoveLocalStream localStream:RTCMediaStream);
    
    func roomManager(broker:RoomManager, didAddStream remoteStream:RTCMediaStream, ofPeer remotePeer:NBMPeer);
    
    func roomManager(broker:RoomManager, didRemoveStream remoteStream:RTCMediaStream, ofPeer remotePeer:NBMPeer);
    
    func roomManager(broker:RoomManager, peerJoined peer:NBMPeer);
    
    func roomManager(broker:RoomManager, peerLeft peer:NBMPeer);
    
    func roomManager(broker:RoomManager, peerEvicted peer:NBMPeer);
    
    func roomManager(broker:RoomManager, roomJoined error:NSError?);
    
    func roomManager(broker:RoomManager, messageReceived message:String, ofPeer peer:NBMPeer);
    
    func roomManagerPeerStatusChanged(broker:RoomManager);
    
    func roomManager(broker:RoomManager, didFailWithError error:NSError);
    
    func roomManager(broker:RoomManager, iceStatusChanged state:RTCICEConnectionState, ofPeer peer:NBMPeer);
    
    func roomManager(broker:RoomManager, didSentCustomRequest error:NSError, didResponse response:NBMResponse);
}