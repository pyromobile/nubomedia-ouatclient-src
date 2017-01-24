//
//  NotificationModel.swift
//  uoat
//
//  Created by Pyro User on 28/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

enum NotificationType
{
    case Undefined
    case ReadingRoom
    case PlayingRoom
    case FriendShip
}


class NotificationModel
{
    class func getAllByUser(userId:String, onNotificationsReady:(notifications:[NotificationType:[Notification]])->Void)
    {
        var notificationsByType:[NotificationType:[Notification]] = [NotificationType:[Notification]]()
        
        let criteria:[String:AnyObject] = ["to":"pub_\(userId)"]
        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
        KuasarsEntity.query( query, entityType: "requests", occEnabled: false, completion:{ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                let entities = response.contentObjects as! [KuasarsEntity]
                for entity:KuasarsEntity in entities
                {
                    let id:String = entity.ID
                    let type:String = (entity.customData![TypeField])! as! String
                    let from:String = (entity.customData![FromField])! as! String
                    let to:String = (entity.customData![ToField])! as! String

                    var roomId:String = ""
                    if( type == ReadingRoom || type == PlayingRoom )
                    {
                        roomId = (entity.customData![RoomIdField])! as! String
                    }
                    let typed = getTypeByName(type)
                    
                    let notification = Notification( id:id, type:typed, from:from, to:to, roomId:roomId )

                    if var _ = notificationsByType[typed]
                    {
                        notificationsByType[typed]?.append( notification )
                    }
                    else
                    {
                        notificationsByType[typed] = [notification]
                    }
                }
            }
            onNotificationsReady( notifications:notificationsByType )
        })
    }
    
    class func getNickNamesFromNotifications( notifications:[Notification], onNotificationsReady:(notifications:[Notification])->Void )
    {
        let batch = KuasarsBatch()
        for notification:Notification in notifications
        {
            let friendId:String = notification.getFrom()
            
            let criteria:[String:AnyObject] = ["id":"\(friendId)"]
            let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
            
            let request:KuasarsRequest = KuasarsServices.queryEntities(query, type: "users", occEnabled: false)
            batch.addRequest(request)
        }
        
        batch.performRequests({ (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                let responses = response.contentObjects as! [NSDictionary]
                for index in 0 ..< responses.count
                {
                    let rsp:NSDictionary = responses[index] as NSDictionary
                    let body:[NSDictionary] = rsp["body"] as! [NSDictionary]
                    
                    let friendNick = body[0]["nick"] as! String
                    print("Request Amigo :\(friendNick)")
                    notifications[index].nickNameFrom = friendNick
                }
            }
            onNotificationsReady( notifications: notifications )
        })
    }
    
    class func getNickNamesFromSentNotifications( notifications:[Notification], onNotificationsReady:(notifications:[Notification])->Void )
    {
        let batch = KuasarsBatch()
        for notification:Notification in notifications
        {
            let friendId:String = notification.getTo()
            
            let criteria:[String:AnyObject] = ["id":"\(friendId)"]
            let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
            
            let request:KuasarsRequest = KuasarsServices.queryEntities(query, type: "users", occEnabled: false)
            batch.addRequest(request)
        }
        
        batch.performRequests({ (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                let responses = response.contentObjects as! [NSDictionary]
                for index in 0 ..< responses.count
                {
                    let rsp:NSDictionary = responses[index] as NSDictionary
                    let body:[NSDictionary] = rsp["body"] as! [NSDictionary]
                    
                    let friendNick = body[0]["nick"] as! String
                    print("Request Amigo :\(friendNick)")
                    notifications[index].nickNameFrom = friendNick
                }
            }
            onNotificationsReady( notifications: notifications )
        })
    }
    
    
    class func removeNotificationsById(notificationIds:[String], onNotificationsReady:()->Void)
    {
        KuasarsEntity.deleteEntitiesOfType("requests", withIds: notificationIds) { (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print("Kuasars error:\(error.description)")
            }
            else
            {
                print("Removed")
            }
            onNotificationsReady()
        }
    }
    
    class func sendNotifications(notifications:[Notification],onNotificationsReady:(error:Bool)->Void)
    {
        let serverTimeRequest:KuasarsRequest = KuasarsServices.getCurrentTime()
        KuasarsCore.executeRequest(serverTimeRequest) { (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print("Error get server time: \(error.description)")
            }
            else
            {
                let expire:Double = 10*60*1000 //Ten minutes!
                
                //Get time from server.
                let content:NSDictionary = response.contentObjects[0] as! NSDictionary
                let serverTime:Double = content["timeInMillisFrom1970"] as! Double
                
                let batch = KuasarsBatch()
                for notification in notifications
                {
                    let type:String = getNameByType( notification.getType() )
                    if( type.isEmpty ){ continue }
                    let friendId:String = notification.getTo()
                    let userId:String = notification.getFrom()
                    let roomId:String = notification.getRoomId()
                    
                    //create friend request.
                    let entity = ["type":type,"to":friendId,"from":"pub_\(userId)","roomId":roomId,"expireAt":(serverTime + expire)]
                    let requestsEntity = KuasarsEntity(type: "requests", customData: entity as [NSObject : AnyObject], expirationDate:(serverTime + expire), occEnabled: false)
                    
                    let acl = KuasarsPermissions()
                    acl.setReadPermissions( KuasarsReadPermissionALL, usersList: nil, groupList: nil )
                    requestsEntity.setPermissions( acl )
                    
                    let request:KuasarsRequest = KuasarsServices.saveNewEntity(requestsEntity)
                    
                    batch.addRequest( request )
                }
                batch.performRequests({ (response:KuasarsResponse!, error:KuasarsError!) in
                    onNotificationsReady(error:error != nil)
                })
            }
        }
    }
    
    class func sendFriendshipRequest(userId:String, friendSecrectCode:String, friendNick:String,onFriendshipReady:(error:Bool)->Void)
    {
        //Check secrect code remote user & get time from server.
        let criteria:[String:AnyObject] = ["code":friendSecrectCode, "nick":friendNick]
        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
        let userQueryRequest:KuasarsRequest = KuasarsServices.queryEntities( query, type: "users", occEnabled: false)
        
        let serverTimeRequest:KuasarsRequest = KuasarsServices.getCurrentTime()
        
        let batch = KuasarsBatch()
        batch.addRequest( userQueryRequest )
        batch.addRequest( serverTimeRequest )
        
        batch.performRequests { (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                onFriendshipReady( error:true )
            }
            else
            {
                //User exist?
                let responses = response.contentObjects as! [NSDictionary]
                let resp1 = responses[0] as NSDictionary
                let userExists = ( resp1["code"] as! Int == 200 )
                
                if( userExists )
                {
                    let body1 = resp1["body"] as! NSArray
                    let friendID = body1[0]["id"] as! String
                    print("friend ID:\(friendID)")
                    
                    //Server time.
                    let expire:Double = 24*60*60*1000
                    let resp2 = responses[1] as NSDictionary
                    let body2 = resp2["body"] as! NSDictionary
                    let serverTime:Double = body2["timeInMillisFrom1970"] as! Double
                    
                    print("Server time:\(serverTime) - Add:\(expire)")
                
                    //create friend request.
                    let entity = ["type":"friendship","to":friendID,"from":"pub_\(userId)","expireAt":(serverTime + expire)]
                    let requestsEntity = KuasarsEntity(type: "requests", customData: entity as [NSObject : AnyObject], expirationDate:(serverTime + expire), occEnabled: false)
                    
                    let acl = KuasarsPermissions()
                    acl.setReadPermissions( KuasarsReadPermissionALL, usersList: nil, groupList: nil )
                    requestsEntity.setPermissions( acl )
                    requestsEntity.save { ( response:KuasarsResponse!, error:KuasarsError! ) -> Void in
                        if( error != nil )
                        {
                            print( "Error from kuasars: \(error.description)" )
                            onFriendshipReady( error:true )
                        }
                        else
                        {
                            print("Request was sent!")
                            onFriendshipReady( error:false )
                        }
                    }
                }
                else
                {
                    onFriendshipReady( error:true )
                }
            }
        }
    }
    
    
    class func getNotificationsSentByMe(userId:String, onNotificationsReady:(notifications:[NotificationType:[Notification]])->Void)
    {
        var notificationsByType:[NotificationType:[Notification]] = [NotificationType:[Notification]]()
        
        let criteria:[String:AnyObject] = ["from":"pub_\(userId)"]
        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
        KuasarsEntity.query( query, entityType: "requests", occEnabled: false, completion:{ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                let entities = response.contentObjects as! [KuasarsEntity]
                for entity:KuasarsEntity in entities
                {
                    let id:String = entity.ID
                    let type:String = (entity.customData![TypeField])! as! String
                    let from:String = (entity.customData![FromField])! as! String
                    let to:String = (entity.customData![ToField])! as! String
                    
                    var roomId:String = ""
                    if( type == ReadingRoom || type == PlayingRoom )
                    {
                        roomId = (entity.customData![RoomIdField])! as! String
                    }
                    let typed = getTypeByName(type)
                    
                    let notification = Notification( id:id, type:typed, from:from, to:to, roomId:roomId )
                    
                    if var _ = notificationsByType[typed]
                    {
                        notificationsByType[typed]?.append( notification )
                    }
                    else
                    {
                        notificationsByType[typed] = [notification]
                    }
                }
            }
            onNotificationsReady( notifications:notificationsByType )
        })
    }

    
    /*=============================================================*/
    /*                        Private Section                      */
    /*=============================================================*/
    private class func getTypeByName( typeName:String ) -> NotificationType
    {
        let notificationType:NotificationType
        switch( typeName )
        {
            case ReadingRoom:
                notificationType = .ReadingRoom
                break
            case PlayingRoom:
                notificationType = .PlayingRoom
                break
            case FriendShip:
                notificationType = .FriendShip
                break
            default:
                notificationType = .Undefined
                break
        }
        
        return notificationType
    }
    
    private class func getNameByType( type:NotificationType ) -> String
    {
        let name:String
        switch( type )
        {
            case .ReadingRoom:
                name = ReadingRoom
                break
            case .PlayingRoom:
                name = PlayingRoom
                break
            case .FriendShip:
                name = FriendShip
                break
            default:
                name = ""
        }
        
        return name
    }
    
    //Fields.
    private static let TypeField:String = "type"
    private static let FromField:String = "from"
    private static let ToField:String = "to"
    private static let RoomIdField:String = "roomId"
    
    //Types.
    private static let ReadingRoom:String = "readingroom"
    private static let PlayingRoom:String = "playingroom"
    private static let FriendShip:String = "friendship"

}