//
//  ViewController.swift
//  uoat
//
//  Created by Pyro User on 4/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LoginSignupDelegate, ProfileDelegate
{
    var user:User!
    
    required init?(coder aDecoder: NSCoder)
    {
        //Detectar idioma.
        let langId = NSLocale.preferredLanguages()[0].split("-")[0];
        print("Idioma device: \(langId)");
        print("Scale:\(UIScreen.mainScreen().scale)")
        print("VIEW:\(UIScreen.mainScreen().bounds)")
        LanguageMgr.getInstance.setId( langId );

        //Create library with books in device.
        Library.create( langId, isHD: ( UIScreen.mainScreen().scale > 1.0 ) )
        var bookIds:[String] = [String]()
        for book in Library.getInstance().currentBooks()
        {
            print("Tale detected in device: \(book.id) - \(book.title)")
            bookIds.append(book.id)
        }

        let pos = Int(arc4random_uniform( UInt32(bookIds.count) ) )
        self.bgImgPath = Library.getInstance().getFirstImageToPresentation( bookIds[pos] )
        
        self.user = User()
        
        self.wellcomeMsg = ""
        
        super.init(coder: aDecoder);
        
        //Init kuasars.
        self.initKuasars();
        
        //Load accesories to show in game.
        AccesoriesMgr.create( ( UIScreen.mainScreen().scale > 1.0 ) )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.networkStatusChanged(_:)), name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set background image from any book
        if( self.bgMainImage.image == nil )
        {
            self.bgMainImage.image = UIImage( contentsOfFile: self.bgImgPath )!
            let blurEffectView:UIVisualEffectView = Utils.blurEffectView(self.bgMainImage, radius: 6)   //3
            self.bgMainImage.addSubview( blurEffectView )
        }
        
        //buttons animations.
        self.originalPosTaleModeButton = self.taleModeButton.frame
        self.originalPosFreeModeButton = self.freeModeButton.frame
        self.originalPosBottomGrpView = self.bottomGrpView.frame
        self.originalPosJoinSessionGrpView = self.joinSessionGrpView.frame

        //invite notifications.
        //self.invitesButton.enabled = false
        self.joinSessionGrpView.hidden = true
        self.bgNotificationImage.hidden = true
        self.notificationCountLabel.text = ""
        
        //friendship notifications.
        self.bgFriendshipNotificationImage.hidden = true
        self.friendshipNotificationCountLabel.text = ""
    }
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        //Main buttons.
        if( hasSetAnimationValuesNow )
        {
            self.taleModeButton.frame.origin.x = self.view.bounds.width
            self.freeModeButton.frame.origin.x = -self.freeModeButton.frame.width
            self.bottomGrpView.frame.origin.y  = self.view.bounds.height
            self.joinSessionGrpView.frame.origin.x = self.view.bounds.width
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.hasSetAnimationValuesNow = false
            UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
                    self.taleModeButton.frame = self.originalPosTaleModeButton
                    self.freeModeButton.frame = self.originalPosFreeModeButton
                    self.bottomGrpView.frame  = self.originalPosBottomGrpView
                    if( !self.joinSessionGrpView.hidden )
                    {
                        self.joinSessionGrpView.frame = self.originalPosJoinSessionGrpView
                    }
                }) { [unowned self] (finished:Bool) in
                    self.showNotificationsInfo()
            }
        })
        self.showUserInfo()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        self.hasSetAnimationValuesNow = true
        if( segue.identifier == "showLoginSignupView" )
        {
            //let navigationController = segue.destinationViewController as! UINavigationController
            //let controller = navigationController.viewControllers.first as! LoginSignupViewController
            let controller = segue.destinationViewController as! LoginSignupViewController
            controller.user = self.user
            controller.delegate = self
        }
        else if( segue.identifier == "showProfileView" )
        {
            let controller = segue.destinationViewController as! ProfileViewController
            controller.user = self.user
            controller.delegate = self
        }
        else if( segue.identifier == "showFriendsManagerView" )
        {
            let controller = segue.destinationViewController as! FriendsManagerViewController
            controller.user = self.user
            controller.notificationsByType = self.notificationsByType
        }
        else if( segue.identifier == "showModeLobbyView" )
        {
            //let navigationController = segue.destinationViewController as! UINavigationController
            //let controller = navigationController.viewControllers.first as! TaleModeLobbyViewController
            let controller = segue.destinationViewController as! TaleModeLobbyViewController
            controller.user = self.user
            controller.bgImagePath = self.bgImgPath
        }
        else if( segue.identifier == "showInviteNotificationsManagerView" )
        {
            let controller = segue.destinationViewController as! InviteNotificationsManagerViewController
            controller.user = self.user
            controller.bgImagePath = self.bgImgPath
            controller.notificationsByType = self.notificationsByType
        }
    }

    func willShowFriends(sender:UIButton)
    {
        if( NetworkWatcher.internetAvailabe )
        {
            UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
                self.taleModeButton.frame.origin.x = self.view.frame.width
                self.freeModeButton.frame.origin.x = -self.freeModeButton.frame.width
                self.bottomGrpView.frame.origin.y = self.view.frame.height
                if( !self.joinSessionGrpView.hidden )
                {
                    self.joinSessionGrpView.frame.origin.x = self.view.frame.width
                }
            }) { [unowned self] (finished:Bool) in
                self.performSegueWithIdentifier( "showFriendsManagerView", sender:nil )
            }
        }
        else
        {
           Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }
    
    func willShowInvites(sender:UIButton)
    {
        if( NetworkWatcher.internetAvailabe )
        {
            UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
                self.taleModeButton.frame.origin.x = self.view.frame.width
                self.freeModeButton.frame.origin.x = -self.freeModeButton.frame.width
                self.bottomGrpView.frame.origin.y = self.view.frame.height
                if( !self.joinSessionGrpView.hidden )
                {
                    self.joinSessionGrpView.frame.origin.x = self.view.frame.width
                }
            }) { [unowned self] (finished:Bool) in
                self.performSegueWithIdentifier( "showInviteNotificationsManagerView", sender:nil )
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }
    
    func networkStatusChanged(notification:NSNotification)
    {
        print("ViewController::networkStatusChanged was called...")
        let userInfo:Dictionary<String,Bool!> = notification.userInfo as! Dictionary<String,Bool!>
        let isAvailable:Bool = userInfo["isAvailable"]!
        
        if( !isAvailable )
        {
            Utils.alertMessage( self, title:"Attention", message:"Internet connection lost!", onAlertClose:nil )
        }
        
        self.notificationsErrorMessageShowed = false
    }

    
    /*=============================================================*/
    /*                   From LoginSignupDelegate                  */
    /*=============================================================*/
    func onLoginSignupReady()
    {
        hasSetAnimationValuesNow = false
        self.showUserInfo()
        self.showNotificationsInfo()
    }
    
    
    /*=============================================================*/
    /*                     From ProfileDelegate                    */
    /*=============================================================*/
    func onProfileReady()
    {
        hasSetAnimationValuesNow = false
        self.showUserInfo()
        self.showNotificationsInfo()
    }

    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var bgMainImage: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var taleModeButton: UIButton!
    @IBOutlet weak var freeModeButton: UIButton!
    @IBOutlet weak var joinSessionGrpView: UIView!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var bgNotificationImage: UIImageView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var bottomGrpView: UIView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var bgFriendshipNotificationImage: UIImageView!
    @IBOutlet weak var friendshipNotificationCountLabel: UILabel!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func login(sender: UIButton)
    {
        if( NetworkWatcher.internetAvailabe )
        {
            if( !self.user.isLogged() )
            {
                self.performSegueWithIdentifier("showLoginSignupView", sender: nil)
            }
            else
            {
                self.performSegueWithIdentifier("showProfileView", sender: nil)
            }
        }
        else
        {
            Utils.alertMessage( self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }
    
    @IBAction func starTaleMode(sender: UIButton)
    {
        UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
            self.taleModeButton.frame.origin.x = self.view.frame.width
            self.freeModeButton.frame.origin.x = -self.freeModeButton.frame.width
            self.bottomGrpView.frame.origin.y = self.view.frame.height
            if( !self.joinSessionGrpView.hidden )
            {
                self.joinSessionGrpView.frame.origin.x = self.view.frame.width
            }
        }) { [unowned self] (finished:Bool) in
            self.user.lobby = .Tale
            self.performSegueWithIdentifier("showModeLobbyView", sender: nil )
        }
    }
    
    @IBAction func starFreeMode(sender: UIButton)
    {
        if( NetworkWatcher.internetAvailabe )
        {
            UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
                self.taleModeButton.frame.origin.x = self.view.frame.width
                self.freeModeButton.frame.origin.x = -self.freeModeButton.frame.width
                self.bottomGrpView.frame.origin.y = self.view.frame.height
                if( !self.joinSessionGrpView.hidden )
                {
                    self.joinSessionGrpView.frame.origin.x = self.view.frame.width
                }
            }) { [unowned self] (finished:Bool) in
                self.user.lobby = .Free
                self.performSegueWithIdentifier("showModeLobbyView", sender: nil )
            }
        }
        else
        {
            Utils.alertMessage(self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
        }
    }

    @IBAction func showCredits(sender: UIButton)
    {
        performSegueWithIdentifier("showInformationView", sender: nil)
    }
    
    @IBAction func showGallery(sender: UIButton)
    {
        performSegueWithIdentifier("showGalleryView", sender: nil )
    }
    
    @IBAction func unwindToMainView(segue: UIStoryboardSegue)
    {
        //Back from TaleModeViewController or FreeModeViewController
        if( segue.sourceViewController.isKindOfClass( FreeModeViewController ) )
        {
            let controller:FreeModeViewController = segue.sourceViewController as! FreeModeViewController
            
            self.user = controller.user
            controller.user = nil
        }
        else if( segue.sourceViewController.isKindOfClass( TaleModeViewController ) )
        {
            let controller:TaleModeViewController = segue.sourceViewController as! TaleModeViewController
            
            self.user = controller.user
            controller.user = nil
        }
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func initKuasars()
    {
        KuasarsCore.setAppId( "560ab6e3e4b0b185810131aa" );
        KuasarsCore.setEnvironment( KuasarsEnvironmentPRO );
        KuasarsCore.setDebuggerEnabled( true );
    }
    
    private func showUserInfo()
    {
        if( self.user.isLogged() )
        {
            //Hi message and change login button title.
            let hiName = self.wellcomeMsg + self.user.name;
            helloLabel.text = hiName;
            helloLabel.hidden = false;
            loginButton.setTitle( "Profile", forState: .Normal );
            
            //Friends button.
            self.friendsButton.enabled = true
            self.friendsButton.addTarget( self, action:#selector(ViewController.willShowFriends(_:)), forControlEvents:.TouchUpInside )
        }
        else
        {
            if( self.wellcomeMsg.isEmpty )
            {
                self.wellcomeMsg = helloLabel.text!
            }
            
            helloLabel.text = self.wellcomeMsg
            helloLabel.hidden = true
            loginButton.setTitle( "Registrarse", forState: .Normal )
            
            //Friends button.
            self.friendsButton.enabled = false
            self.friendsButton.removeTarget( self, action:#selector(ViewController.willShowFriends(_:)), forControlEvents:.TouchUpInside )
        }
    }
    
    private func showNotificationsInfo()
    {
        //Invite button is showed when notifications for playingroom and readingroom are received.
        if( self.user.isLogged() )
        {
            if( NetworkWatcher.internetAvailabe )
            {
                NotificationModel.getAllByUser( self.user.id, onNotificationsReady:{[unowned self](notifications) in
                    //Show
                    var invitesCount:Int = 0
                    var friendshipRequestCount:Int = 0
                    if let invitesPlayingRoom = notifications[NotificationType.PlayingRoom]
                    {
                        invitesCount += invitesPlayingRoom.count
                    }
                    else if let invitesReadingRoom = notifications[NotificationType.ReadingRoom]
                    {
                        invitesCount += invitesReadingRoom.count
                    }
                    else if let friendship = notifications[NotificationType.FriendShip]
                    {
                        friendshipRequestCount += friendship.count
                    }
                    
                    //Show invites to room notifications.
                    if( invitesCount > 0 )
                    {
                        //self.invitesButton.enabled = true
                        self.notificationCountLabel.text = "\(invitesCount)"
                        if( self.joinSessionGrpView.hidden )
                        {
                            self.joinSessionGrpView.hidden = false
                            self.bgNotificationImage.hidden = false
                            self.invitesButton.addTarget( self, action:#selector(ViewController.willShowInvites(_:)), forControlEvents:.TouchUpInside )
                            self.joinSessionGrpView.alpha = 0.0
                            UIView.animateWithDuration( 0.5, animations:{ [unowned self] in
                                self.joinSessionGrpView.alpha = 1.0
                            })
                        }
                    }
                    else
                    {
                        //self.invitesButton.enabled = false
                        self.joinSessionGrpView.hidden = true
                        self.bgNotificationImage.hidden = true
                        self.notificationCountLabel.text = ""
                    }
                    
                    //Show friendship notifications.
                    if( friendshipRequestCount > 0 )
                    {
                        self.bgFriendshipNotificationImage.hidden = false
                        self.friendshipNotificationCountLabel.text = "\(friendshipRequestCount)"
                    }
                    else
                    {
                        self.bgFriendshipNotificationImage.hidden = true
                        self.friendshipNotificationCountLabel.text = ""
                    }
                    
                    self.notificationsByType = notifications
                })
            }
            else
            {
                if( !self.notificationsErrorMessageShowed )
                {
                    Utils.alertMessage(self, title:"Attention", message:"You must have internet connection!", onAlertClose:nil )
                    self.notificationsErrorMessageShowed = true
                }
            }
        }
        else
        {
            //self.invitesButton.enabled = false
            
            if( !self.joinSessionGrpView.hidden )
            {
                self.joinSessionGrpView.alpha = 1.0
                UIView.animateWithDuration( 0.2, animations:{ [unowned self] in
                    self.joinSessionGrpView.alpha = 0.0
                }){ [unowned self] (finished:Bool) in
                    self.joinSessionGrpView.hidden = true
                    self.bgNotificationImage.hidden = true
                    self.notificationCountLabel.text = ""
                }
            }
            
            self.bgFriendshipNotificationImage.hidden = true
            self.friendshipNotificationCountLabel.text = ""
        }
    }
    
    
    private var hasSetAnimationValuesNow:Bool = true
    private var originalPosTaleModeButton:CGRect = CGRect.zero
    private var originalPosFreeModeButton:CGRect = CGRect.zero
    private var originalPosBottomGrpView:CGRect = CGRect.zero
    private var originalPosJoinSessionGrpView:CGRect = CGRect.zero
    private var wellcomeMsg:String
    private var bgImgPath:String
    private var notificationsByType:[NotificationType:[Notification]] = [NotificationType:[Notification]]()
    private var notificationsErrorMessageShowed:Bool = false
}
