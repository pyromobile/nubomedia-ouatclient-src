//
//  LobbyType.swift
//  uoat
//
//  Created by Pyro User on 24/6/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

enum LobbyType:Int
{
    case Tale
    case Free
}

/* DEPRECATED
class Lobby
{
    init( type:LobbyType, user:User? )
    {
        self.roomId = ""
        self.type = type
        self.user = user
    }
    
    internal func getType() -> LobbyType
    {
        return self.type
    }
    
    internal func getUser() -> User?
    {
        return self.user
    }
    
    
    internal var roomId:String
    private var type:LobbyType
    private var user:User?
}
 */