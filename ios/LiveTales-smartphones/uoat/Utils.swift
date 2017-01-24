//
//  Utils.swift
//  uoat
//
//  Created by Pyro User on 17/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation

class Utils
{
    static func md5( string string: String ) -> String
    {
        var digest = [UInt8](count: Int( CC_MD5_DIGEST_LENGTH ), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5( data.bytes, CC_LONG( data.length ), &digest )
        }
        
        var digestHex = ""
        for index in 0..<Int( CC_MD5_DIGEST_LENGTH )
        {
            digestHex += String( format: "%02x", digest[index] )
        }
        
        return digestHex
    }
    
    static func alertMessage(viewController:UIViewController, title:String, message:String, onAlertClose:((action:UIAlertAction)->Void)?)
    {
        let alert = UIAlertController( title:title, message:message, preferredStyle:.Alert )
        //options.
        let actionOk = UIAlertAction( title:"Ok", style:.Default, handler:onAlertClose)
        alert.addAction( actionOk )
        
        viewController.presentViewController( alert, animated: true, completion:nil  )
    }

    static func blurEffectView(view:UIView, radius:Int) -> UIVisualEffectView
    {
        let customBlurClass: AnyObject.Type = NSClassFromString("_UICustomBlurEffect")!
        let customBlurObject: NSObject.Type = customBlurClass as! NSObject.Type
        
        let blurEffect = customBlurObject.init() as! UIBlurEffect
        blurEffect.setValue(radius, forKeyPath: "blurRadius")
        
        let blurEffectView = UIVisualEffectView( effect: blurEffect )
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        return blurEffectView
    }
    
    static func flipImage( named name:String, orientation:UIImageOrientation ) -> UIImage
    {
        let image:UIImage = UIImage( named: name )!
        
        //Filp arrow image.
        let imageFlip:UIImage = UIImage( CGImage: image.CGImage!, scale: image.scale, orientation: orientation )
        return imageFlip
    }
    
    static func randomString(length:Int) -> String
    {
        let baseString:NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString:NSMutableString = NSMutableString( capacity:length )
        
        for _:Int in 0...length
        {
            let len = UInt32( baseString.length )
            let rand = arc4random_uniform( len )
            randomString.appendFormat( "%C", baseString.characterAtIndex( Int( rand ) ) )
        }
        
        return String(randomString)
    }
    /* RELOCATED INTO MODELS/USER/USERMODEL.SWIFT
    static func loadUserFriends(userId:String,callback:(friends:[(id:String,nick:String)]?)->Void)
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
                let batch = KuasarsBatch()
                
                let entities = response.contentObjects as! [KuasarsEntity]
                for entity:KuasarsEntity in entities
                {
                    let friendId:String = (entity.customData!["friend"])! as! String
                    print("Amigo encontrado:\(friendId)")
                    
                    let criteria:[String:AnyObject] = ["id":"\(friendId)"]
                    let query = KuasarsQuery( criteria, retrievingFields: nil ) as KuasarsQuery
                    
                    let request:KuasarsRequest = KuasarsServices.queryEntities(query, type: "users", occEnabled: false)
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
                            /*
                            print("Amigo :\(friendNick)")
                            let usr = UILabel( frame: CGRectMake( 0, CGFloat(0 + 42*index), self.friendsScrollView.frame.width, 40 ) );
                            usr.text = friendNick
                            usr.backgroundColor = UIColor.whiteColor()
                            usr.textColor = UIColor.grayColor()
                            
                            self.friendsScrollView.addSubview( usr )
                            
                            self.friendsScrollView.contentSize = CGSize( width:self.friendsScrollView.frame.width, height: CGFloat( 42 * index) )
                            */
                            
                            let id:String = entities[index].customData["friend"] as! String
                            friends.append( (id:id, nick:friendNick) )
                        }
                        callback(friends: friends)
                    }
                })
            }
        })
    }
 */
}