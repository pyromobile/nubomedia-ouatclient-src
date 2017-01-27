//
//  NetworkWatcher.swift
//  uoat
//
//  Created by Pyro User on 20/9/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkWatcher
{
    static var internetAvailabe:Bool = true
    static let reachabilityStatusChangedNotification = "ReachabilityStatusChangeNotification"
    
    class func isInternetAvailable()
    {
        let hostToConnect:String = "google.com"
        var context = SCNetworkReachabilityContext( version:0, info:nil, retain:nil, release:nil, copyDescription: nil )
        //context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())
        let isAvailable = SCNetworkReachabilityCreateWithName( nil, hostToConnect )!
        SCNetworkReachabilitySetCallback( isAvailable, {(_,flags,_) -> Void in
            var reachabilityFlags = SCNetworkReachabilityFlags()
            reachabilityFlags = flags
            
            //let myObject = Unmanaged<NetworkWatcher>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()

            var isAvailable:Bool = false
            if( reachabilityFlags.contains(.Reachable) && !reachabilityFlags.contains(.ConnectionRequired) )
            {
                if( reachabilityFlags.contains(.IsWWAN) )
                {
                    NetworkWatcher.internetAvailabe = true
                    isAvailable = true
                    print("Online device by data access!")
                }
                else
                {
                    NetworkWatcher.internetAvailabe = true
                    isAvailable = true
                    print("Onlne device by wi-fi access!")
                }
            }
            else
            {
                NetworkWatcher.internetAvailabe = false
                isAvailable = false
                print("Offline device")
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName( NetworkWatcher.reachabilityStatusChangedNotification, object:nil, userInfo: ["isAvailable":isAvailable] )
        }, &context )
        
        SCNetworkReachabilityScheduleWithRunLoop( isAvailable, CFRunLoopGetMain(), kCFRunLoopCommonModes )
    }
    
    /*
    func myCallback(reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutablePointer<Void>)
    {
        var reachabilityFlags = SCNetworkReachabilityFlags()
        reachabilityFlags = flags
        
        if( reachabilityFlags.contains(.Reachable) && !reachabilityFlags.contains(.ConnectionRequired) )
        {
            if( reachabilityFlags.contains(.IsWWAN) )
            {
                internetAvailabe = true
                print("Online device by data access!")
            }
            else
            {
                internetAvailabe = true
                print("Onlne device by wi-fi access!")
            }
        }
        else
        {
            internetAvailabe = false
            print("Offline device")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName( NetworkWatcher.reachabilityStatusChangedNotification, object:nil )

    }
 */
}