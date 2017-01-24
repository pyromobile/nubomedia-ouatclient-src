//
//  UserModel.swift
//  uoat
//
//  Created by Pyro User on 8/8/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class UserModel
{
    class func login(userName:String, password:String, onLogin:(isOK:Bool,userId:String,nick:String,code:String)->Void)
    {
        KuasarsCore.loginWithAppInternalToken(password, userId:userName){ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( ( error ) != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                onLogin( isOK:false, userId:"", nick:"", code:"" )
            }
            else
            {
                print( "User logged Ok!" )
                let info = response.contentObjects[0] as! NSDictionary
                
                let id:String = info["userId"] as! String
                
                UserModel.loadUserEntities( id, callback:{ (isOk, nick, code) in
                    if( isOk )
                    {
                        onLogin( isOK:true, userId:id, nick:nick, code:code )
                    }
                    else
                    {
                        onLogin( isOK:false, userId:"", nick:"", code:"" )
                    }
                })
            }
        }
    }
    
    class func signup(userName:String, password:String, secretCode:String, onSignup:(isOK:Bool,userId:String)->Void)
    {
        let user = KuasarsUser( internalToken:password, andInternalIdentifier: userName )
        user.fullName = userName
        user.custom = ["code":secretCode]
        user.save { ( response:KuasarsResponse!, error:KuasarsError! ) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                onSignup( isOK:false, userId:"" )
            }
            else
            {
                print( "User created Ok!" )
                KuasarsCore.loginWithAppInternalToken(password, userId: userName) { (response:KuasarsResponse!, error:KuasarsError!) -> Void in
                    if( ( error ) != nil )
                    {
                        //Utils.alertMessage( self, title:"Error", message:"User or password wrong!" )
                        print( "Error from kuasars: \(error.description)" )
                        onSignup( isOK:false, userId:"" )
                    }
                    else
                    {
                        print( "User logged Ok!" )
                        let info = response.contentObjects[0] as! NSDictionary
                        
                        let id:String = info["userId"] as! String
                        
                        //self.user.setProfile( id, name:userName, password:password )
                        
                        //self.createUserEntities()
                        UserModel.createUserEntities( id, nick:"Guest",code:secretCode, callback: { (isOk) in
                            if( isOk )
                            {
                                onSignup( isOK:true, userId:id )
                            }
                            else
                            {
                                onSignup( isOK:false, userId:"" )
                            }
                        })
                    }
                }
            }
        }
    }
    
    class func logout()
    {
        KuasarsCore.logout { (response:KuasarsResponse!, error:KuasarsError!) in
            //No hacemos nada.
        }
    }
    
    class func updateNick(userId:String, nick:String, uniqueCode:String, onUpdateNick:(isOK:Bool)->Void)
    {
        let entity = ["id":"pub_\(userId)","nick":nick,"logged":true,"code":uniqueCode]
        let usersEntity = KuasarsEntity( type:"users", customData:entity as [NSObject : AnyObject], expirationDate:0, occEnabled:false )
        
        let acl = KuasarsPermissions()
        acl.setReadPermissions( KuasarsReadPermissionALL, usersList:nil, groupList:nil )
        usersEntity.setPermissions( acl )
        usersEntity.replace({ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                //Utils.alertMessage( self, title: "Error", message: "Nick name wasn't changed!" )
                onUpdateNick( isOK:false )
            }
            else
            {
                print( "Update users entity Ok!" )
                //Utils.alertMessage( self, title: "Info", message: "Nick name was changed correctly!" )
                onUpdateNick( isOK:true )
            }
        })
    }
    
    class func loadUserFriends(userId:String,callback:(friends:[(id:String,nick:String)]?)->Void)
    {
        let criteria:[String:AnyObject] = ["me":"pub_\(userId)"]
        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
        KuasarsEntity.query( query, entityType: "friends", occEnabled: false, completion:{ (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
            }
            else
            {
                if( response.statusCode == 200 )
                {
                    let batch = KuasarsBatch()
                    
                    let entities = response.contentObjects as! [KuasarsEntity]
                    for entity:KuasarsEntity in entities
                    {
                        let friendId:String = (entity.customData!["friend"])! as! String
                        print("Amigo encontrado:\(friendId)")
                        
                        let criteria:[String:AnyObject] = ["id":"\(friendId)"]
                        let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
                        
                        let request:KuasarsRequest = KuasarsServices.queryEntities( query, type:"users", occEnabled:false )
                        batch.addRequest(request)
                    }
                    batch.performRequests({ (response:KuasarsResponse!, error:KuasarsError!) in
                        if( error != nil )
                        {
                            print( "Error from kuasars: \(error.description)" )
                            callback(friends:nil)
                        }
                        else
                        {
                            var friends:[(id:String,nick:String)] = [(id:String,nick:String)]()
                            let responses = response.contentObjects as! [NSDictionary]
                            for index in 0 ..< responses.count
                            {
                                let rsp:NSDictionary = responses[index] as NSDictionary
                                let body:[NSDictionary] = rsp["body"] as! [NSDictionary]
                                let friendNick = body[0]["nick"] as! String
                                let id:String = entities[index].customData["friend"] as! String
                                friends.append( (id:id, nick:friendNick) )
                            }
                            callback(friends: friends)
                        }
                    })
                }
                else
                {
                    //No results!
                    callback(friends:[])
                }
            }
        })
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private class func loadUserEntities(userId:String, callback:(isOk:Bool,nick:String,code:String)->Void)
    {
        //load user's public profile.
        KuasarsEntity.getWithType( "users", entityID: "pub_\(userId)", occEnabled: false) { (response:KuasarsResponse!, error:KuasarsError!) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                callback( isOk:false, nick:"", code:"" )
            }
            else
            {
                let entity = response.contentObjects[0] as! KuasarsEntity
                let nick:String = entity.customData!["nick"]! as! String
                let code:String = entity.customData!["code"]! as! String
                //load user's friend group.
                callback( isOk:true, nick:nick, code:code )
            }
        }
    }
    
    private class func createUserEntities(userId:String,nick:String,code:String,callback:(isOk:Bool)->Void)
    {
        //creates user's public profile.
        let entity = ["id":"pub_\(userId)","nick":nick,"logged":true, "code":code]
        let usersEntity = KuasarsEntity( type:"users", customData:entity as [NSObject : AnyObject], expirationDate:0, occEnabled:false )
        
        let acl = KuasarsPermissions()
        acl.setReadPermissions( KuasarsReadPermissionALL, usersList:nil, groupList:nil )
        usersEntity.setPermissions( acl )
        usersEntity.save { ( response:KuasarsResponse!, error:KuasarsError! ) -> Void in
            if( error != nil )
            {
                print( "Error from kuasars: \(error.description)" )
                callback( isOk:false )
            }
            else
            {
                //creates user's friends group.
                let entity = ["id":"grp_\(userId)","friends":[]]
                let friendsEntity = KuasarsEntity( type:"friends", customData:entity as [NSObject:AnyObject], expirationDate:0, occEnabled:false )
                let acl = KuasarsPermissions()
                acl.setReadPermissions( KuasarsReadPermissionALL, usersList: nil, groupList: nil )
                friendsEntity.setPermissions( acl )
                friendsEntity.save({ ( response:KuasarsResponse!, error:KuasarsError! ) -> Void in
                    if( error != nil )
                    {
                        print( "Error from kuasars: \(error.description)" )
                        callback( isOk:false )
                    }
                    else
                    {
                        //let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "mainViewController" ) as? ViewController;
                        //mainViewController?.user = self.user
                        
                        //self.presentViewController( mainViewController!, animated: true, completion: nil )
                        /*
                        self.dismissViewControllerAnimated( true, completion:{[unowned self] in
                            self.delegate?.onLoginSignupReady()
                            })
                        */
                        callback( isOk:true )
                    }
                })
            }
        }
    }
}