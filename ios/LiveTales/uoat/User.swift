//
//  User.swift
//  uoat
//
//  Created by Pyro User on 13/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class User
{
    init()
    {
        self.id = ""
        self.name = ""
        self.password = ""
        self.secretCode = ""
        self._nick = "Guest"
        self._lobby = LobbyType.Free
        self._roomId = ""
        self._acceptedRoomInvitation = false
        self._narrator = false
    }

    func isLogged() -> Bool
    {
        return !self.id.isEmpty && !self.name.isEmpty
    }
    
    func setProfile(id:String, name:String, password:String, secretCode:String)
    {
        self.id = id
        self.name = name
        self.password = password
        self.secretCode = secretCode
    }
    
    func reset()
    {
        self.id = ""
        self.name = ""
        self.password = ""
        self.secretCode = ""
        self._nick = "Guest"
        self._lobby = LobbyType.Free
        self._roomId = ""
        self._acceptedRoomInvitation = false
        self._narrator = false
    }
    
    //--------------------------------------------------------------
    //  Properties.
    //--------------------------------------------------------------
    var nick:String{
        get
        {
            return self._nick
        }
        set(nick)
        {
            var nickTmp:String = nick
            if( nickTmp.isEmpty )
            {
                nickTmp = "Guest"
            }
            self._nick = nickTmp
        }
    }

    var lobby:LobbyType{
        get
        {
            return self._lobby
        }
        set(lobby)
        {
            self._lobby = lobby
        }
    }
    
    var roomId:String{
        get{
            return self._roomId
        }
        set(roomId)
        {
            self._roomId = roomId
        }
    }
    
    var acceptedRoomInvitation:Bool{
        get{
            return self._acceptedRoomInvitation
        }
        set(acceptedRoomInvitation)
        {
            self._acceptedRoomInvitation = acceptedRoomInvitation
        }
    }
    
    var isNarrator:Bool{
        get{
            return self._narrator
        }
        set(narrator)
        {
            self._narrator = narrator
        }
    }
    
    internal private(set) var id:String         //Kuasars Id.
    internal private(set) var name:String       //Name for login.
    internal private(set) var password:String   //Password for login.
    internal private(set) var secretCode:String //Secrect code generated to be used in friendship.
    

    private var _nick:String         //Nick (your name for others users)
    private var _lobby:LobbyType
    private var _roomId:String
    private var _acceptedRoomInvitation:Bool
    private var _narrator:Bool
}
