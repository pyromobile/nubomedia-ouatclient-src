//
//  AppDelegate.swift
//  uoat
//
//  Created by Pyro User on 4/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NetworkWatcher.isInternetAvailable();
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.window?.rootViewController?.presentedViewController is TaleModeLobbyViewController
        {
            if( window?.rootViewController?.presentedViewController?.presentedViewController is SWRevealViewController)
            {
                return self.prepareOrientationForTaleMode( (window?.rootViewController?.presentedViewController?.presentedViewController)! )
            }
            else if(window?.rootViewController?.presentedViewController?.presentedViewController is FreeModeViewController)
            {
                return self.prepareOrientationForFreeMode( (window?.rootViewController?.presentedViewController?.presentedViewController)! )
            }
            else
            {
                return UIInterfaceOrientationMask.Landscape
            }
        }
        else if( self.window?.rootViewController?.presentedViewController is InviteNotificationsManagerViewController )
        {
            if( window?.rootViewController?.presentedViewController?.presentedViewController is SWRevealViewController)
            {
                return self.prepareOrientationForTaleMode( (window?.rootViewController?.presentedViewController?.presentedViewController)! )
            }
            else if(window?.rootViewController?.presentedViewController?.presentedViewController is FreeModeViewController)
            {
                return self.prepareOrientationForFreeMode( (window?.rootViewController?.presentedViewController?.presentedViewController)! )
            }
            else
            {
                return UIInterfaceOrientationMask.Landscape
            }
        }
        else
        {
            return UIInterfaceOrientationMask.Landscape
        }
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareOrientationForTaleMode(currentViewController:UIViewController) -> UIInterfaceOrientationMask
    {
        let revealViewController = currentViewController as! SWRevealViewController
        if( (revealViewController.frontViewController as! UINavigationController).viewControllers.first is TaleModeViewController )
        {
            let talemodeViewController = (revealViewController.frontViewController as! UINavigationController).viewControllers.first as! TaleModeViewController
            
            if( talemodeViewController.isVisible )
            {
                if( !talemodeViewController.isFullTale )
                {
                    if(talemodeViewController.isFirstCall )
                    {
                        talemodeViewController.view.alpha = 0
                    }
                    print("PORTRAIT")
                    return UIInterfaceOrientationMask.Portrait
                }
                else
                {
                    print("LANDSCAPE")
                    return UIInterfaceOrientationMask.Landscape
                }
            }
            else
            {
                print("LANDSCAPE")
                return UIInterfaceOrientationMask.Landscape
            }
        }
        else
        {
            return UIInterfaceOrientationMask.Landscape
        }
    }
    
    private func prepareOrientationForFreeMode(currentViewController:UIViewController) -> UIInterfaceOrientationMask
    {
        let freeModeViewController = currentViewController as! FreeModeViewController
        freeModeViewController.view.alpha = freeModeViewController.isFirstTime ? 0 : 1
        print("PORTRAIT")
        return UIInterfaceOrientationMask.Portrait
    }
}

