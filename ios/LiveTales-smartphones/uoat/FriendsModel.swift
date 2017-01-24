//
//  FriendsModel.swift
//  uoat
//
//  Created by Pyro User on 9/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class FriendsModel
{
    class func createFriendship(to:String, from:String, onFriendshipReady:(error:Bool)->Void)
    {
        let batch = KuasarsBatch()
        
        //create friend relationship.
        let friendEntityMeFriend:KuasarsRequest = FriendsModel.createFriendEntity( to, friend:from )
        let friendEntityFriendMe:KuasarsRequest = FriendsModel.createFriendEntity( from, friend:to )

        batch.addRequest( friendEntityMeFriend )
        batch.addRequest( friendEntityFriendMe )
        
        batch.performRequests { (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print("Kuasars error:\(error.description)")
                onFriendshipReady( error:true )
            }
            else
            {
                print("Saved!")
                onFriendshipReady( error:false )
            }
        }
    }
    
    
    class func deleteFriendship(userId:String,friendIds:[String],onDeleteFriendshipReady:(error:Bool)->Void)
    {
        var entitiesToRemove:[String] = [String]()
        
        let batch = KuasarsBatch()
        for friendId:String in friendIds
        {
            //let friendId:String = friendsToShow.removeValueForKey(friendSelected)!
            
            
            //{"$or":[{"me":"pub_56d825d3e4b07d03caa019c3","friend":"pub_573b1d53e4b04c6b97862081"},{"me":"pub_573b1d53e4b04c6b97862081","friend":"pub_56d825d3e4b07d03caa019c3"}]}
            let meFriendCriteria:[String:AnyObject] = ["me":"pub_\(userId)", "friend":friendId]
            let friendMeCriteria:[String:AnyObject] = ["me":friendId, "friend":"pub_\(userId)"]
            
            var criterias:[[String:AnyObject]] = [[String:AnyObject]]()
            criterias.append(meFriendCriteria)
            criterias.append(friendMeCriteria)
            
            let orCriteria:[String:AnyObject] = ["$or":criterias]
            
            let query = KuasarsQuery( orCriteria, retrievingFields: ["id"] ) as KuasarsQuery
            let friendRequest:KuasarsRequest = KuasarsServices.queryEntities(query, type: "friends", occEnabled: false)
            
            batch.addRequest(friendRequest)
        }
        batch.performRequests({ (response:KuasarsResponse!, error:KuasarsError!) in
            if( error != nil )
            {
                print("Kuasars error: \(error.description)")
                onDeleteFriendshipReady( error:true )
            }
            else
            {
                let body:NSArray = response.contentObjects[0]["body"] as! NSArray
                
                for respInBody in body
                {
                    let id:String = respInBody["id"] as! String
                    print("ID:\(id)")
                    entitiesToRemove.append(id)
                }
                
                KuasarsEntity.deleteEntitiesOfType("friends", withIds: entitiesToRemove) { (response:KuasarsResponse!, error:KuasarsError!) in
                    if( error != nil )
                    {
                        print("Kuasars error:\(error.description)")
                        onDeleteFriendshipReady(error:true)
                    }
                    else
                    {
                        print("Removed")
                        onDeleteFriendshipReady(error:false)
                    }
                }
            }
        })
    }
    
    
    private class func createFriendEntity(me:String, friend:String) -> KuasarsRequest
    {
        let friendForMe = ["me":me, "friend":friend]
        let requestsEntity = KuasarsEntity(type: "friends", customData: friendForMe as [NSObject : AnyObject], expirationDate:0, occEnabled: false)
        
        let acl = KuasarsPermissions()
        acl.setReadPermissions( KuasarsReadPermissionALL, usersList: nil, groupList: nil )
        requestsEntity.setPermissions( acl )
        let friendEntityRequest:KuasarsRequest = KuasarsServices.saveNewEntity( requestsEntity )
        
        return friendEntityRequest
    }
}