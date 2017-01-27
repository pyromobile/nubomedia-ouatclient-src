//
//  Notification.swift
//  uoat
//
//  Created by Pyro User on 28/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class Notification
{
    init(id:String, type:NotificationType, from:String, to:String, roomId:String)
    {
        self.id = id
        self.type = type
        self.to = to
        self.from = from
        self.roomId = roomId
        self.nicknameFrom = ""
    }
    
    func getId() -> String
    {
        return self.id
    }
    
    func getType() -> NotificationType
    {
        return self.type
    }

    func getTo() -> String
    {
        return self.to
    }
    
    func getFrom() -> String
    {
        return self.from
    }
    
    func getRoomId() -> String
    {
        return self.roomId
    }
    
    var nickNameFrom:String {
        get {
            return self.nicknameFrom
        }
        set(nickname){
            self.nicknameFrom = nickname
        }
    }
    
    private var id:String
    private var type:NotificationType
    private var to:String
    private var from:String
    private var roomId:String
    private var nicknameFrom:String
}