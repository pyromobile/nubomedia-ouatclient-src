//
//  InviteNotificationsManagerViewController.swift
//  uoat
//
//  Created by Pyro User on 28/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class InviteNotificationsManagerViewController:UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var bgImagePath:String!
    weak var user:User!
    var notificationsByType:[NotificationType:[Notification]]!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InviteNotificationsManagerViewController.networkStatusChanged(_:)), name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil)
    }
    
    deinit
    {
        self.user = nil
        self.bgImagePath = nil
        self.notifications.removeAll()
        self.notificationIdsToBeConsumed.removeAll()
        
        NSNotificationCenter.defaultCenter().removeObserver( self, name: NetworkWatcher.reachabilityStatusChangedNotification, object: nil )
        
        print("InviteNotificationsManagerViewController - deInit....OK")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //load resources.
        //.:Back button
        let leftArrowActiveImage:UIImage = Utils.flipImage( named: "btn_next_available", orientation: .Down )
        self.leftArrowImage.image = leftArrowActiveImage
        
        if( self.bgMainImage.image == nil )
        {
            self.bgMainImage.image = UIImage( contentsOfFile:self.bgImagePath )!
            let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.bgMainImage, radius:6 )   //3
            self.bgMainImage.addSubview( blurEffectView )
        }
        
        self.notificationsTable.delegate = self
        self.notificationsTable.dataSource = self
        
        self.dumpNotifications()
        self.getNickNamesFromNotifications()
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
        if( segue.identifier == "showFreeModeView" )
        {
            let controller = segue.destinationViewController as! FreeModeViewController
            controller.user = self.user
            controller.bgImagePath = self.bgImagePath
        }
        else if( segue.identifier == "showRevealView" )
        {
            //let controller = segue.destinationViewController as! TaleModeViewController
            //controller.user = self.user
            let swrevealController = segue.destinationViewController as! SWRevealViewController
            swrevealController.loadView()
            let navigationController = swrevealController.frontViewController as! UINavigationController
            let controller = navigationController.topViewController as! TaleModeViewController
            controller.user = self.user
        }
    }
    
    func willAcceptInvite( sender:UIButton )
    {
        if( NetworkWatcher.internetAvailabe )
        {
            print("Accepted - \(sender.tag)")
            
            let row:Int = sender.tag
            
            let inviteNotificationAccepted:Notification = self.notifications[row]
            if( inviteNotificationAccepted.getType() == NotificationType.PlayingRoom )
            {
                self.user.lobby = LobbyType.Free
            }
            else
            {
                self.user.lobby = LobbyType.Tale
            }
            self.user.roomId = inviteNotificationAccepted.getRoomId()
            self.user.acceptedRoomInvitation = true
            self.user.isNarrator = false
            
            self.notificationIdsToBeConsumed.append( inviteNotificationAccepted.getId() )
            self.notifications.removeAtIndex( row )
            self.notificationsTable.reloadData()
            
            NotificationModel.removeNotificationsById( self.notificationIdsToBeConsumed, onNotificationsReady:{
                if( self.user.lobby == LobbyType.Free )
                {
                    UIView.animateWithDuration( 0.25, animations:{ [unowned self] in
                        self.view.alpha = 0.0
                        }, completion:{ [unowned self](finished:Bool) in
                            self.performSegueWithIdentifier( "showFreeModeView", sender:nil )
                    })
                }
                else
                {
                    UIView.animateWithDuration( 0.25, animations:{ [unowned self] in
                        self.view.alpha = 0.0
                        }, completion:{ [unowned self](finished:Bool) in
                            self.performSegueWithIdentifier( "showRevealView", sender:nil )
                    })
                }
            })
        }
        else
        {
            Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.networkWarning"), onAlertClose:nil )
        }
    }
    
    func willCancelInvite( sender:UIButton )
    {
        if( NetworkWatcher.internetAvailabe )
        {
            print("Removed - \(sender.tag)")
            
            let row:Int = sender.tag
            
            self.notificationIdsToBeConsumed.append( self.notifications[row].getId() )
            self.notifications.removeAtIndex( row )
            self.notificationsTable.reloadData()
            
            if( notifications.count == 0 )
            {
                NotificationModel.removeNotificationsById( self.notificationIdsToBeConsumed, onNotificationsReady:{
                    self.dismissViewControllerAnimated( true, completion:{} )
                })
            }
        }
        else
        {
            Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.networkWarning"), onAlertClose:nil )
        }
    }
    
    func networkStatusChanged(notification:NSNotification)
    {
        print("InviteNotificationsManagerViewController::networkStatusChanged was called...")
        if( NetworkWatcher.internetAvailabe )
        {
            Utils.alertMessage( self, title:Utils.localize("notice.title"), message:Utils.localize("notice.networkWorksAgain"), onAlertClose:nil )
        }
        else
        {
            Utils.alertMessage( self, title:Utils.localize("attention.title"), message:Utils.localize("attention.networkLost"), onAlertClose:nil )
        }
    }
    
    
    /*=============================================================*/
    /*                  from UITableViewDataSource                 */
    /*=============================================================*/
    func numberOfSectionsInTableView(tableView:UITableView) -> Int
    {
        return 1
    }
 
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.notifications.count;
    }
 
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( self.cellIdentifier, forIndexPath:indexPath ) as! NotificationsTableViewCell
        
        let row = indexPath.row
        
        var roomType:String = Utils.localize("inviteNotificationsManagerView.costumes")
        if( self.notifications[row].getType() == NotificationType.ReadingRoom )
        {
            roomType = Utils.localize("inviteNotificationsManagerView.tale")
        }
        
        //User information.
        cell.imageView?.image = UIImage() //TODO: foto usuario??
        cell.nickNameLabel.text = self.notifications[row].nickNameFrom
        cell.descriptionLabel.text = String(format:Utils.localize("inviteNotificationsManagerView.invite"),roomType)
        
        //Actions.
        cell.acceptButton.addTarget( self, action:#selector(InviteNotificationsManagerViewController.willAcceptInvite(_:)), forControlEvents:.TouchUpInside )
        cell.acceptButton.tag = row
        cell.cancelButton.addTarget( self, action:#selector(InviteNotificationsManagerViewController.willCancelInvite(_:)), forControlEvents:.TouchUpInside )
        cell.cancelButton.tag = row
        return cell
    }

    
    /*=============================================================*/
    /*                   from UITableViewDelegate                  */
    /*=============================================================*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var bgMainImage: UIImageView!
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var notificationsTable: UITableView!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        if( self.notificationIdsToBeConsumed.count > 0 )
        {
            NotificationModel.removeNotificationsById( self.notificationIdsToBeConsumed, onNotificationsReady:{
                self.dismissViewControllerAnimated( true, completion:{} )
            })
        }
        else
        {
           self.dismissViewControllerAnimated( true, completion:{} ) 
        }
    }
    
    
    /*=============================================================*/
    /*                        Private Section                      */
    /*=============================================================*/
    private func dumpNotifications()
    {
        if let invitesPlayingRoom = notificationsByType[NotificationType.PlayingRoom]
        {
            for notification:Notification in invitesPlayingRoom
            {
                self.notifications.append( notification )
            }
        }
        
        if let invitesReadingRoom = notificationsByType[NotificationType.ReadingRoom]
        {
            for notification:Notification in invitesReadingRoom
            {
                self.notifications.append( notification )
            }
        }
    }
    
    private func getNickNamesFromNotifications()
    {
        NotificationModel.getNickNamesFromNotifications(self.notifications) { [weak self](notifications) in
            self!.notifications = notifications
            self!.notificationsTable.reloadData()
        }
    }

    
    private let cellIdentifier:String = "NotificationsTableViewCell"
    private var notifications:[Notification] = [Notification]()
    private var notificationIdsToBeConsumed:[String] = [String]()
}
